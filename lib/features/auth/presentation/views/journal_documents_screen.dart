import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:renal_care_app/core/di/journal_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/data/models/journal_document_model.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/auth/presentation/widgets/note_viewer.dart';

class JournalDocumentsScreen extends ConsumerWidget {
  final String? userId;
  final bool canDelete;

  const JournalDocumentsScreen({super.key, this.userId, this.canDelete = true});

  Future<void> _openFileOrDocument(
    BuildContext context,
    JournalDocument d,
  ) async {
    if (d.type == 'text/plain') {
      // Dacă e notă text, afișează un ecran care conține textul notei
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => NoteViewer(
                // Ecran simplu pentru a vizualiza conținutul notei text
                title: d.name,
                textContent: d.url,
                addedAt: d.addedAt,
              ),
        ),
      );
    } else {
      // Dacă e un PDF sau o imagine externă: descarcă & deschide cu OpenFile
      try {
        final dir = await getTemporaryDirectory();
        final localPath = '${dir.path}/${p.basename(d.url)}';
        final file = File(localPath);
        if (!await file.exists()) {
          await Dio().download(d.url, localPath);
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
  }

  Future<void> _saveExternalFile(
    BuildContext context,
    JournalDocument d,
  ) async {
    // funcție refolosită pentru a salva PDF‐uri sau imagini
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download/RenalCare');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final filename = p.basename(d.url);
      final targetPath = p.join(downloadsDir.path, filename);
      await Dio().download(d.url, targetPath);
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

  void _showAttachmentOptions(BuildContext ctx, JournalDocument d) {
    showModalBottomSheet(
      context: ctx,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (d.type != 'text/plain') ...[
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openFileOrDocument(ctx, d);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Save'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _saveExternalFile(ctx, d);
                    },
                  ),
                ] else ...[
                  // dacă e notă text, oferim doar opțiunea „Vezi”
                  ListTile(
                    leading: const Icon(Icons.visibility),
                    title: const Text('See note'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openFileOrDocument(ctx, d);
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidToLoad = userId ?? ref.read(authViewModelProvider).user!.uid;
    final docsAsync = ref.watch(journalDocsForUserProvider(uidToLoad));

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
        title: const Text('Journal Documents'),
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
                'There are no saved journal texts...',
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
              final isPdf = d.type == 'application/pdf';

              Widget leadingWidget;
              if (d.type == 'text/plain') {
                // afișăm o iconiță specifică pentru note
                leadingWidget = const Icon(
                  Icons.note_alt,
                  size: 40,
                  color: Colors.white70,
                );
              } else if (isImage) {
                leadingWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    d.url,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                );
              } else if (isPdf) {
                leadingWidget = const Icon(
                  Icons.picture_as_pdf,
                  size: 40,
                  color: Colors.white70,
                );
              } else {
                leadingWidget = const Icon(
                  Icons.insert_drive_file,
                  size: 40,
                  color: Colors.white70,
                );
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: leadingWidget,
                title: Text(
                  d.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  addedOn,
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () => _showAttachmentOptions(context, d),
                trailing:
                    canDelete
                        ? IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          onPressed: () async {
                            // Șterge documentul din Firestore (/journal_documents)
                            final uid =
                                ref.read(authViewModelProvider).user!.uid;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('journal_documents')
                                .doc(d.id)
                                .delete();
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
