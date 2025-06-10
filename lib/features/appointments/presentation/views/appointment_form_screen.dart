import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/appointments_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/appointments/data/models/appointment_model.dart';
import 'package:renal_care_app/features/appointments/domain/entities/appointment.dart';
import 'package:renal_care_app/features/auth/data/models/user_model.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class AppointmentFormScreen extends ConsumerStatefulWidget {
  /// Dacă e non-null, înseamnă Edit mode și facem fetch pe acel ID.
  final String? appointmentId;

  const AppointmentFormScreen({super.key, this.appointmentId});

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  DateTime? _pickedDateTime;

  late String _currentRole;
  List<User> _doctorList = [];
  String? _selectedDoctorId;
  String? _selectedDoctorAddress;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController();

    final me = ref.read(authViewModelProvider).user!;
    _currentRole = me.role; // rolul din AuthState

    if (_currentRole == 'patient') {
      _loadDoctors(); // încarcă lista de doctori din Firestore
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    final me = ref.read(authViewModelProvider).user!;
    // găsește chat_rooms unde ești participant
    final rooms =
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('participants', arrayContains: me.uid)
            .get();

    final doctorIds = <String>{};
    for (var r in rooms.docs) {
      for (var pid in r.data()['participants']) {
        if (pid != me.uid) doctorIds.add(pid);
      }
    }

    final users = await Future.wait(
      doctorIds.map((did) async {
        final snap =
            await FirebaseFirestore.instance.collection('users').doc(did).get();
        final model = UserModel.fromDocument(snap);
        return model.toEntity();
      }),
    );

    setState(() => _doctorList = users);
  }

  Future<Appointment?> _loadAppointment() async {
    final uid = ref.read(authViewModelProvider).user!.uid;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('appointments')
            .doc(widget.appointmentId)
            .get();
    if (!doc.exists) return null;
    return AppointmentModel.fromJson(doc.data()!, doc.id).toEntity();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _pickedDateTime ?? now.add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || time == null) return;

    setState(() {
      _pickedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _onSave(Appointment? initial) async {
    if (!_formKey.currentState!.validate() ||
        _pickedDateTime == null ||
        (_currentRole == 'patient' && _selectedDoctorId == null)) {
      if (_currentRole == 'patient' && _selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trebuie să selectezi un doctor.')),
        );
      }
      return;
    }

    final me = ref.read(authViewModelProvider).user!;
    // referință la colecția de appointments a pacientului
    final appointmentsCol = FirebaseFirestore.instance
        .collection('users')
        .doc(me.uid)
        .collection('appointments');

    // dacă e edit => ia id-ul vechi, altfel cere Firestore unul nou
    final newId = initial?.id ?? appointmentsCol.doc().id;

    final appt = Appointment(
      id: newId,
      patientId: me.uid,
      doctorId: initial?.doctorId ?? _selectedDoctorId!,
      dateTime: _pickedDateTime!,
      description: _descCtrl.text.trim(),
      doctorAddress: initial?.doctorAddress ?? _selectedDoctorAddress!,
    );

    final vm = ref.read(appointmentViewModelProvider.notifier);
    if (initial == null) {
      await vm.create(appt);
    } else {
      await vm.update(appt);
    }

    // once it's committed and re‐loaded, pop back:
    if (!mounted) return;
    context.pop();
  }

  Widget _buildForm(BuildContext ctx, Appointment? initial) {
    final isEditing = initial != null;
    // dacă venim din FutureBuilder, setăm valorile inițiale o singură dată:
    if (isEditing && _pickedDateTime == null) {
      _descCtrl.text = initial.description;
      _pickedDateTime = initial.dateTime;
      _selectedDoctorId = initial.doctorId;
      _selectedDoctorAddress = initial.doctorAddress;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradient1,
                AppColors.gradient2,
                AppColors.gradient3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(isEditing ? 'Edit Appointment' : 'New Appointment'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_currentRole == 'patient') ...[
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: const InputDecoration(
                    labelText: 'Doctor',
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  items:
                      _doctorList
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.uid,
                              child: Text(u.name),
                            ),
                          )
                          .toList(),
                  onChanged: (id) {
                    final u = _doctorList.firstWhere((x) => x.uid == id);
                    setState(() {
                      _selectedDoctorId = u.uid;
                      _selectedDoctorAddress = [
                        if (u.county != null) u.county,
                        if (u.city != null) u.city,
                        if (u.street != null) u.street,
                        if (u.houseNumber != null) u.houseNumber,
                      ].where((s) => s != null).join(', ');
                    });
                  },
                  validator:
                      (v) => v == null ? 'You must select a doctor' : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.note),
                ),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _pickedDateTime == null
                      ? 'Pick date & time'
                      : DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(_pickedDateTime!),
                ),
                onTap: _pickDateTime,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(isEditing ? 'UPDATE' : 'CREATE'),
                  onPressed: () async => await _onSave(initial),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // dacă suntem în NEW mode, afișăm direct form-ul gol:
    if (widget.appointmentId == null) {
      return _buildForm(context, null);
    }

    // dacă doctor
    if (_currentRole == 'doctor' && widget.appointmentId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Doctor view - aici vezi cererile de programare',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // dacă pacient
    // altfel, edit mode → încărcăm din Firestore
    return FutureBuilder<Appointment?>(
      future: _loadAppointment(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          // Afișează eroarea exactă
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Eroare la încărcare: ${snap.error}'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Înapoi'),
                  ),
                ],
              ),
            ),
          );
        }
        // avem datele
        return _buildForm(context, snap.data);
      },
    );
  }
}
