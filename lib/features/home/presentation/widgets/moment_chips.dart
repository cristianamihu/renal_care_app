import 'package:flutter/material.dart';

/// Un set de ChoiceChip-uri pentru momentele zilei
class MomentChips extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;
  const MomentChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const List<String> _moments = [
    'Dimineața',
    'După micul dejun',
    'Înainte de prânz',
    'După prânz',
    'După cină',
    'Seara',
    'Noaptea',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
          _moments.map((label) {
            final isSelected = label == selected;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(label),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
    );
  }
}
