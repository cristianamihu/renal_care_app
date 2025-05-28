import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/info_row.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';

class ProfileDetailScreen extends ConsumerWidget {
  /// dacă e null, arată profilul curentului user
  final String? userId;
  const ProfileDetailScreen({this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final currentUid = authState.user?.uid;
    final uidToShow = userId ?? currentUid;

    // Determinăm dacă e profilul propriu
    final isOwnProfile = userId == null || userId == currentUid;

    // 3) Luăm fie user-ul curent (din authState), fie îl încărcăm din Firestore
    final userAsync =
        isOwnProfile
            // deja în authState
            ? AsyncValue.data(authState.user!)
            // folosim FutureProvider.family care returnează User după uid
            : ref.watch(userProvider(uidToShow!));

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        // formatez DOB și address
        final dob =
            user.dateOfBirth != null
                ? DateFormat('dd MMM yyyy').format(user.dateOfBirth!)
                : '—';
        final address = [
          if (user.county != null) user.county,
          if (user.city != null) user.city,
          if (user.street != null) user.street,
          if (user.houseNumber != null) user.houseNumber,
        ].where((s) => s != null).join(', ');

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
            title: Text(isOwnProfile ? 'Profile' : user.name),
            actions:
                isOwnProfile
                    ? [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.go('/editProfile'),
                        tooltip: 'Edit profile',
                      ),
                    ]
                    : null,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.gradient3,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 32),

                  InfoRow(label: 'Phone', value: user.phone ?? '—'),
                  InfoRow(label: 'Date of Birth', value: dob),
                  InfoRow(label: 'Role', value: user.role),
                  InfoRow(
                    label: 'Address',
                    value: address.isNotEmpty ? address : '—',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
