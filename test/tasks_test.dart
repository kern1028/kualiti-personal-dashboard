import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/core/db/task_dao.dart';
import 'package:kualiti/features/tasks/models/task_model.dart';

void main() {
  group('TaskModel Test', () {
    test('Overdue calculation test', () {
      final pastTask = TaskModel(
        title: 'Past Task',
        dueDate: '2020-01-01',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(pastTask.isOverdue, true);

      final futureTask = TaskModel(
        title: 'Future Task',
        dueDate: '2030-01-01',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(futureTask.isOverdue, false);
    });

    test('Daily repeat calculation test', () {
      final task = TaskModel(
        title: 'Daily Task',
        dueDate: '2026-10-10',
        repeatType: 1, // Daily
        createdAt: DateTime.now().toIso8601String(),
      );

      final next = TaskDao.instance.calculateNextOccurrence(task);
      expect(next, isNotNull);
      expect(next!.dueDate, '2026-10-11');
    });

    test('Monthly repeat end of month test', () {
      final task = TaskModel(
        title: 'Monthly Task',
        dueDate: '2026-01-31',
        repeatType: 3, // Monthly
        createdAt: DateTime.now().toIso8601String(),
      );

      final next = TaskDao.instance.calculateNextOccurrence(task);
      expect(next, isNotNull);
      // Feb 2026 has 28 days
      expect(next!.dueDate, '2026-02-28');
    });
  });
}
