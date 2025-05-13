import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/core/utils/name_text_formatter.dart';
import 'package:renal_care_app/core/utils/validators.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodel/profile_state.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/profile_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _phone, _county, _city, _street, _houseNumber;
  DateTime? _dob;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    // dacă submit e successful, mergi la home
    ref.listen<ProfileState>(profileViewModelProvider, (prev, next) {
      if (next.status == ProfileStatus.success) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // numărul de telefon
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone numebr',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => Validators.phone(v ?? ''),
                onSaved: (v) => _phone = v!,
              ),

              // Județ
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'County',
                  prefixIcon: Icon(Icons.map),
                ),
                inputFormatters: [NameTextFormatter()],
                validator: (v) => Validators.notEmpty(v ?? '', 'County'),
                onSaved: (v) => _county = v,
              ),
              const SizedBox(height: 12),

              // Localitate
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
                inputFormatters: [NameTextFormatter()],
                validator: (v) => Validators.notEmpty(v ?? '', 'City'),
                onSaved: (v) => _city = v,
              ),
              const SizedBox(height: 12),

              // Stradă
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Street',
                  prefixIcon: Icon(Icons.home),
                ),
                inputFormatters: [NameTextFormatter()],
                validator: (v) => Validators.notEmpty(v ?? '', 'Street'),
                onSaved: (v) => _street = v,
              ),
              const SizedBox(height: 12),

              // Număr
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Number',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (v) => Validators.notEmpty(v ?? '', 'House number'),
                onSaved: (v) => _houseNumber = v,
              ),
              const SizedBox(height: 12),

              // Data nașterii + afișare vârstă
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixText:
                      _dob == null
                          ? null
                          : '${DateTime.now().year - _dob!.year} years old',
                ),
                controller: TextEditingController(
                  text:
                      _dob == null
                          ? ''
                          : _dob!.toLocal().toString().split(' ')[0],
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    setState(() {
                      // păstrează doar data, fără oră:
                      _dob = DateTime(d.year, d.month, d.day);
                    });
                  }
                },
                validator: (_) => _dob == null ? 'Pick Date of Birth' : null,
              ),
              const SizedBox(height: 24),

              // Buton Salvează
              profileState.status == ProfileStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    label: const Text('Complete profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradient1,
                      foregroundColor: AppColors.whiteColor,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ref
                            .read(profileViewModelProvider.notifier)
                            .submit(
                              uid: ref.read(authViewModelProvider).user!.uid,
                              phone: _phone!,
                              county: _county!,
                              city: _city!,
                              street: _street!,
                              houseNumber: _houseNumber!,
                              dateOfBirth: _dob!,
                            );
                      }
                    },
                  ),

              if (profileState.status == ProfileStatus.error)
                Text(
                  profileState.errorMessage ?? 'Error',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
