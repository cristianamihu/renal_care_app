import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Provider locali pentru câmpurile de înregistrare
final _regEmailProvider = StateProvider<String>((_) => '');
final _regPasswordProvider = StateProvider<String>((_) => '');
final _regRoleProvider = StateProvider<UserRole>((_) => UserRole.patient);

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  AppColors.gradient3,
                  AppColors.gradient1,
                  AppColors.gradient2,
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
                      TextField(
                        style: const TextStyle(color: AppColors.whiteColor),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.whiteColor,
                          ),
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: AppColors.whiteColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.whiteColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged:
                            (v) =>
                                ref.read(_regEmailProvider.notifier).state = v,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(color: AppColors.whiteColor),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.whiteColor,
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: AppColors.whiteColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.whiteColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                        onChanged:
                            (v) =>
                                ref.read(_regPasswordProvider.notifier).state =
                                    v,
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
                      if (authState.status == AuthStatus.loading)
                        const CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gradient2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .signUp(
                                    email: ref.read(_regEmailProvider),
                                    password: ref.read(_regPasswordProvider),
                                    role: ref.read(_regRoleProvider),
                                  );
                            },
                            child: const Text(
                              'REGISTER',
                              style: TextStyle(letterSpacing: 1.2),
                            ),
                          ),
                        ),
                      if (authState.status == AuthStatus.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            authState.errorMessage ?? 'Error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
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
