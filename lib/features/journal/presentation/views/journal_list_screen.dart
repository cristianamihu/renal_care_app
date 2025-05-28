import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

import 'package:renal_care_app/features/journal/presentation/viewmodels/journal_viewmodel.dart';
import 'package:renal_care_app/features/journal/presentation/views/journal_entry_detail_screen.dart';
import 'package:renal_care_app/features/journal/presentation/views/journal_entry_form_screen.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  Color colorForLabel(String label) {
    switch (label) {
      case 'Emergency':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalViewModelProvider);

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
        title: const Text('Notes'),
      ),
      body: entriesAsync.when(
        loading: () => _EmptyNotesPlaceholder(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data:
            (entries) =>
                entries.isEmpty
                    ? _EmptyNotesPlaceholder()
                    : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) {
                        final e = entries[i];
                        return ListTile(
                          leading: _LabelDot(colorForLabel(e.label)),
                          title: Text(
                            e.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            e.timestamp.toLocal().toString().split('.')[0],
                          ),
                          onLongPress: () => _showOptions(context, ref, e),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => JournalEntryDetailScreen(entry: e),
                              ),
                            );
                          },
                        );
                      },
                    ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gradient3,
        icon: const Icon(Icons.add),
        label: const Text('Add a note'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JournalEntryFormScreen()),
          );
        },
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, e) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JournalEntryFormScreen(initial: e),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context, ref, e.id);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String entryId) {
    showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete note?'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(journalViewModelProvider.notifier).deleteEntry(entryId);
      }
    });
  }
}

class _EmptyNotesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Take notes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Document your symptoms, health events and any medical information of importance',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelDot extends StatelessWidget {
  final Color color;
  const _LabelDot(this.color);
  @override
  Widget build(BuildContext context) =>
      CircleAvatar(radius: 6, backgroundColor: color);
}
