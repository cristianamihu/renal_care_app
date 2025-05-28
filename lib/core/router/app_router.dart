import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:renal_care_app/core/widgets/main_scaffold.dart';
import 'package:renal_care_app/features/auth/presentation/views/edit_profile_screen.dart';

import 'package:renal_care_app/features/auth/presentation/views/login_screen.dart';
import 'package:renal_care_app/features/auth/presentation/views/complete_profile_screen.dart';
import 'package:renal_care_app/features/auth/presentation/views/profile_detail_screen.dart';
import 'package:renal_care_app/features/auth/presentation/views/register_screen.dart';
import 'package:renal_care_app/features/chat/presentation/views/chat_room_list_screen.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/chat/presentation/views/chat_screen.dart';
import 'package:renal_care_app/features/emergency/presentation/views/emergency_screen.dart';
import 'package:renal_care_app/features/journal/presentation/views/journal_list_screen.dart';
import 'package:renal_care_app/features/home/presentation/views/measurements_screen.dart';

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
final appRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((
  ref,
  rootKey,
) {
  // Cream notifier-ul care va reîmprospăta router-ul
  final authListenable = _AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/login',
    refreshListenable:
        authListenable, // se va re-evalua când authListenable schimbă starea
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(child: Text(state.error.toString())),
        ),

    // Rutele aplicației
    routes: [
      // rutele publice
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/completeProfile',
        builder: (_, __) => const CompleteProfileScreen(),
      ),

      GoRoute(
        path: '/editProfile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(path: '/emergency', builder: (_, __) => const EmergencyPage()),

      // Profilul user-ului
      GoRoute(
        path: '/profile',
        builder: (_, __) => MainScaffold(child: const ProfileDetailScreen()),
      ),

      // profilul oricărui alt user
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final otherUid = state.pathParameters['userId']!;
          return MainScaffold(child: ProfileDetailScreen(userId: otherUid));
        },
      ),

      // "Home" repurposed → MeasurementsScreen
      GoRoute(
        path: '/home',
        builder: (_, __) => MainScaffold(child: const MeasurementsScreen()),
      ),

      GoRoute(
        path: '/journal',
        builder: (_, __) => MainScaffold(child: const JournalListScreen()),
      ),

      // Mesagerie
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ChatRoomListScreen(),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return ChatScreen(roomId: roomId);
            },
          ),
        ],
      ),
    ],

    // Logica de redirect în funcție de stare
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final loggedIn = authState.status == AuthStatus.authenticated;
      final profileComplete = authState.user?.profileComplete ?? false;
      final goingToProfile = state.uri.path == '/completeProfile';
      final goingToLogin =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (state.uri.path == '/') {
        // redirect the bare "/" to your real home
        return '/home';
      }

      // Dacă nu ești logat și încerci să accesezi altceva decât login/register → du-l la /login
      if (!loggedIn && !goingToLogin) {
        return '/login';
      }

      // dacă ești logat, dar încă n-a completat profilul, şi nu e deja la completeProfile
      if (loggedIn && !profileComplete && !goingToProfile) {
        return '/completeProfile';
      }

      //dacă ești logat, profil OK, dar încearcă să intre la login/register/completeProfile
      if (loggedIn &&
          profileComplete &&
          (state.uri.path == '/login' ||
              state.uri.path == '/register' ||
              goingToProfile)) {
        return '/home';
      }

      // Altfel, nu redirecționa
      return null;
    },
  );
});
