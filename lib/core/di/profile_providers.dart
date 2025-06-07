import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/domain/entities/profile_document.dart';

/// Provider care ascultă documentele de profil ale unui anumit userId
final profileDocsForUserProvider = StreamProvider.autoDispose
    .family<List<ProfileDocument>, String>((ref, userId) {
      // userId vine din Family
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile_documents')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((doc) {
                  final data = doc.data();
                  return ProfileDocument(
                    id: doc.id,
                    name: data['name'] as String,
                    url: data['url'] as String,
                    type: data['type'] as String,
                    addedAt: (data['addedAt'] as Timestamp).toDate(),
                  );
                }).toList(),
          );
    });

/// „Shortcut” pentru documentele user-ului curent
final profileDocsProvider =
    Provider.autoDispose<AsyncValue<List<ProfileDocument>>>((ref) {
      final authState = ref.watch(authViewModelProvider);
      final uid = authState.user?.uid;
      if (uid == null) {
        // Dacă nu e niciun user logat, returnăm o AsyncValue.data golă
        return const AsyncValue.data(<ProfileDocument>[]);
      }
      return ref.watch(profileDocsForUserProvider(uid));
    });
