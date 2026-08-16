import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/citizen/application_detail_screen.dart';

/// Top-level background handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handling
  // ignore: avoid_print
  print('[NotificationService] Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  String? _pendingApplicationId;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important application status notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Get and reset pending application ID
  String? consumePendingApplicationId() {
    final id = _pendingApplicationId;
    _pendingApplicationId = null;
    return id;
  }

  /// Trigger navigation if a pending notification click exists
  void checkAndConsumePendingNavigation() {
    final id = consumePendingApplicationId();
    if (id != null && id.isNotEmpty) {
      // Delay slightly to ensure dashboard shell / route is fully mounted
      Future.delayed(const Duration(milliseconds: 300), () {
        navigateToApplication(id);
      });
    }
  }

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request Notification Permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // ignore: avoid_print
      print('[NotificationService] User notification permission status: ${settings.authorizationStatus}');

      // 3. Configure Android Local Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 4. Initialize Local Notifications Plugin
      const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            _handlePayloadString(payload);
          }
        },
      );

      // 5. Configure Foreground Notification Options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Listen for Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('[NotificationService] Foreground message received: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // 7. Listen for Background Tap Events (App opened from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // ignore: avoid_print
        print('[NotificationService] Notification opened from background: ${message.data}');
        _handleMessageNavigation(message);
      });

      // 8. Check for Terminated App Launch (App launched from notification click)
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        // ignore: avoid_print
        print('[NotificationService] App launched from terminated state via notification: ${initialMessage.data}');
        _handleMessageNavigation(initialMessage);
      }

      // 9. Listen for Token Refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        // ignore: avoid_print
        print('[NotificationService] FCM token refreshed: $newToken');
        syncTokenWithBackend(newToken);
      });

      _isInitialized = true;
      // ignore: avoid_print
      print('[NotificationService] Initialized successfully.');
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] Initialization error: $e');
    }
  }

  /// Sync device FCM token to Supabase profiles.fcm_token
  Future<void> syncTokenWithBackend([String? token]) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // ignore: avoid_print
        print('[NotificationService] No authenticated user. Skipping token sync.');
        return;
      }

      final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        // ignore: avoid_print
        print('[NotificationService] Unable to obtain FCM token.');
        return;
      }

      // ignore: avoid_print
      print('[NotificationService] Syncing FCM token with Supabase profile: ${user.id}');
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': fcmToken})
          .eq('id', user.id);

      // ignore: avoid_print
      print('[NotificationService] FCM token synced successfully.');
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] Error syncing FCM token: $e');
    }
  }

  /// Display a heads-up local notification when received in foreground
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Nyaya Saathi';
    final body = notification?.body ?? message.data['body'] ?? '';

    final payload = jsonEncode(message.data);

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: const Color(0xFF083EA7),
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Handle message navigation when notification is tapped
  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    String? applicationId = data['application_id']?.toString() ??
        data['applicationId']?.toString() ??
        data['tracking_number']?.toString();

    if (applicationId == null || applicationId.isEmpty) {
      // Try to extract tracking number from message body/title
      final text = '${message.notification?.title ?? ''} ${message.notification?.body ?? ''}';
      final match = RegExp(r'(?:SK|LA|APP)-[A-Za-z0-9-]+').firstMatch(text);
      if (match != null) {
        applicationId = match.group(0);
      }
    }

    if (applicationId != null && applicationId.isNotEmpty) {
      navigateToApplication(applicationId);
    }
  }

  void _handlePayloadString(String payloadString) {
    try {
      final data = jsonDecode(payloadString) as Map<String, dynamic>;
      String? applicationId = data['application_id']?.toString() ??
          data['applicationId']?.toString() ??
          data['tracking_number']?.toString();

      if (applicationId != null && applicationId.isNotEmpty) {
        navigateToApplication(applicationId);
        return;
      }
    } catch (_) {}

    // Fallback if payload is plain applicationId string
    if (payloadString.isNotEmpty) {
      navigateToApplication(payloadString);
    }
  }

  /// Open Application Details screen by application ID or tracking number
  void navigateToApplication(String applicationId) {
    final cleanId = applicationId.trim();
    if (cleanId.isEmpty) return;

    final nav = navigatorKey.currentState;
    if (nav == null) {
      // ignore: avoid_print
      print('[NotificationService] NavigatorState not ready yet. Queuing pending application ID: $cleanId');
      _pendingApplicationId = cleanId;
      return;
    }

    try {
      nav.push(
        MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(applicationId: cleanId),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[NotificationService] Error navigating to application details: $e');
    }
  }
}

