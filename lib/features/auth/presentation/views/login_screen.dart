import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_state.dart';

/// Provider locali pentru stocarea textului din câmpuri
final _loginEmailProvider = StateProvider<String>((_) => '');
final _loginPasswordProvider = StateProvider<String>((_) => '');

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // Ascultăm schimbările de stare și navigăm dacă autentificarea e OK
    ref.listen<AuthState>(authViewModelProvider, (_, state) {
      if (state.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background gradient
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
          // Form card
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
                        'RenalCare',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 32,
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
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (v) =>
                                ref.read(_loginEmailProvider.notifier).state =
                                    v,
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
                                ref
                                    .read(_loginPasswordProvider.notifier)
                                    .state = v,
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
                                  .signIn(
                                    email: ref.read(_loginEmailProvider),
                                    password: ref.read(_loginPasswordProvider),
                                  );
                            },
                            child: const Text(
                              'LOGIN',
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
                      const SizedBox(height: 16),
                      // Divider înainte de Google button
                      const Divider(color: AppColors.whiteColor),
                      const SizedBox(height: 16),
                      // Google Sign-In button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteColor,
                            foregroundColor: AppColors.backgroundColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/google_logo.png',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text('Sign in with Google'),
                          onPressed: () {
                            ref
                                .read(authViewModelProvider.notifier)
                                .signInWithGoogle();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(
                          "Don't have an account? Sign up",
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
