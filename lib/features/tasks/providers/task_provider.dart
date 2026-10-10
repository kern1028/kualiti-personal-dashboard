import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/db/task_dao.dart';
import '../../../core/notifications/notification_service.dart';
import '../models/task_model.dart';

enum TaskFilter { all, today, upcoming, done, repeating }
enum TaskSort { due, priority, az }

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.due;

  TaskModel? _lastDeletedTask;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await TaskDao.instance.getAllTasks();
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _sort = sort;
    notifyListeners();
  }

  List<TaskModel> get filteredAndSortedTasks {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    List<TaskModel> filtered = [];

    switch (_filter) {
      case TaskFilter.all:
        filtered = _tasks.where((t) => !t.done).toList();
        break;

      case TaskFilter.today:
        filtered = _tasks.where((t) => !t.done && (t.dueDate == todayStr || t.isOverdue)).toList();
        break;

      case TaskFilter.upcoming:
        filtered = _tasks.where((t) => !t.done && t.dueDate.compareTo(todayStr) > 0 && !t.isOverdue).toList();
        break;

      case TaskFilter.done:
        filtered = _tasks.where((t) => t.done).toList();
        break;

      case TaskFilter.repeating:
        filtered = _tasks.where((t) => !t.done && t.repeatType > 0).toList();
        break;
    }

    // Sort logic
    filtered.sort((a, b) {
      if (_filter == TaskFilter.today) {
        // In Today filter, overdue tasks come first
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
      }

      switch (_sort) {
        case TaskSort.due:
          final dueA = a.fullDueDateTime;
          final dueB = b.fullDueDateTime;
          return dueA.compareTo(dueB);

        case TaskSort.priority:
          return b.priority.compareTo(a.priority); // Highest first

        case TaskSort.az:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return filtered;
  }

  // Dashboard summary stats
  int get todayUncompletedCount {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _tasks.where((t) => !t.done && (t.dueDate == todayStr || t.isOverdue)).length;
  }

  TaskModel? get closestUpcomingTask {
    final uncompleted = _tasks.where((t) => !t.done).toList();
    if (uncompleted.isEmpty) return null;

    uncompleted.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      return a.fullDueDateTime.compareTo(b.fullDueDateTime);
    });

    return uncompleted.first;
  }

  Future<void> addTask(TaskModel task) async {
    final seriesId = task.repeatType > 0
        ? (task.seriesId ?? 'series_${DateTime.now().millisecondsSinceEpoch}')
        : null;

    final taskToInsert = task.copyWith(seriesId: seriesId);
    final id = await TaskDao.instance.insertTask(taskToInsert);
    final inserted = taskToInsert.copyWith(id: id);

    _tasks.insert(0, inserted);
    notifyListeners();

    await _scheduleNotificationForTask(inserted);
  }

  Future<void> updateTask(TaskModel task) async {
    await TaskDao.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }

    if (!task.done) {
      await _scheduleNotificationForTask(task);
    } else if (task.id != null) {
      await NotificationService.instance.cancelReminder(task.id!);
    }
  }

  Future<void> toggleTaskDone(TaskModel task) async {
    final nowDone = !task.done;
    final doneAt = nowDone ? DateTime.now().toIso8601String() : null;
    final updated = task.copyWith(done: nowDone, doneAt: doneAt);

    await TaskDao.instance.updateTask(updated);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updated;
    }

    if (task.id != null) {
      await NotificationService.instance.cancelReminder(task.id!);
    }

    // Handle repeating task auto-creation
    if (nowDone && task.repeatType > 0 && task.seriesId != null) {
      final hasActive = await TaskDao.instance.hasUncompletedSeriesTask(task.seriesId!);
      if (!hasActive) {
        final nextTask = TaskDao.instance.calculateNextOccurrence(task);
        if (nextTask != null) {
          final nextId = await TaskDao.instance.insertTask(nextTask);
          final insertedNext = nextTask.copyWith(id: nextId);
          _tasks.insert(0, insertedNext);
          await _scheduleNotificationForTask(insertedNext);
        }
      }
    }

    notifyListeners();
  }

  Future<void> deleteTask(TaskModel task) async {
    if (task.id == null) return;
    _lastDeletedTask = task;
    await TaskDao.instance.deleteTask(task.id!);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();

    await NotificationService.instance.cancelReminder(task.id!);
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask == null) return;
    final taskToRestore = _lastDeletedTask!;
    _lastDeletedTask = null;

    final id = await TaskDao.instance.insertTask(taskToRestore);
    final restored = taskToRestore.copyWith(id: id);
    _tasks.insert(0, restored);
    notifyListeners();

    if (!restored.done) {
      await _scheduleNotificationForTask(restored);
    }
  }

  Future<void> clearCompletedHistory() async {
    await TaskDao.instance.clearCompletedHistory();
    _tasks.removeWhere((t) => t.done);
    notifyListeners();
  }

  Future<void> _scheduleNotificationForTask(TaskModel task) async {
    if (task.id == null || task.done) return;

    final prefs = await SharedPreferences.getInstance();
    final useSound = prefs.getBool('sound_enabled') ?? true;

    final reminderTime = task.reminderDateTime;
    if (reminderTime.isAfter(DateTime.now())) {
      final dueInfo = task.hasTime && task.dueTime != null
          ? '${task.dueDate} ${task.dueTime}'
          : task.dueDate;

      await NotificationService.instance.scheduleTaskReminder(
        taskId: task.id!,
        title: task.title,
        body: dueInfo,
        reminderDateTime: reminderTime,
        useSound: useSound,
      );
    }
  }
}
