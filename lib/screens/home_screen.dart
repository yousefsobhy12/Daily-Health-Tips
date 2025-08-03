import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/health_tips_service.dart';
import '../services/fcm_service.dart';
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
      // Set the current user for personalized notifications
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
              // Welcome Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, size: 48, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        'Hello, ${_user!.name}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Goal: ${_capitalizeFirst(_user!.goal)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Tip Section
              if (_currentTip != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(_currentTip!.category),
                              color: _getCategoryColor(_currentTip!.category),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _capitalizeFirst(
                                _currentTip!.category.replaceAll('_', ' '),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: _getCategoryColor(_currentTip!.category),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentTip!.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentTip!.content,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Personalized for you',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _refreshTip,
                              tooltip: 'Get another tip',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
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
                    child: _buildQuickActionCard(
                      icon: Icons.list,
                      title: 'More Tips',
                      subtitle: 'Browse all tips',
                      onTap: () {
                        // TODO: Navigate to tips list
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

              // Test Notification Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _testNotification,
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
                      onPressed: _testPersonalizedNotification,
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
              ),

              const SizedBox(height: 24),

              // Notification Status
              Card(
                child: ListTile(
                  leading: Icon(
                    _user!.notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _user!.notificationsEnabled
                        ? Colors.green
                        : Colors.grey,
                  ),
                  title: Text(
                    _user!.notificationsEnabled
                        ? 'Notifications Enabled'
                        : 'Notifications Disabled',
                  ),
                  subtitle: Text(
                    _user!.notificationsEnabled
                        ? 'You\'ll receive daily tips at ${_user!.notificationTime?.hour.toString().padLeft(2, '0')}:${_user!.notificationTime?.minute.toString().padLeft(2, '0')}'
                        : 'Enable notifications to get daily tips',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
