import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/chat_providers.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/chat/domain/entities/patient_info.dart';

class PatientSearchBar extends ConsumerStatefulWidget {
  const PatientSearchBar({super.key});

  @override
  ConsumerState<PatientSearchBar> createState() => _PatientSearchBarState();
}

class _PatientSearchBarState extends ConsumerState<PatientSearchBar> {
  final _searchController = TextEditingController();
  List<PatientInfo> suggestions = [];
  bool _isSearching = false;

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      suggestions = [];
    });

    try {
      // apelează use-case-ul
      final results = await ref.read(searchPatientsUseCaseProvider).call(query);
      if (!mounted) return;
      setState(() => suggestions = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Eroare la căutare: $e')));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search for patient (email)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),

        // Lista de sugestii
        if (!_isSearching)
          ...suggestions.map(
            (p) => ListTile(
              title: Text(p.email),
              subtitle: p.name != null ? Text(p.name!) : null,
              onTap: () async {
                // async aici, cu mounted-check
                // crează room și apoi navighează /chat/:roomId
                final localContext = context;
                final doctorUid = ref.read(authViewModelProvider).user!.uid;

                try {
                  // Creează chat-ul
                  final room = await ref
                      .read(createChatRoomUseCaseProvider)
                      .call(doctorUid: doctorUid, patientUid: p.uid);

                  // Dacă widgetul mai există, golește câmpul și sugestiile
                  if (!localContext.mounted) return;
                  _searchController.clear();
                  setState(() => suggestions = []);

                  // Ascunde tastatura
                  FocusScope.of(context).unfocus();

                  // Navighează în chat
                  localContext.go('/chat/${room.id}');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nu s-a putut crea chat: $e')),
                    );
                  }
                }
              },
            ),
          ),
      ],
    );
  }
}
