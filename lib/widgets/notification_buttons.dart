import 'package:flutter/material.dart';

class NotificationButtons extends StatelessWidget {
  final VoidCallback onRandomTip;
  final VoidCallback onPersonalizedTip;

  const NotificationButtons({
    super.key,
    required this.onRandomTip,
    required this.onPersonalizedTip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRandomTip,
            icon: const Icon(Icons.shuffle),
            label: const Text('Random Tip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPersonalizedTip,
            icon: const Icon(Icons.person),
            label: const Text('Personalized'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
