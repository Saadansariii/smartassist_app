import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotificatioins();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // request pesmission
    await _requestPermission();

    // setup message handlers
    await _setupMessageHandlers();

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token : $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);

    print('permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotificatioins() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup

    const channel = AndroidNotificationChannel(
        'high_importance_channel', 'High importance Channel',
        description: 'this channel is for importance notificaion.',
        importance: Importance.high);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

// icon notification
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios setup

    final InitializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // handle
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: InitializationSettingsDarwin,
    );

    // flutter notification setup

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'high importance channel', 'High Importance Channel',
                channelDescription:
                    'This Channel is used for importance notifications and more.',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher'),
            iOS: const DarwinNotificationDetails(
                presentAlert: true, presentBadge: true, presentSound: true)),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    // foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // background message

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      // open chat screen
    }
  }
}
