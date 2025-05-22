import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/gradient_button.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/social_button.dart';
import 'package:renal_care_app/core/utils/validators.dart';

/// Provider locali pentru stocarea textului din câmpuri
final _loginEmailProvider = StateProvider<String>((_) => '');
final _loginPasswordProvider = StateProvider<String>((_) => '');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _showPassword = false;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    // Watch your form fields
    final email = ref.watch(_loginEmailProvider);
    final password = ref.watch(_loginPasswordProvider);

    // Compute per-field errors
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);

    // Determine if the whole form is valid
    final isFormValid = emailError == null && passwordError == null;

    // Watch your auth state
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
          // gradient de fundal
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

                      // email field
                      AuthTextField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (v) =>
                                ref.read(_loginEmailProvider.notifier).state =
                                    v,
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

                      // password field
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
                                ref
                                    .read(_loginPasswordProvider.notifier)
                                    .state = v,
                      ),
                      if (_submitted && passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            passwordError,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // buton gradient pentru login
                      if (authState.status == AuthStatus.loading)
                        const CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        )
                      else
                        GradientButton(
                          text: 'LOGIN',
                          onPressed: () {
                            // marchează că s-a încercat submit
                            setState(() => _submitted = true);

                            // dacă formularul e valid, continuă
                            if (isFormValid) {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .signIn(email: email, password: password);
                            }
                          },
                        ),

                      // auth error message
                      if (authState.status == AuthStatus.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            authState.errorMessage ?? 'Error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // google/register links
                      const SizedBox(height: 16),
                      // Divider înainte de Google button
                      const Divider(color: AppColors.whiteColor),
                      const SizedBox(height: 16),

                      // SocialButton pentru Google
                      SocialButton(
                        assetPath: 'assets/google_logo.jpg',
                        text: 'Sign in with Google',
                        onPressed: () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .signInWithGoogle();
                        },
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
