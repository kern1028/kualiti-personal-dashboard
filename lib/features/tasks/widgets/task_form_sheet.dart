import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskModel? taskToEdit;

  const TaskFormSheet({super.key, this.taskToEdit});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late TextEditingController _titleController;
  late int _priority; // 1, 2, 3
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late int _repeatType; // 0..4
  late int _remindBefore; // 0, 10, 60, 1440

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _priority = task?.priority ?? 2;

    if (task != null) {
      final parts = task.dueDate.split('-');
      _selectedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (task.hasTime && task.dueTime != null) {
        final tParts = task.dueTime!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(tParts[0]),
          minute: int.parse(tParts[1]),
        );
      } else {
        _selectedTime = null;
      }

      _repeatType = task.repeatType;
      _remindBefore = task.remindBefore;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = null;
      _repeatType = 0;
      _remindBefore = 0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final dueDateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final dueTimeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.taskToEdit != null) {
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        priority: _priority,
        dueDate: dueDateStr,
        dueTime: dueTimeStr,
        hasTime: _selectedTime != null,
        repeatType: _repeatType,
        remindBefore: _remindBefore,
      );
      provider.updateTask(updated);
    } else {
      final newTask = TaskModel(
        title: title,
        priority: _priority,
        dueDate: dueDateStr,
        dueTime: dueTimeStr,
        hasTime: _selectedTime != null,
        repeatType: _repeatType,
        remindBefore: _remindBefore,
        createdAt: DateTime.now().toIso8601String(),
      );
      provider.addTask(newTask);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius),
        ),
        border: Border.all(color: tokens.line, width: tokens.borderWidth),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: tokens.fontTitle,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tokens.ink,
              ),
              decoration: InputDecoration(
                hintText: l10n.taskTitle,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: tokens.inkMuted,
                  fontFamily: tokens.fontTitle,
                ),
              ),
              autofocus: widget.taskToEdit == null,
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Priority Selection
            Text(
              l10n.priority,
              style: TextStyle(
                fontFamily: tokens.fontTitle,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: tokens.inkMuted,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPriorityChip(1, l10n.priorityChill, tokens.priorityLow, tokens),
                const SizedBox(width: 8),
                _buildPriorityChip(2, l10n.priorityImportant, tokens.priorityMid, tokens),
                const SizedBox(width: 8),
                _buildPriorityChip(3, l10n.priorityCritical, tokens.priorityHigh, tokens),
              ],
            ),
            const SizedBox(height: 16),

            // Date & Optional Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.date,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                        ),
                      ),
                      child: Text(
                        DateTimeFormatter.formatDate(_selectedDate),
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          color: tokens.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.timeOptional,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                        ),
                      ),
                      child: Text(
                        _selectedTime != null
                            ? DateTimeFormatter.formatTime(
                                _selectedTime!.hour,
                                _selectedTime!.minute,
                              )
                            : '--:--',
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          color: tokens.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedTime != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: tokens.inkMuted, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedTime = null;
                      });
                    },
                  ),
              ],
            ),
            if (_selectedTime == null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.timeDefaultHint,
                style: TextStyle(
                  fontFamily: tokens.fontBody,
                  fontSize: 11,
                  color: tokens.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Repeat Options
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _repeatType,
                    decoration: InputDecoration(
                      labelText: l10n.repeat,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.repeatNever)),
                      DropdownMenuItem(value: 1, child: Text(l10n.repeatDaily)),
                      DropdownMenuItem(value: 2, child: Text(l10n.repeatWeekly)),
                      DropdownMenuItem(value: 3, child: Text(l10n.repeatMonthly)),
                      DropdownMenuItem(value: 4, child: Text(l10n.repeatYearly)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _repeatType = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _remindBefore,
                    decoration: InputDecoration(
                      labelText: l10n.remindMe,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.remindOnTime)),
                      DropdownMenuItem(value: 10, child: Text(l10n.remind10Min)),
                      DropdownMenuItem(value: 60, child: Text(l10n.remind1Hour)),
                      DropdownMenuItem(value: 1440, child: Text(l10n.remind1Day)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _remindBefore = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save / Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: tokens.inkMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radius),
                    ),
                  ),
                  onPressed: _saveTask,
                  child: Text(
                    l10n.save,
                    style: TextStyle(
                      fontFamily: tokens.fontTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
    int value,
    String label,
    Color color,
    ThemeTokens tokens,
  ) {
    final isSelected = _priority == value;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: tokens.fontBody,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : tokens.ink,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
        side: BorderSide(
          color: isSelected ? color : tokens.line,
          width: 1,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _priority = value;
        });
      },
    );
  }
}
