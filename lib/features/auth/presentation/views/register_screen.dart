import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/core/utils/validators.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/gradient_button.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/social_button.dart';
import 'package:renal_care_app/core/utils/name_text_formatter.dart';

/// Provider locali pentru câmpurile de înregistrare
final _regNameProvider = StateProvider<String>((_) => '');
final _regEmailProvider = StateProvider<String>((_) => '');
final _regPasswordProvider = StateProvider<String>((_) => '');
final _regRoleProvider = StateProvider<UserRole>((_) => UserRole.patient);

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _showPassword = false;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(_regNameProvider);
    final email = ref.watch(_regEmailProvider);
    final password = ref.watch(_regPasswordProvider);
    final role = ref.watch(_regRoleProvider);

    // Calculeaza erorile pe fiecare câmp
    final nameError = Validators.notEmpty(name, 'Full Name');
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);

    // Determinare dacă formularul e valid în ansamblu
    final isFormValid =
        nameError == null && emailError == null && passwordError == null;

    final authState = ref.watch(authViewModelProvider);

    // Ascultăm schimbările de stare și navigăm dacă autentificarea e OK
    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradient1,
                  AppColors.gradient2,
                  AppColors.gradient3,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: AppColors.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.borderColor),
                ),
                elevation: 8,

                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // field-ul pentru numele întreg
                      AuthTextField(
                        icon: Icons.person,
                        label: 'Full Name',
                        keyboardType: TextInputType.name,
                        inputFormatters: [NameTextFormatter()],
                        onChanged:
                            (v) =>
                                ref.read(_regNameProvider.notifier).state = v,
                      ),
                      if (_submitted && nameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            nameError,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // field-ul pentru email
                      AuthTextField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (v) =>
                                ref.read(_regEmailProvider.notifier).state = v,
                      ),
                      if (_submitted && emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            emailError,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // field-ul pentru parolă
                      AuthTextField(
                        icon: Icons.lock_outline,
                        label: 'Password',
                        obscure: !_showPassword,
                        showToggle: true,
                        onToggle:
                            () =>
                                setState(() => _showPassword = !_showPassword),
                        onChanged:
                            (v) =>
                                ref.read(_regPasswordProvider.notifier).state =
                                    v,
                      ),
                      if (_submitted && passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            passwordError,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<UserRole>(
                        value: ref.watch(_regRoleProvider),
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          labelStyle: TextStyle(color: AppColors.whiteColor),
                        ),
                        dropdownColor: AppColors.backgroundColor,
                        style: const TextStyle(color: AppColors.whiteColor),
                        items:
                            UserRole.values
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (r) =>
                                ref.read(_regRoleProvider.notifier).state = r!,
                      ),
                      const SizedBox(height: 24),

                      // butonul pentru înregistrare
                      if (authState.status == AuthStatus.loading)
                        const CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        )
                      else
                        GradientButton(
                          text: 'REGISTER',
                          onPressed: () {
                            setState(() => _submitted = true);

                            if (isFormValid) {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .signUp(
                                    name: name,
                                    email: email,
                                    password: password,
                                    role: role,
                                  );
                            }
                          },
                        ),

                      //eroare de autentificare
                      if (authState.status == AuthStatus.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            authState.errorMessage ?? 'Error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.whiteColor),
                      const SizedBox(height: 16),

                      // Google Sign-Up
                      SocialButton(
                        assetPath: 'assets/google_logo.jpg',
                        text: 'Sign up with Google',
                        onPressed: () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .signInWithGoogle();
                        },
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppColors.whiteColor),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: AppColors.gradient3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
