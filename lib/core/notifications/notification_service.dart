import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/asset_constants.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String channelSoundId = 'kualiti_sound';
  static const String channelSilentId = 'kualiti_silent';

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to UTC if timezone detection fails
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    await _createNotificationChannels();
    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Sound channel (MP3 + Vibrate)
      const AndroidNotificationChannel soundChannel = AndroidNotificationChannel(
        channelSoundId,
        'Kualiti Sound Reminders',
        description: 'Notifications with custom cozy sound and vibration',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(
          AssetConstants.notificationSoundResource,
        ),
        enableVibration: true,
      );

      // Silent channel (Vibrate only)
      const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
        channelSilentId,
        'Kualiti Silent Reminders',
        description: 'Notifications with vibration only',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(soundChannel);
      await androidImplementation.createNotificationChannel(silentChannel);
    }
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required String body,
    required DateTime reminderDateTime,
    required bool useSound,
  }) async {
    await init();

    if (reminderDateTime.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      reminderDateTime,
      tz.local,
    );

    final String channelId = useSound ? channelSoundId : channelSilentId;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      useSound ? 'Kualiti Sound Reminders' : 'Kualiti Silent Reminders',
      channelDescription: 'Task reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      sound: useSound
          ? const RawResourceAndroidNotificationSound(
              AssetConstants.notificationSoundResource,
            )
          : null,
      playSound: useSound,
      enableVibration: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      taskId,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int taskId) async {
    await _notificationsPlugin.cancel(taskId);
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}
