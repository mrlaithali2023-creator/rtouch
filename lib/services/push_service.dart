import 'package:flutter/foundation.dart';

Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {}

class PushService {
  PushService._();
  static final PushService instance = PushService._();
  Future<void> init() async {
    debugPrint('PushService: notifications disabled in this build');
  }
}

/// Top-level handler required by FCM for background/terminated messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: keep this lightweight.
  // The system tray notification is handled automatically by FCM when the
  // payload contains a `notification` block.
  debugPrint('BG message: ${message.messageId} ${message.notification?.title}');
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'rtouch_high_importance',
    'إشعارات Rtouch',
    description: 'إشعارات العروض والمنتجات الجديدة',
    importance: Importance.high,
  );

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission on Android 13+ / iOS.
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications init for foreground display.
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Subscribe all users to the broadcast topic so admins can blast notifs.
    try {
      await messaging.subscribeToTopic('all_users');
    } catch (e) {
      debugPrint('subscribeToTopic failed: $e');
    }

    // Print token for testing from Firebase console.
    final token = await messaging.getToken();
    debugPrint('FCM token: $token');

    // Foreground messages → show as a heads-up notification + add to in-app list.
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n != null) {
        _local.show(
          n.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        NotificationsService.instance.addRemote(
          title: n.title ?? 'إشعار',
          body: n.body ?? '',
        );
      }
    });

    // Tapping a notification while app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final n = m.notification;
      if (n != null) {
        NotificationsService.instance.addRemote(
          title: n.title ?? 'إشعار',
          body: n.body ?? '',
        );
      }
    });
  }
}
