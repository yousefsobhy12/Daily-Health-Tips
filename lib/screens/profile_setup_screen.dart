import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/health_tips_service.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedAge = 25;
  String _selectedGoal = 'stay healthy';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _notificationsEnabled = true;

  final List<String> _availableGoals = HealthTipsService().getAvailableGoals();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final notificationDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final userProfile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: _selectedAge,
        goal: _selectedGoal,
        notificationTime: notificationDateTime,
        notificationsEnabled: _notificationsEnabled,
      );

      await UserProfileService().saveUserProfile(userProfile);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Daily Health Tips!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s personalize your experience',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAge,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                items: List.generate(83, (index) => index + 18).map((age) {
                  return DropdownMenuItem<int>(
                    value: age,
                    child: Text('$age years old'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAge = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                decoration: const InputDecoration(
                  labelText: 'Health Goal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                items: _availableGoals.map((goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(_capitalizeFirst(goal)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Notification Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Daily Notifications'),
                subtitle: const Text('Receive personalized health tips daily'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _notificationsEnabled ? Colors.green : Colors.grey,
                ),
              ),
              if (_notificationsEnabled) ...[
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Notification Time'),
                  subtitle: Text('Daily at ${_selectedTime.format(context)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectTime,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
