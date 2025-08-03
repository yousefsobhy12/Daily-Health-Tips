import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_profile.dart';
import 'health_tips_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  UserProfile? _currentUser;

  // Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestNotificationPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token (only if Firebase is initialized)
      try {
        _fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $_fcmToken');

        // Handle token refresh
        _firebaseMessaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          _updateUserFCMToken(token);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } catch (e) {
        print('Firebase not initialized, skipping FCM setup: $e');
      }
    } catch (e) {
      print('Error initializing FCM service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermission() async {
    try {
      // Request notification permission
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // Request additional permissions for Android
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await Permission.notification.request();
      }
    } catch (e) {
      print(
        'Firebase not available, requesting basic notification permission: $e',
      );
      // Fallback to basic permission request
      await Permission.notification.request();
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // You can perform background tasks here
  }

  // Handle notification tap when app is in background
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigate to specific screen based on message data
  }

  // Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'daily_health_tips',
          'Daily Health Tips',
          channelDescription: 'Channel for daily health tips notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  // Set current user
  void setCurrentUser(UserProfile user) {
    _currentUser = user;
    _updateUserFCMToken(_fcmToken);
  }

  // Update user's FCM token in database
  Future<void> _updateUserFCMToken(String? token) async {
    if (token != null && _currentUser != null) {
      // Update user profile with new FCM token
      _currentUser = _currentUser!.copyWith(fcmToken: token);
      // Here you would typically save this to your database
      print('Updated FCM token for user: ${_currentUser!.id}');
    }
  }

  // Get current FCM token
  String? get fcmToken => _fcmToken;

  // Get current user
  UserProfile? get currentUser => _currentUser;

  // Subscribe to topic for personalized notifications
  Future<void> subscribeToPersonalizedTopic() async {
    if (_currentUser != null) {
      try {
        // Subscribe to user-specific topic
        await _firebaseMessaging.subscribeToTopic('user_${_currentUser!.id}');

        // Subscribe to goal-specific topic
        await _firebaseMessaging.subscribeToTopic(
          'goal_${_currentUser!.goal.replaceAll(' ', '_')}',
        );

        // Subscribe to age group topic
        String ageGroup = _getAgeGroup(_currentUser!.age);
        await _firebaseMessaging.subscribeToTopic('age_$ageGroup');

        print(
          'Subscribed to personalized topics for user: ${_currentUser!.id}',
        );
      } catch (e) {
        print('Firebase not available, skipping topic subscription: $e');
      }
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopics() async {
    if (_currentUser != null) {
      try {
        await _firebaseMessaging.unsubscribeFromTopic(
          'user_${_currentUser!.id}',
        );
        await _firebaseMessaging.unsubscribeFromTopic(
          'goal_${_currentUser!.goal.replaceAll(' ', '_')}',
        );

        String ageGroup = _getAgeGroup(_currentUser!.age);
        await _firebaseMessaging.unsubscribeFromTopic('age_$ageGroup');

        print('Unsubscribed from topics for user: ${_currentUser!.id}');
      } catch (e) {
        print('Firebase not available, skipping topic unsubscription: $e');
      }
    }
  }

  // Get age group based on age
  String _getAgeGroup(int age) {
    if (age < 18) return 'under_18';
    if (age >= 18 && age <= 25) return '18_25';
    if (age >= 26 && age <= 35) return '26_35';
    if (age >= 36 && age <= 50) return '36_50';
    return '50_plus';
  }

  // Show test notification with random health tip
  Future<void> showTestNotification() async {
    // Get a random health tip
    final healthTipsService = HealthTipsService();
    final randomTip = healthTipsService.getRandomTip();

    await _showLocalNotificationWithTip(randomTip);
  }

  // Show personalized notification based on user profile
  Future<void> showPersonalizedNotification() async {
    if (_currentUser == null) {
      print('No current user set for personalized notification');
      return;
    }

    final healthTipsService = HealthTipsService();
    final personalizedTip = healthTipsService.getPersonalizedTip(_currentUser!);

    await _showLocalNotificationWithTip(personalizedTip);
  }

  // Helper method to show notification with health tip
  Future<void> _showLocalNotificationWithTip(HealthTip tip) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'daily_health_tips',
          'Daily Health Tips',
          channelDescription: 'Channel for daily health tips notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/
          1000, // Unique ID based on timestamp
      tip.title,
      tip.content,
      platformChannelSpecifics,
    );
  }
}
