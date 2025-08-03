import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class NotificationStatus extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;

  const NotificationStatus({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          user.notificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: user.notificationsEnabled ? Colors.green : Colors.grey,
        ),
        title: Text(
          user.notificationsEnabled
              ? 'Notifications Enabled'
              : 'Notifications Disabled',
        ),
        subtitle: Text(
          user.notificationsEnabled
              ? 'You\'ll receive daily tips at ${user.notificationTime?.hour.toString().padLeft(2, '0')}:${user.notificationTime?.minute.toString().padLeft(2, '0')}'
              : 'Enable notifications to get daily tips',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
