import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/info_row.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';

class ProfileDetailScreen extends ConsumerWidget {
  /// Dacă userId e null, afișează profilul curent
  final String? userId;
  const ProfileDetailScreen({this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final currentUid = authState.user?.uid;
    final uidToShow = userId ?? currentUid;

    // Dacă nu avem niciun UID (numele user-ului e null), afișăm o pagină de eroare
    if (uidToShow == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Nu am putut identifica utilizatorul.')),
      );
    }

    // Determinăm dacă e profilul propriu
    final isOwnProfile = userId == null || userId == currentUid;

    // Afișăm fie datele din AuthViewModel (pentru profilul curent),
    // fie apelăm userProvider(uidToShow) pentru a obține un User din Firestore.
    final userAsync =
        isOwnProfile
            // deja în authState
            ? AsyncValue.data(authState.user!)
            // folosim FutureProvider.family care returnează User după uid
            : ref.watch(userProvider(uidToShow));

    final showDocs =
        isOwnProfile || (authState.user?.role == 'doctor' && !isOwnProfile);

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        // Formatează data nașterii și adresa
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
                        onPressed: () => context.push('/editProfile'),
                        tooltip: 'Edit profile',
                      ),
                    ]
                    : null,
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Avatar + nume + email
                  Center(
                    child: Column(
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

                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Divider(height: 32),

                        // Informații generale
                        InfoRow(label: 'Phone', value: user.phone ?? '—'),
                        InfoRow(label: 'Date of Birth', value: dob),
                        InfoRow(label: 'Role', value: user.role),
                        InfoRow(
                          label: 'Address',
                          value: address.isNotEmpty ? address : '—',
                        ),
                        const SizedBox(height: 24),

                        // Primul chenar: Saved Documents (documente salvate din chat)
                        if (showDocs)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.borderColor),
                              ),
                              color: AppColors.backgroundColor.withValues(
                                alpha: 0.8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Navighează spre ecranul de „Saved Documents”
                                  GoRouter.of(
                                    context,
                                  ).push('/profile/$uidToShow/savedDocs');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.folder_shared,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Saved Documents',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Al doilea chenar: Documente → Measurement (documente pe baza măsurătorilor)
                        if (showDocs)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.borderColor),
                              ),
                              color: AppColors.backgroundColor.withValues(
                                alpha: 0.8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Navighează spre ecranul de „Measurement Documents”
                                  GoRouter.of(
                                    context,
                                  ).push('/profile/$uidToShow/measurementDocs');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.stacked_bar_chart,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Measurement Documents',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Al treilea chenar: pentru Journal Documents
                        if (showDocs)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.borderColor),
                              ),
                              color: AppColors.backgroundColor.withValues(
                                alpha: 0.8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  GoRouter.of(
                                    context,
                                  ).push('/profile/$uidToShow/journalDocs');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.note,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Journal Documents',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
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
