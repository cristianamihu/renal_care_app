import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

import 'package:renal_care_app/features/journal/domain/entities/journal_entry.dart';
import 'package:renal_care_app/features/journal/presentation/viewmodels/journal_viewmodel.dart';

class JournalEntryFormScreen extends ConsumerStatefulWidget {
  final JournalEntry? initial;
  const JournalEntryFormScreen({super.key, this.initial});

  @override
  ConsumerState<JournalEntryFormScreen> createState() => _FormState();
}

class _FormState extends ConsumerState<JournalEntryFormScreen> {
  late final TextEditingController _controller;
  late String _selectedLabel;
  final List<String> _labels = ['General', 'Emergency'];

  @override
  void initState() {
    super.initState();
    final entry = widget.initial;
    _controller = TextEditingController(text: entry?.text ?? '');
    _selectedLabel = entry?.label ?? _labels.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color colorForLabel(String l) {
    switch (l) {
      case 'Emergency':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  Future<void> _onDone() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final vm = ref.read(journalViewModelProvider.notifier);
    if (widget.initial == null) {
      await vm.addEntry(text, _selectedLabel);
    } else {
      await vm.updateEntry(widget.initial!, text, _selectedLabel);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('dd MMM yyyy, HH:mm', 'ro').format(DateTime.now());
    final isEditing = widget.initial != null;

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
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Label', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 6,
                  backgroundColor: colorForLabel(_selectedLabel),
                ),
                const SizedBox(width: 8),
                Text(_selectedLabel, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Time: $now', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 24),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose label:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children:
                  _labels.map((l) {
                    final isSel = l == _selectedLabel;
                    final col = colorForLabel(l);
                    return ChoiceChip(
                      label: Text(l),
                      selected: isSel,
                      selectedColor: col,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: isSel ? col : Colors.grey),
                      onSelected: (_) => setState(() => _selectedLabel = l),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradient3,
              ),
              onPressed: _onDone,
              child: Text(isEditing ? 'UPDATE' : 'DONE'),
            ),
          ),
        ),
      ),
    );
  }
}
