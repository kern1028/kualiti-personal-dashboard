import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_form_sheet.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  Color _getPriorityColor(ThemeTokens tokens) {
    switch (task.priority) {
      case 1:
        return tokens.priorityLow;
      case 3:
        return tokens.priorityHigh;
      case 2:
      default:
        return tokens.priorityMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final priorityColor = _getPriorityColor(tokens);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Dismissible(
      key: ValueKey('task_${task.id}_${task.createdAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: tokens.priorityHigh.withOpacity(0.15),
          borderRadius: BorderRadius.circular(tokens.radius),
        ),
        child: Icon(Icons.delete_outline_rounded, color: tokens.priorityHigh),
      ),
      onDismissed: (_) async {
        await taskProvider.deleteTask(task);

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('${l10n.deleted} - ${task.title}'),
              action: SnackBarAction(
                label: l10n.undo,
                textColor: tokens.accent,
                onPressed: () {
                  taskProvider.undoDelete();
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(color: tokens.line, width: tokens.borderWidth),
          boxShadow: tokens.isPixel
              ? [
                  BoxShadow(
                    color: tokens.line,
                    offset: const Offset(2, 2),
                  )
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radius),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskFormSheet(taskToEdit: task),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // Priority Strip / Indicator
                Container(
                  width: tokens.isPixel ? 10 : 8,
                  height: 28,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(
                      tokens.isPixel ? 0 : 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Checkbox
                GestureDetector(
                  onTap: () => taskProvider.toggleTaskDone(task),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: task.done ? tokens.accent : Colors.transparent,
                      shape: tokens.isPixel ? BoxShape.rectangle : BoxShape.circle,
                      border: Border.all(
                        color: task.done ? tokens.accent : tokens.inkMuted,
                        width: task.done ? 2 : 1.5,
                      ),
                    ),
                    child: task.done
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: tokens.onAccent,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Task details (Title, Due Date, Overdue badge, Repeat icon)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: task.done ? tokens.inkMuted : tokens.ink,
                          decoration: task.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (task.isOverdue) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.priorityHigh.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${l10n.overdue} (${task.getRelativeOverdueText(l10n, localeCode)})',
                                style: TextStyle(
                                  fontFamily: tokens.fontBody,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.priorityHigh,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ] else ...[
                            Text(
                              DateTimeFormatter.formatDate(task.fullDueDateTime) +
                                  (task.hasTime && task.dueTime != null
                                      ? ' ${task.dueTime}'
                                      : ''),
                              style: TextStyle(
                                fontFamily: tokens.fontBody,
                                fontSize: 12,
                                color: tokens.inkMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (task.repeatType > 0)
                            Icon(
                              Icons.repeat_rounded,
                              size: 13,
                              color: tokens.inkMuted,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
