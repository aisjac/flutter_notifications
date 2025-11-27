import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'home_screen.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // 1. TIMEZONE SETUP
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    // 2. ANDROID 13+ NOTIFICATION PERMISSION (BEFORE INITIALIZE)
    if (await Permission.notification.isDenied ||
        await Permission.notification.isRestricted) {
      await Permission.notification.request();
    }

    // 3. INITIALIZATION SETTINGS
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Store the notification data globally when a notification is tapped
        if (response.payload != null) {
          final parts = response.payload!.split('|');
          NotificationData.title = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
          NotificationData.body = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;

          print('Notification tapped: ${NotificationData.title} - ${NotificationData.body}');
        }
      },
    );

    // Request active notifications to update NotificationData if app was launched from notification
    final activeNotifications = await notificationsPlugin.getActiveNotifications();
    if (activeNotifications.isNotEmpty) {
      final notification = activeNotifications.first;
      NotificationData.title = notification.title;
      NotificationData.body = notification.body;
      print('Active notification found: ${notification.title}');
    }

    _isInitialized = true;
  }

  // NOTIFICATION CHANNEL DETAILS - USING DEFAULT SOUND
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "default_channel_id",
        "Standard Notifications",
        channelDescription: "Regular notifications with default sound",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        // Using azan from raw resources
        enableVibration: true,
        channelShowBadge: true,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: 'azan.mp3', // iOS sound filename
      ),
    );
  }

  // Enhanced full screen notification details - USING DEFAULT SOUND
  NotificationDetails fullScreenNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "fullscreen_channel_id",
        "Fullscreen Notifications",
        channelDescription: "Important notifications that appear full screen",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        // Using azan from raw resources
        enableVibration: true,
        channelShowBadge: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.call,
        // Changed from alarm to call
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: 'azan.mp3', // iOS sound filename
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // IMMEDIATE NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    final payload = '${title ?? ""}|${body ?? ""}';

    // First update the NotificationData so it's available immediately
    NotificationData.title = title;
    NotificationData.body = body;

    // Then show the notification
    await notificationsPlugin.show(id, title, body, notificationDetails(), payload: payload);
  }

  // IMMEDIATE FULL SCREEN NOTIFICATION
  Future<void> showFullScreenNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    final payload = '${title ?? ""}|${body ?? ""}';

    // First update the NotificationData so it's available immediately
    NotificationData.title = title;
    NotificationData.body = body;

    // Then show the notification
    await notificationsPlugin.show(
        id, title, body, fullScreenNotificationDetails(), payload: payload);
  }

  // SCHEDULED DAILY NOTIFICATION
  Future<void> scheduleNotification({
    int id = 1,
    required String? title,
    required String? body,
    required DateTime scheduledDateTime,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Convert DateTime to TZDateTime
    var scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDateTime.year,
      scheduledDateTime.month,
      scheduledDateTime.day,
      scheduledDateTime.hour,
      scheduledDateTime.minute,
    );

    // If the time already passed u2192 schedule tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final payload = '${title ?? ""}|${body ?? ""}';
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );

    print("Notification scheduled at $scheduledDate");
  }

  // SCHEDULED DAILY FULL SCREEN NOTIFICATION
  Future<void> scheduleFullScreenNotification({
    int id = 1,
    required String? title,
    required String? body,
    required DateTime scheduledDateTime,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Convert DateTime to TZDateTime
    var scheduledDate = tz.TZDateTime(
      tz.local,
      scheduledDateTime.year,
      scheduledDateTime.month,
      scheduledDateTime.day,
      scheduledDateTime.hour,
      scheduledDateTime.minute,
    );

    // If the time already passed u2192 schedule tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final payload = '${title ?? ""}|${body ?? ""}';
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      fullScreenNotificationDetails(),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );

    print("Full screen notification scheduled at $scheduledDate");
  }

  Future<void> cancelAllNotification() async {
    await notificationsPlugin.cancelAll();
  }
}