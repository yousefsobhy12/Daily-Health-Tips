import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/fcm_service.dart';
import 'profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _user;
  TimeOfDay? _notificationTime;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final user = await UserProfileService().loadUserProfile();
      final notificationTime = await UserProfileService()
          .loadNotificationTime();
      final notificationsEnabled = await UserProfileService()
          .loadNotificationsEnabled();

      setState(() {
        _user = user;
        _notificationTime =
            notificationTime ?? const TimeOfDay(hour: 9, minute: 0);
        _notificationsEnabled = notificationsEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationTime(TimeOfDay time) async {
    if (_user != null) {
      await UserProfileService().updateNotificationPreferences(
        userId: _user!.id,
        notificationTime: time,
      );
      await UserProfileService().saveNotificationTime(time);
      setState(() {
        _notificationTime = time;
      });
    }
  }

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    if (_user != null) {
      await UserProfileService().updateNotificationPreferences(
        userId: _user!.id,
        notificationsEnabled: enabled,
      );
      await UserProfileService().saveNotificationsEnabled(enabled);

      final fcmService = FCMService();
      if (enabled) {
        await fcmService.subscribeToPersonalizedTopic();
      } else {
        await fcmService.unsubscribeFromTopics();
      }

      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _notificationTime) {
      await _updateNotificationTime(picked);
    }
  }

  Future<void> _resetProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
          'Are you sure you want to reset your profile? This will clear all your settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await UserProfileService().deleteUserProfile();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('No user profile found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Profile Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Name'),
                  subtitle: Text(_user!.name),
                ),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Age'),
                  subtitle: Text('${_user!.age} years old'),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Health Goal'),
                  subtitle: Text(_capitalizeFirst(_user!.goal)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Settings
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive daily health tips'),
                  value: _notificationsEnabled,
                  onChanged: _updateNotificationsEnabled,
                  secondary: const Icon(Icons.notifications),
                ),
                if (_notificationsEnabled) ...[
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Notification Time'),
                    subtitle: Text(_notificationTime?.toString() ?? 'Not set'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _selectTime,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Information
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('About'),
                  subtitle: const Text(
                    'Daily Health Tips - Personalized wellness advice',
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Daily Health Tips',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.favorite,
                        color: Colors.green,
                      ),
                      children: const [
                        Text(
                          'Get personalized health tips based on your age and fitness goals.',
                        ),
                        SizedBox(height: 8),
                        Text('Features:'),
                        Text('• Personalized daily health tips'),
                        Text('• Customizable notification schedule'),
                        Text('• Age and goal-based recommendations'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Reset Profile',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Clear all settings and start over'),
              onTap: _resetProfile,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
