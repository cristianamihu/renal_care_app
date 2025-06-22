import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/core/di/profile_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/views/image_viewer_screen.dart';

class SavedDocumentsScreen extends ConsumerWidget {
  /// Dacă userId e null, înseamnă „documentele user-ului curent”
  final String? userId;

  const SavedDocumentsScreen({super.key, this.userId});

  Future<void> _openDocument(
    BuildContext context,
    String url,
    String name,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final localPath = '${dir.path}/${p.basename(url)}';
      final file = File(localPath);
      if (!await file.exists()) {
        await Dio().download(url, localPath);
      }
      await OpenFile.open(localPath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening: $e')));
      }
    }
  }

  Future<void> _saveDocument(
    BuildContext context,
    String url,
    String filename,
  ) async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download/RenalCare');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final targetPath = p.join(downloadsDir.path, filename);
      await Dio().download(url, targetPath);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved in: $targetPath')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  void _showAttachmentOptions(BuildContext ctx, String url, String filename) {
    showModalBottomSheet(
      context: ctx,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Open'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openDocument(ctx, url, filename);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Save'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _saveDocument(ctx, url, filename);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.read(authViewModelProvider).user!.uid;
    final isOwnProfile = userId == null || userId == currentUid;

    final uidToLoad = userId ?? ref.read(authViewModelProvider).user!.uid;
    final docsAsync = ref.watch(profileDocsForUserProvider(uidToLoad));

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
        title: const Text('Saved Documents'),
      ),

      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Text(
                'Loading error: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'There are no saved documents...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const Divider(color: Colors.grey),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i];
              final addedOn = DateFormat(
                'dd MMM yyyy HH:mm',
              ).format(d.addedAt.toLocal());

              final isImage = d.type.startsWith('image/');

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading:
                    isImage
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            d.url,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(
                          Icons.insert_drive_file,
                          size: 40,
                          color: Colors.white70,
                        ),
                title: Text(
                  d.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  addedOn,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  if (isImage) {
                    // Aici definești comportamentul când dai tap pe o imagine.
                    // De exemplu, poți deschide imaginea fullscreen:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => ImageViewerScreen(
                              imageUrl: d.url,
                              filename: d.name,
                            ),
                      ),
                    );
                  } else {
                    // Dacă nu e imagine (deci e document), arată bottom sheet-ul:
                    _showAttachmentOptions(context, d.url, d.name);
                  }
                },
                // Dacă canDelete e false, nu afișăm butonul de ștergere
                trailing:
                    isOwnProfile
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Delete note?'),
                                    content: const Text(
                                      'Are you sure you want to delete this note?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (shouldDelete == true) {
                              final uid =
                                  ref.read(authViewModelProvider).user!.uid;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('journal_documents')
                                  .doc(d.id)
                                  .delete();
                            }
                          },
                        )
                        : null,
              );
            },
          );
        },
      ),
    );
  }
}
