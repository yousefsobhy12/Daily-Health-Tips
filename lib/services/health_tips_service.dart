import 'dart:math';
import '../models/user_profile.dart';

class HealthTipsService {
  static final HealthTipsService _instance = HealthTipsService._internal();
  factory HealthTipsService() => _instance;
  HealthTipsService._internal();

  final List<HealthTip> _healthTips = [
    HealthTip(
      id: '1',
      title: 'Stay Hydrated for Weight Loss',
      content:
          'Drink 8-10 glasses of water daily. Water helps boost metabolism and reduces hunger cravings.',
      targetGoals: ['lose weight'],
      targetAgeGroups: ['18_25', '26_35', '36_50', '50_plus'],
      category: 'nutrition',
    ),
    HealthTip(
      id: '2',
      title: 'High-Intensity Interval Training',
      content:
          'Try 20 minutes of HIIT workouts 3-4 times per week for maximum fat burning.',
      targetGoals: ['lose weight', 'get fit'],
      targetAgeGroups: ['18_25', '26_35', '36_50'],
      category: 'exercise',
    ),
    HealthTip(
      id: '3',
      title: 'Progressive Overload',
      content:
          'Gradually increase the weight or resistance in your strength training to build muscle effectively.',
      targetGoals: ['get fit'],
      targetAgeGroups: ['18_25', '26_35', '36_50', '50_plus'],
      category: 'exercise',
    ),
    HealthTip(
      id: '4',
      title: 'Protein-Rich Breakfast',
      content:
          'Start your day with 20-30g of protein to support muscle growth and recovery.',
      targetGoals: ['get fit'],
      targetAgeGroups: ['18_25', '26_35', '36_50'],
      category: 'nutrition',
    ),
    HealthTip(
      id: '5',
      title: 'Quality Sleep Matters',
      content:
          'Aim for 7-9 hours of quality sleep each night to support overall health and recovery.',
      targetGoals: ['stay healthy', 'lose weight', 'get fit'],
      targetAgeGroups: ['18_25', '26_35', '36_50', '50_plus'],
      category: 'sleep',
    ),
    HealthTip(
      id: '6',
      title: 'Mindful Eating',
      content:
          'Eat slowly and pay attention to your hunger cues. This helps prevent overeating.',
      targetGoals: ['stay healthy', 'lose weight'],
      targetAgeGroups: ['18_25', '26_35', '36_50', '50_plus'],
      category: 'nutrition',
    ),
    HealthTip(
      id: '7',
      title: 'Bone Health for Young Adults',
      content:
          'Build strong bones now with calcium-rich foods and weight-bearing exercises.',
      targetGoals: ['stay healthy', 'get fit'],
      targetAgeGroups: ['18_25', '26_35'],
      category: 'nutrition',
    ),
    HealthTip(
      id: '8',
      title: 'Heart Health Focus',
      content:
          'Include cardio exercises 3-5 times per week to maintain heart health.',
      targetGoals: ['stay healthy'],
      targetAgeGroups: ['36_50', '50_plus'],
      category: 'exercise',
    ),
    HealthTip(
      id: '9',
      title: 'Stress Management',
      content:
          'Practice 10 minutes of meditation or deep breathing daily to reduce stress.',
      targetGoals: ['stay healthy', 'lose weight', 'get fit'],
      targetAgeGroups: ['18_25', '26_35', '36_50', '50_plus'],
      category: 'mental_health',
    ),
    HealthTip(
      id: '10',
      title: 'Social Connection',
      content:
          'Maintain strong social connections - they\'re crucial for mental and physical health.',
      targetGoals: ['stay healthy'],
      targetAgeGroups: ['26_35', '36_50', '50_plus'],
      category: 'mental_health',
    ),
  ];

  HealthTip getPersonalizedTip(UserProfile user) {
    String ageGroup = _getAgeGroup(user.age);

    List<HealthTip> suitableTips = _healthTips.where((tip) {
      return tip.targetGoals.contains(user.goal) &&
          tip.targetAgeGroups.contains(ageGroup);
    }).toList();

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips.where((tip) {
        return tip.targetGoals.contains('stay healthy') &&
            tip.targetAgeGroups.contains(ageGroup);
      }).toList();
    }

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips.where((tip) {
        return tip.targetAgeGroups.contains(ageGroup);
      }).toList();
    }

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips;
    }

    suitableTips.shuffle();
    return suitableTips.first;
  }

  List<HealthTip> getPersonalizedTips(UserProfile user, int count) {
    String ageGroup = _getAgeGroup(user.age);

    List<HealthTip> suitableTips = _healthTips.where((tip) {
      return tip.targetGoals.contains(user.goal) &&
          tip.targetAgeGroups.contains(ageGroup);
    }).toList();

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips.where((tip) {
        return tip.targetGoals.contains('stay healthy') &&
            tip.targetAgeGroups.contains(ageGroup);
      }).toList();
    }

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips.where((tip) {
        return tip.targetAgeGroups.contains(ageGroup);
      }).toList();
    }

    if (suitableTips.isEmpty) {
      suitableTips = _healthTips;
    }

    suitableTips.shuffle();
    return suitableTips.take(count).toList();
  }

  List<HealthTip> getTipsByCategory(String category, UserProfile user) {
    String ageGroup = _getAgeGroup(user.age);

    return _healthTips.where((tip) {
      return tip.category == category &&
          tip.targetGoals.contains(user.goal) &&
          tip.targetAgeGroups.contains(ageGroup);
    }).toList();
  }

  String _getAgeGroup(int age) {
    if (age < 18) return 'under_18';
    if (age >= 18 && age <= 25) return '18_25';
    if (age >= 26 && age <= 35) return '26_35';
    if (age >= 36 && age <= 50) return '36_50';
    return '50_plus';
  }

  List<String> getAvailableGoals() {
    Set<String> goals = {};
    for (var tip in _healthTips) {
      goals.addAll(tip.targetGoals);
    }
    return goals.toList();
  }

  List<String> getAvailableCategories() {
    Set<String> categories = {};
    for (var tip in _healthTips) {
      categories.add(tip.category);
    }
    return categories.toList();
  }

  HealthTip getRandomTip() {
    final random = Random();
    return _healthTips[random.nextInt(_healthTips.length)];
  }
}
