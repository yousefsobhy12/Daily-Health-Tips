import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class WelcomeCard extends StatelessWidget {
  final UserProfile user;

  const WelcomeCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 48, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              'Hello, ${user.name}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Your Goal: ${_capitalizeFirst(user.goal)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
