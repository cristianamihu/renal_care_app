import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:renal_care_app/features/auth/presentation/views/login_screen.dart';
import 'package:renal_care_app/features/auth/presentation/views/register_screen.dart';
import 'package:renal_care_app/features/home/presentation/views/home_screen.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_viewmodel.dart';

/// Un ChangeNotifier care notifică GoRouter când se schimbă starea de autentificare
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    // Ascultăm AuthState și notificăm GoRouter să re-evalueze redirect
    ref.listen<AuthState>(authViewModelProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Un provider global de GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  // Cream notifier-ul care va reîmprospăta router-ul
  final authListenable = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable:
        authListenable, // se va re-evalua când authListenable schimbă starea
    // Rutele aplicației
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(title: 'RenalCare home page'),
      ),
    ],

    // Logica de redirect în funcție de stare
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final loggedIn = authState.status == AuthStatus.authenticated;
      final goingToLogin =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (!loggedIn && !goingToLogin) {
        // Dacă nu ești logat și încerci să accesezi altceva decât login/register
        return '/login';
      }
      if (loggedIn && goingToLogin) {
        // Dacă ești logat și încerci login/register, du-te la home
        return '/home';
      }
      // Altfel, nu redirecționa
      return null;
    },
  );
});
