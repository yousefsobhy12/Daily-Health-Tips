import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _userProfileKey = 'user_profile';

  Future<void> saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(user.toJson()));
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userProfileKey);
    if (userData != null) {
      return UserProfile.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile user) async {
    await saveUserProfile(user);
  }

  Future<UserProfile> createUserProfile({
    required String name,
    required int age,
    required String goal,
  }) async {
    final user = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      goal: goal,
    );
    await saveUserProfile(user);
    return user;
  }

  Future<void> updateFCMToken(String userId, String token) async {
    final user = await loadUserProfile();
    if (user != null && user.id == userId) {
      final updatedUser = user.copyWith(fcmToken: token);
      await saveUserProfile(updatedUser);
    }
  }

  Future<void> deleteUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  Future<bool> hasUserProfile() async {
    final user = await loadUserProfile();
    return user != null;
  }
}
