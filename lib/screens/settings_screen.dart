import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../widgets/profile_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final user = await UserProfileService().loadUserProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationTime(TimeOfDay newTime) async {
    if (_user != null) {
      final now = DateTime.now();
      final notificationDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        newTime.hour,
        newTime.minute,
      );

      final updatedUser = _user!.copyWith(
        notificationTime: notificationDateTime,
      );
      await UserProfileService().saveUserProfile(updatedUser);
      setState(() {
        _user = updatedUser;
      });
    }
  }

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(notificationsEnabled: enabled);
      await UserProfileService().saveUserProfile(updatedUser);
      setState(() {
        _user = updatedUser;
      });
    }
  }

  Future<void> _selectTime() async {
    if (_user?.notificationTime != null) {
      final currentTime = TimeOfDay.fromDateTime(_user!.notificationTime!);
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );
      if (picked != null && picked != currentTime) {
        await _updateNotificationTime(picked);
      }
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
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(body: Center(child: Text('No user profile found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildResetSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProfileItem(label: 'Name', value: _user!.name, icon: Icons.person),
            ProfileItem(
              label: 'Age',
              value: '${_user!.age} years old',
              icon: Icons.cake,
            ),
            ProfileItem(
              label: 'Goal',
              value: _capitalizeFirst(_user!.goal),
              icon: Icons.fitness_center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive daily health tips'),
              value: _user!.notificationsEnabled,
              onChanged: _updateNotificationsEnabled,
              secondary: Icon(
                _user!.notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _user!.notificationsEnabled ? Colors.green : Colors.grey,
              ),
            ),
            if (_user!.notificationsEnabled) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Notification Time'),
                subtitle: Text(
                  _user!.notificationTime != null
                      ? 'Daily at ${TimeOfDay.fromDateTime(_user!.notificationTime!).format(context)}'
                      : 'Not set',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectTime,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset Profile'),
              subtitle: const Text('Clear all settings and start over'),
              onTap: _resetProfile,
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
