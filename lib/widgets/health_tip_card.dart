import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class HealthTipCard extends StatelessWidget {
  final HealthTip tip;
  final VoidCallback onRefresh;

  const HealthTipCard({super.key, required this.tip, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(tip.category),
                  color: _getCategoryColor(tip.category),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _capitalizeFirst(tip.category.replaceAll('_', ' ')),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getCategoryColor(tip.category),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              tip.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personalized for you',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Get another tip',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'nutrition':
        return Icons.restaurant;
      case 'exercise':
        return Icons.fitness_center;
      case 'mental_health':
        return Icons.psychology;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.favorite;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'nutrition':
        return Colors.orange;
      case 'exercise':
        return Colors.blue;
      case 'mental_health':
        return Colors.purple;
      case 'sleep':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
