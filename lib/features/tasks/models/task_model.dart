import 'package:intl/intl.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/date_time_formatter.dart';

class TaskModel {
  final int? id;
  final String title;
  final int priority; // 1: Santai, 2: Penting, 3: Sangat Penting
  final String dueDate; // YYYY-MM-DD
  final String? dueTime; // HH:mm
  final bool hasTime;
  final int repeatType; // 0: none, 1: daily, 2: weekly, 3: monthly, 4: yearly
  final String? repeatDays; // e.g. "1,3,5"
  final String? repeatUntil; // YYYY-MM-DD
  final int remindBefore; // 0, 10, 60, 1440
  final bool done;
  final String? doneAt; // ISO string
  final String? seriesId;
  final String createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.priority = 2,
    required this.dueDate,
    this.dueTime,
    this.hasTime = false,
    this.repeatType = 0,
    this.repeatDays,
    this.repeatUntil,
    this.remindBefore = 0,
    this.done = false,
    this.doneAt,
    this.seriesId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'priority': priority,
      'due_date': dueDate,
      'due_time': dueTime,
      'has_time': hasTime ? 1 : 0,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
      'repeat_until': repeatUntil,
      'remind_before': remindBefore,
      'done': done ? 1 : 0,
      'done_at': doneAt,
      'series_id': seriesId,
      'created_at': createdAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      priority: map['priority'] as int? ?? 2,
      dueDate: map['due_date'] as String,
      dueTime: map['due_time'] as String?,
      hasTime: (map['has_time'] as int? ?? 0) == 1,
      repeatType: map['repeat_type'] as int? ?? 0,
      repeatDays: map['repeat_days'] as String?,
      repeatUntil: map['repeat_until'] as String?,
      remindBefore: map['remind_before'] as int? ?? 0,
      done: (map['done'] as int? ?? 0) == 1,
      doneAt: map['done_at'] as String?,
      seriesId: map['series_id'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    int? priority,
    String? dueDate,
    String? dueTime,
    bool? hasTime,
    int? repeatType,
    String? repeatDays,
    String? repeatUntil,
    int? remindBefore,
    bool? done,
    String? doneAt,
    String? seriesId,
    String? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      hasTime: hasTime ?? this.hasTime,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatUntil: repeatUntil ?? this.repeatUntil,
      remindBefore: remindBefore ?? this.remindBefore,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      seriesId: seriesId ?? this.seriesId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  DateTime get fullDueDateTime {
    final parts = dueDate.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    int hour = 9;
    int minute = 0;
    if (hasTime && dueTime != null && dueTime!.contains(':')) {
      final tParts = dueTime!.split(':');
      hour = int.parse(tParts[0]);
      minute = int.parse(tParts[1]);
    }

    return DateTime(year, month, day, hour, minute);
  }

  DateTime get reminderDateTime {
    return fullDueDateTime.subtract(Duration(minutes: remindBefore));
  }

  bool get isOverdue {
    if (done) return false;
    final now = DateTime.now();
    return fullDueDateTime.isBefore(now);
  }

  String getRelativeOverdueText(AppLocalizations l10n, String locale) {
    if (!isOverdue) return '';
    final now = DateTime.now();
    final due = fullDueDateTime;
    final difference = now.difference(due);

    final isYesterday = now.day - due.day == 1 &&
        now.month == due.month &&
        now.year == due.year;

    if (isYesterday) {
      if (hasTime) {
        return '${l10n.yesterday} ${DateTimeFormatter.formatTime(due.hour, due.minute)}';
      }
      return l10n.yesterday;
    }

    if (difference.inDays >= 1) {
      return '${difference.inDays} ${l10n.daysAgo}';
    }

    if (hasTime) {
      return DateTimeFormatter.formatTime(due.hour, due.minute);
    }
    return l10n.overdue;
  }
}
