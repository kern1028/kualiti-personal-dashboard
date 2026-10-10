import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/db/app_database.dart';
import 'core/utils/date_time_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize central date & time formatting preferences
  await DateTimeFormatter.init();

  // Initialize SQLite database instance
  await AppDatabase.instance.database;

  runApp(const KualitiApp());
}
