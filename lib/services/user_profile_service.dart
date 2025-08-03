import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static const String _userProfileKey = 'user_profile';
  static const String _notificationTimeKey = 'notification_time';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Save user profile to local storage
  Future<void> saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(user.toJson()));
  }

  // Load user profile from local storage
  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userProfileKey);

    if (userData != null) {
      try {
        return UserProfile.fromJson(json.decode(userData));
      } catch (e) {
        print('Error loading user profile: $e');
        return null;
      }
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile user) async {
    await saveUserProfile(user);
  }

  // Save notification time preference
  Future<void> saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeData = {'hour': time.hour, 'minute': time.minute};
    await prefs.setString(_notificationTimeKey, json.encode(timeData));
  }

  // Load notification time preference
  Future<TimeOfDay?> loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeData = prefs.getString(_notificationTimeKey);

    if (timeData != null) {
      try {
        final data = json.decode(timeData);
        return TimeOfDay(hour: data['hour'], minute: data['minute']);
      } catch (e) {
        print('Error loading notification time: $e');
        return null;
      }
    }
    return null;
  }

  // Save notifications enabled preference
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Load notifications enabled preference
  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // Create a new user profile
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
      notificationsEnabled: true,
    );

    await saveUserProfile(user);
    return user;
  }

  // Update user's FCM token
  Future<void> updateFCMToken(String userId, String fcmToken) async {
    final user = await loadUserProfile();
    if (user != null && user.id == userId) {
      final updatedUser = user.copyWith(fcmToken: fcmToken);
      await saveUserProfile(updatedUser);
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    TimeOfDay? notificationTime,
    bool? notificationsEnabled,
  }) async {
    final user = await loadUserProfile();
    if (user != null && user.id == userId) {
      DateTime? time;
      if (notificationTime != null) {
        final now = DateTime.now();
        time = DateTime(
          now.year,
          now.month,
          now.day,
          notificationTime.hour,
          notificationTime.minute,
        );
      }

      final updatedUser = user.copyWith(
        notificationTime: time,
        notificationsEnabled: notificationsEnabled ?? user.notificationsEnabled,
      );

      await saveUserProfile(updatedUser);

      if (notificationTime != null) {
        await saveNotificationTime(notificationTime);
      }

      if (notificationsEnabled != null) {
        await saveNotificationsEnabled(notificationsEnabled);
      }
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_notificationTimeKey);
    await prefs.remove(_notificationsEnabledKey);
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    final user = await loadUserProfile();
    return user != null;
  }

  // Get user's notification time as DateTime for today
  Future<DateTime?> getNotificationDateTime() async {
    final user = await loadUserProfile();
    final notificationTime = await loadNotificationTime();

    if (user != null && notificationTime != null && user.notificationsEnabled) {
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      );
    }
    return null;
  }
}
