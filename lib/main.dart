import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/db/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/utils/date_time_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
    debugPrint('SystemUiOverlayStyle init error: $e');
  }

  // Initialize central date & time formatting preferences
  try {
    await DateTimeFormatter.init();
  } catch (e) {
    debugPrint('DateTimeFormatter init error: $e');
  }

  // Initialize SQLite database instance
  try {
    await AppDatabase.instance.database;
  } catch (e) {
    debugPrint('AppDatabase init error: $e');
  }

  // Initialize Notification Service
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  runApp(const KualitiApp());
}
