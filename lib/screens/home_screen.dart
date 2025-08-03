import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/health_tips_service.dart';
import '../services/fcm_service.dart';
import '../widgets/welcome_card.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/notification_buttons.dart';
import '../widgets/notification_status.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _user;
  HealthTip? _currentTip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndTip();
  }

  Future<void> _loadUserAndTip() async {
    try {
      final user = await UserProfileService().loadUserProfile();
      if (user != null) {
        final tip = HealthTipsService().getPersonalizedTip(user);
        setState(() {
          _user = user;
          _currentTip = tip;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTip() async {
    if (_user != null) {
      final tip = HealthTipsService().getPersonalizedTip(_user!);
      setState(() {
        _currentTip = tip;
      });
    }
  }

  Future<void> _testNotification() async {
    try {
      final fcmService = FCMService();
      await fcmService.showTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Random health tip notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testPersonalizedNotification() async {
    try {
      final fcmService = FCMService();
      fcmService.setCurrentUser(_user!);
      await fcmService.showPersonalizedNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personalized health tip notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending personalized notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Daily Health Tips'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTip,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeCard(user: _user!),
              const SizedBox(height: 24),
              if (_currentTip != null)
                HealthTipCard(tip: _currentTip!, onRefresh: _refreshTip),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'Manage preferences',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.list,
                      title: 'More Tips',
                      subtitle: 'Browse all tips',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('More tips feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NotificationButtons(
                onRandomTip: _testNotification,
                onPersonalizedTip: _testPersonalizedNotification,
              ),
              const SizedBox(height: 24),
              NotificationStatus(
                user: _user!,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
