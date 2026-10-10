import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../../features/tasks/models/task_model.dart';

class TaskDao {
  static final TaskDao instance = TaskDao._internal();
  TaskDao._internal();

  Future<int> insertTask(TaskModel task) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<TaskModel?> getTaskById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> clearCompletedHistory() async {
    final db = await AppDatabase.instance.database;
    return await db.delete(
      'tasks',
      where: 'done = 1',
    );
  }

  Future<bool> hasUncompletedSeriesTask(String seriesId) async {
    final db = await AppDatabase.instance.database;
    final res = await db.query(
      'tasks',
      where: 'series_id = ? AND done = 0',
      whereArgs: [seriesId],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  TaskModel? calculateNextOccurrence(TaskModel task) {
    if (task.repeatType == 0) return null;

    final parts = task.dueDate.split('-');
    int currentYear = int.parse(parts[0]);
    int currentMonth = int.parse(parts[1]);
    int currentDay = int.parse(parts[2]);

    DateTime nextDate;

    switch (task.repeatType) {
      case 1: // Daily
        nextDate = DateTime(currentYear, currentMonth, currentDay).add(const Duration(days: 1));
        break;

      case 2: // Weekly
        final currentDt = DateTime(currentYear, currentMonth, currentDay);
        List<int> days = [currentDt.weekday];
        if (task.repeatDays != null && task.repeatDays!.isNotEmpty) {
          days = task.repeatDays!.split(',').map((e) => int.parse(e.trim())).toList()..sort();
        }
        
        int daysToAdd = 1;
        while (true) {
          final testDt = currentDt.add(Duration(days: daysToAdd));
          if (days.contains(testDt.weekday)) {
            nextDate = testDt;
            break;
          }
          daysToAdd++;
          if (daysToAdd > 14) {
            nextDate = currentDt.add(const Duration(days: 7));
            break;
          }
        }
        break;

      case 3: // Monthly
        int targetMonth = currentMonth + 1;
        int targetYear = currentYear;
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }
        // Handle 29th-31st: if month has fewer days, use last day of that month
        final lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        int targetDay = currentDay > lastDayOfTargetMonth ? lastDayOfTargetMonth : currentDay;
        nextDate = DateTime(targetYear, targetMonth, targetDay);
        break;

      case 4: // Yearly
        int targetYear = currentYear + 1;
        // Handle Feb 29 leap year to non-leap year
        final lastDayOfFeb = DateTime(targetYear, 3, 0).day;
        int targetDay = (currentMonth == 2 && currentDay == 29 && lastDayOfFeb == 28) ? 28 : currentDay;
        nextDate = DateTime(targetYear, currentMonth, targetDay);
        break;

      default:
        return null;
    }

    final formattedNextDate =
        '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

    // Check repeat_until
    if (task.repeatUntil != null && task.repeatUntil!.isNotEmpty) {
      if (formattedNextDate.compareTo(task.repeatUntil!) > 0) {
        return null; // Exceeded repeat_until limit
      }
    }

    return TaskModel(
      title: task.title,
      priority: task.priority,
      dueDate: formattedNextDate,
      dueTime: task.dueTime,
      hasTime: task.hasTime,
      repeatType: task.repeatType,
      repeatDays: task.repeatDays,
      repeatUntil: task.repeatUntil,
      remindBefore: task.remindBefore,
      done: false,
      doneAt: null,
      seriesId: task.seriesId ?? 'series_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
