import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _openAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(l10n.navTasks),
        backgroundColor: tokens.bg,
        actions: [
          PopupMenuButton<TaskSort>(
            icon: Icon(Icons.sort_rounded, color: tokens.ink),
            tooltip: 'Sort',
            onSelected: (sort) => taskProvider.setSort(sort),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskSort.due,
                child: Row(
                  children: [
                    if (taskProvider.sort == TaskSort.due)
                      Icon(Icons.check, size: 18, color: tokens.accent),
                    const SizedBox(width: 8),
                    Text(l10n.sortDue),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSort.priority,
                child: Row(
                  children: [
                    if (taskProvider.sort == TaskSort.priority)
                      Icon(Icons.check, size: 18, color: tokens.accent),
                    const SizedBox(width: 8),
                    Text(l10n.sortPriority),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSort.az,
                child: Row(
                  children: [
                    if (taskProvider.sort == TaskSort.az)
                      Icon(Icons.check, size: 18, color: tokens.accent),
                    const SizedBox(width: 8),
                    Text(l10n.sortAlphabetical),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip(TaskFilter.all, l10n.filterAll, taskProvider, tokens),
                const SizedBox(width: 8),
                _buildFilterChip(TaskFilter.today, l10n.filterToday, taskProvider, tokens),
                const SizedBox(width: 8),
                _buildFilterChip(TaskFilter.upcoming, l10n.filterUpcoming, taskProvider, tokens),
                const SizedBox(width: 8),
                _buildFilterChip(TaskFilter.done, l10n.filterDone, taskProvider, tokens),
                const SizedBox(width: 8),
                _buildFilterChip(TaskFilter.repeating, l10n.filterRepeating, taskProvider, tokens),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main Tasks List or Empty State
          Expanded(
            child: taskProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: tokens.accent),
                  )
                : _buildTaskList(context, taskProvider, tokens, l10n),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.accent,
        foregroundColor: tokens.onAccent,
        elevation: tokens.isPixel ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius),
          side: tokens.isPixel
              ? BorderSide(color: tokens.line, width: tokens.borderWidth)
              : BorderSide.none,
        ),
        onPressed: () => _openAddTaskSheet(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(
    TaskFilter filterOption,
    String label,
    TaskProvider provider,
    ThemeTokens tokens,
  ) {
    final isSelected = provider.filter == filterOption;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: tokens.fontBody,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? tokens.onAccent : tokens.ink,
        ),
      ),
      selected: isSelected,
      selectedColor: tokens.accent,
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
        side: BorderSide(
          color: isSelected ? tokens.accent : tokens.line,
          width: tokens.borderWidth,
        ),
      ),
      onSelected: (_) => provider.setFilter(filterOption),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    TaskProvider provider,
    ThemeTokens tokens,
    AppLocalizations l10n,
  ) {
    final list = provider.filteredAndSortedTasks;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 48,
              color: tokens.inkMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emptyState,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 14,
                color: tokens.inkMuted,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.accent,
                side: BorderSide(color: tokens.accent),
              ),
              onPressed: () => _openAddTaskSheet(context),
              child: Text(l10n.add),
            ),
          ],
        ),
      );
    }

    // Special layout for Completed (Selesai) view with Clear History button
    if (provider.filter == TaskFilter.done) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.completedHistory,
                style: TextStyle(
                  fontFamily: tokens.fontTitle,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tokens.inkMuted,
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: tokens.surface,
                      title: Text(
                        l10n.clearHistory,
                        style: TextStyle(
                          fontFamily: tokens.fontTitle,
                          color: tokens.ink,
                        ),
                      ),
                      content: Text(
                        l10n.clearHistory + '?',
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          color: tokens.inkMuted,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearCompletedHistory();
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            l10n.clearHistory,
                            style: TextStyle(color: tokens.priorityHigh),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  l10n.clearHistory,
                  style: TextStyle(
                    fontFamily: tokens.fontBody,
                    fontSize: 12,
                    color: tokens.priorityHigh,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...list.map((task) => TaskTile(task: task)),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final task = list[index];
        return TaskTile(task: task);
      },
    );
  }
}
