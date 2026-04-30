import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _notifications.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'weather_channel',
      'Weather Notifications',
      description: 'Current weather updates and alerts',
      importance: Importance.high,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  static Future<bool> requestPermission() async {
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final bool? iosResult = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? androidResult =
        await androidPlugin?.requestNotificationsPermission();

    return iosResult ?? androidResult ?? true;
  }

  static Future<void> showWeatherNotification({
    required String city,
    required String temperature,
    required String description,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      channelDescription: 'Current weather updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      0,
      'Weather in $city',
      '$temperature - $description',
      details,
    );
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      channelDescription: 'Current weather updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      1,
      'Weather Notifications Enabled',
      'You will now receive weather updates.',
      details,
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
