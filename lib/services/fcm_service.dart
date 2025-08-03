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

  Future<void> initialize() async {
    try {
      await _requestNotificationPermission();
      await _initializeLocalNotifications();

      try {
        _fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $_fcmToken');

        _firebaseMessaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          _updateUserFCMToken(token);
        });

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } catch (e) {
        print('Firebase not initialized, skipping FCM setup: $e');
      }
    } catch (e) {
      print('Error initializing FCM service: $e');
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
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

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await Permission.notification.request();
      }
    } catch (e) {
      print(
        'Firebase not available, requesting basic notification permission: $e',
      );
      await Permission.notification.request();
    }
  }

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

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
  }

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

  void setCurrentUser(UserProfile user) {
    _currentUser = user;
    _updateUserFCMToken(_fcmToken);
  }

  Future<void> _updateUserFCMToken(String? token) async {
    if (token != null && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(fcmToken: token);
      print('Updated FCM token for user: ${_currentUser!.id}');
    }
  }

  String? get fcmToken => _fcmToken;
  UserProfile? get currentUser => _currentUser;

  Future<void> subscribeToPersonalizedTopic() async {
    if (_currentUser != null) {
      try {
        await _firebaseMessaging.subscribeToTopic('user_${_currentUser!.id}');
        await _firebaseMessaging.subscribeToTopic(
          'goal_${_currentUser!.goal.replaceAll(' ', '_')}',
        );

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

  String _getAgeGroup(int age) {
    if (age < 18) return 'under_18';
    if (age >= 18 && age <= 25) return '18_25';
    if (age >= 26 && age <= 35) return '26_35';
    if (age >= 36 && age <= 50) return '36_50';
    return '50_plus';
  }

  Future<void> showTestNotification() async {
    final healthTipsService = HealthTipsService();
    final randomTip = healthTipsService.getRandomTip();
    await _showLocalNotificationWithTip(randomTip);
  }

  Future<void> showPersonalizedNotification() async {
    if (_currentUser == null) {
      print('No current user set for personalized notification');
      return;
    }

    final healthTipsService = HealthTipsService();
    final personalizedTip = healthTipsService.getPersonalizedTip(_currentUser!);
    await _showLocalNotificationWithTip(personalizedTip);
  }

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
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      tip.title,
      tip.content,
      platformChannelSpecifics,
    );
  }
}
