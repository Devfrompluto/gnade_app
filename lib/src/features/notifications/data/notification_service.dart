import 'dart:convert';
import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Init local notifications for foreground display
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotifs.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // 3. Create Android Notification Channels
    await _createAndroidChannels();

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle Background/Terminated taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmTap);
    final initialMsg = await _fcm.getInitialMessage();
    if (initialMsg != null) {
      _handleFcmTap(initialMsg);
    }

    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final channels = [
      const AndroidNotificationChannel(
        'sales', 'Sales',
        description: 'New sale recorded',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'inventory', 'Inventory Alerts',
        description: 'Low stock and out of stock',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'expenses', 'Expenses',
        description: 'Expense logged',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'summary', 'Daily Summary',
        description: 'End-of-day report',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'general', 'General',
        description: 'General updates',
        importance: Importance.defaultImportance,
      ),
    ];

    final androidPlugin = _localNotifs.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground FCM: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;

    if (notification != null && android != null) {
      _localNotifs.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            data['channel'] ?? 'general',
            data['channel'] ?? 'General',
            icon: '@mipmap/launcher_icon',
            priority: Priority.high,
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromData(data);
      } catch (e) {
        AppLogger.error('Failed to parse local notification payload: $e');
      }
    }
  }

  void _handleFcmTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.push(route);
      }
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      AppLogger.error('Failed to get FCM token: $e');
      return null;
    }
  }
}
