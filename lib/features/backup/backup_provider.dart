import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/db/app_database.dart';
import '../../core/db/task_dao.dart';
import '../../core/db/note_dao.dart';
import '../../core/db/link_dao.dart';

abstract class BackupProvider {
  Future<String> exportBackupData(String userName);
  Future<Map<String, dynamic>?> readBackupData(String jsonString);
  Future<bool> restoreBackupData(Map<String, dynamic> backupMap);
}

class LocalFileBackupProvider implements BackupProvider {
  @override
  Future<String> exportBackupData(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await TaskDao.instance.getAllTasks();
    final notes = await NoteDao.instance.getAllNotes();
    final links = await LinkDao.instance.getAllLinks();

    final backupData = {
      'app': 'kualiti',
      'schemaVersion': 1,
      'appVersion': '1.0.0',
      'createdAt': DateTime.now().toIso8601String(),
      'user': {
        'name': userName,
      },
      'settings': {
        'language': prefs.getString('selected_language') ?? 'system',
        'theme': prefs.getString('selected_theme') ?? 'defaultTheme',
        'dateFormat': prefs.getString('selected_date_format') ?? 'dmy',
        'is24Hour': prefs.getBool('is_24_hour_format') ?? true,
        'soundEnabled': prefs.getBool('sound_enabled') ?? true,
      },
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'notes': notes.map((n) => n.toMap()).toList(),
      'links': links.map((l) {
        final map = l.toMap();
        map.remove('icon_blob'); // Links icons are re-fetched offline
        return map;
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  @override
  Future<Map<String, dynamic>?> readBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> map = json.decode(jsonString);
      if (map['app'] != 'kualiti' || map['schemaVersion'] == null) {
        return null;
      }
      return map;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> restoreBackupData(Map<String, dynamic> backupMap) async {
    try {
      final db = await AppDatabase.instance.database;

      await db.transaction((txn) async {
        // Clear existing local data
        await txn.delete('tasks');
        await txn.delete('notes');
        await txn.delete('links');

        // Restore tasks
        if (backupMap['tasks'] is List) {
          for (final item in backupMap['tasks']) {
            await txn.insert('tasks', Map<String, dynamic>.from(item));
          }
        }

        // Restore notes
        if (backupMap['notes'] is List) {
          for (final item in backupMap['notes']) {
            await txn.insert('notes', Map<String, dynamic>.from(item));
          }
        }

        // Restore links
        if (backupMap['links'] is List) {
          for (final item in backupMap['links']) {
            await txn.insert('links', Map<String, dynamic>.from(item));
          }
        }
      });

      // Restore user & settings
      final prefs = await SharedPreferences.getInstance();
      if (backupMap['user'] != null && backupMap['user']['name'] != null) {
        await prefs.setString('user_name', backupMap['user']['name']);
      }

      if (backupMap['settings'] is Map) {
        final s = backupMap['settings'];
        if (s['language'] != null) await prefs.setString('selected_language', s['language']);
        if (s['theme'] != null) await prefs.setString('selected_theme', s['theme']);
        if (s['dateFormat'] != null) await prefs.setString('selected_date_format', s['dateFormat']);
        if (s['is24Hour'] != null) await prefs.setBool('is_24_hour_format', s['is24Hour']);
        if (s['soundEnabled'] != null) await prefs.setBool('sound_enabled', s['soundEnabled']);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static String sanitizeFileName(String userName) {
    final clean = userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (clean.isEmpty) return 'kualitibackup.json';
    return 'kualiti${clean}backup.json';
  }
}

class GoogleDriveBackupProvider implements BackupProvider {
  @override
  Future<String> exportBackupData(String userName) async {
    throw UnimplementedError('Google Drive backup is coming soon in v2.');
  }

  @override
  Future<Map<String, dynamic>?> readBackupData(String jsonString) async {
    throw UnimplementedError('Google Drive backup is coming soon in v2.');
  }

  @override
  Future<bool> restoreBackupData(Map<String, dynamic> backupMap) async {
    throw UnimplementedError('Google Drive backup is coming soon in v2.');
  }
}
