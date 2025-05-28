import 'package:flutter/material.dart';

class DrinkWaterInfoDialog extends StatelessWidget {
  const DrinkWaterInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('DRINK WATER'),
      content: const Text(
        'Drinking enough water every day is important for many reasons: '
        'it regulates body temperature and can keep joints supple, '
        'prevent infections, provide cells with nutrients and ensure that '
        'organs function better. Good hydration can also improve sleep '
        'quality, cognitive abilities and mood. So please take a sip of water.',
        style: TextStyle(fontSize: 16, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
