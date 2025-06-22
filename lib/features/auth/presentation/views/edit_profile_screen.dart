import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/core/utils/name_text_formatter.dart';
import 'package:renal_care_app/core/utils/validators.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/profile_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/profile_state.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countyCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _numberCtrl;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();

    // Preluăm datele actuale din AuthViewModel și le punem în controloare
    final user = ref.read(authViewModelProvider).user!;
    _phoneCtrl = TextEditingController(text: user.phone);
    _countyCtrl = TextEditingController(text: user.county);
    _cityCtrl = TextEditingController(text: user.city);
    _streetCtrl = TextEditingController(text: user.street);
    _numberCtrl = TextEditingController(text: user.houseNumber);
    _dob = user.dateOfBirth;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _countyCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ascultăm o singură dată ProfileState. Când devine "success", navigăm înapoi:
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.status == ProfileStatus.success) {
        // Afișăm un SnackBar cu confirmare
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              duration: Duration(milliseconds: 800),
            ),
          );
        }
        // Ieşim din ecranul de edit (poate fi și context.go('/profile') dacă vrei să ștergi complet ruta)
        if (mounted) context.go('/profile');
      }

      if (next.status == ProfileStatus.error) {
        // Dacă a apărut o eroare, o afișăm
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving: ${next.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });

    final profileState = ref.watch(profileViewModelProvider);

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
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(), // Întoarcere manuală
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // telefon
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v ?? ''),
                ),
                const SizedBox(height: 12),

                // județ
                TextFormField(
                  controller: _countyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'County',
                    prefixIcon: Icon(Icons.map),
                  ),
                  inputFormatters: [NameTextFormatter()],
                  validator: (v) => Validators.notEmpty(v ?? '', 'County'),
                ),
                const SizedBox(height: 12),

                // localitate
                TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  inputFormatters: [NameTextFormatter()],
                  validator: (v) => Validators.notEmpty(v ?? '', 'City'),
                ),
                const SizedBox(height: 12),

                // stradă
                TextFormField(
                  controller: _streetCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Street',
                    prefixIcon: Icon(Icons.home),
                  ),
                  inputFormatters: [NameTextFormatter()],
                  validator: (v) => Validators.notEmpty(v ?? '', 'Street'),
                ),
                const SizedBox(height: 12),

                // numărul casei
                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(
                    labelText: 'House Number',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  validator:
                      (v) => Validators.notEmpty(v ?? '', 'House number'),
                ),
                const SizedBox(height: 12),

                // data naşterii (readOnly + controller)
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixText:
                        _dob == null
                            ? null
                            : '${DateTime.now().year - _dob!.year} yrs',
                  ),
                  controller: TextEditingController(
                    text:
                        _dob == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(_dob!),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dob ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _dob = picked);
                  },
                  validator: (_) => _dob == null ? 'Pick date' : null,
                ),
                const SizedBox(height: 24),

                // butonul de salvare
                profileState.status == ProfileStatus.loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            56,
                          ), // înălțime 56, umple lățimea
                          backgroundColor: AppColors.gradient3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () {
                          // Validare formular
                          if (_formKey.currentState!.validate()) {
                            // Trimitem update‐ul
                            ref
                                .read(profileViewModelProvider.notifier)
                                .submit(
                                  uid:
                                      ref.read(authViewModelProvider).user!.uid,
                                  phone: _phoneCtrl.text.trim(),
                                  county: _countyCtrl.text.trim(),
                                  city: _cityCtrl.text.trim(),
                                  street: _streetCtrl.text.trim(),
                                  houseNumber: _numberCtrl.text.trim(),
                                  dateOfBirth: _dob!,
                                );
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
