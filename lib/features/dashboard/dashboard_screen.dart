import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';
import '../../core/db/user_provider.dart';
import '../../core/utils/date_time_formatter.dart';
import '../tasks/providers/task_provider.dart';
import '../tasks/models/task_model.dart';
import '../tasks/widgets/task_form_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final userProvider = Provider.of<UserProvider>(context);

    final now = DateTime.now();
    final formattedDate = DateTimeFormatter.formatDateWithDay(
      now,
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header: Greeting & Date, Settings Icon in corner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.greeting}, ${userProvider.userName.isEmpty ? "User" : userProvider.userName}',
                          style: TextStyle(
                            fontFamily: tokens.fontTitle,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: tokens.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontFamily: tokens.fontBody,
                            fontSize: 13,
                            color: tokens.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: tokens.ink),
                    onPressed: onOpenSettings,
                    tooltip: l10n.settings,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Today's Tasks Summary Card
              _buildTodayTasksCard(context, tokens, l10n),
              const SizedBox(height: 14),

              // 3. Four Menu Cards: Notes, Tasks, Timer, Links
              _buildMenuGrid(tokens, l10n),
              const SizedBox(height: 18),

              // 4. Quick Links row (Up to 4 icons)
              _buildQuickLinksRow(tokens, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTasksCard(
    BuildContext context,
    ThemeTokens tokens,
    AppLocalizations l10n,
  ) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final count = taskProvider.todayUncompletedCount;
    final closest = taskProvider.closestUpcomingTask;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.line, width: tokens.borderWidth),
        boxShadow: tokens.isPixel
            ? [
                BoxShadow(
                  color: tokens.line,
                  offset: const Offset(3, 3),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.todayTasks,
                style: TextStyle(
                  fontFamily: tokens.fontTitle,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: tokens.ink,
                ),
              ),
              GestureDetector(
                onTap: () => onNavigateTab(1), // Open Tasks tab
                child: Text(
                  '$count ${l10n.tasksRemaining}',
                  style: TextStyle(
                    fontFamily: tokens.fontBody,
                    fontSize: 12,
                    color: tokens.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (closest == null)
            Text(
              l10n.emptyState,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 13,
                color: tokens.inkMuted,
              ),
            )
          else
            GestureDetector(
              onTap: () => onNavigateTab(1),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: closest.priority == 3
                          ? tokens.priorityHigh
                          : (closest.priority == 1 ? tokens.priorityLow : tokens.priorityMid),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          closest.title,
                          style: TextStyle(
                            fontFamily: tokens.fontBody,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tokens.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            if (closest.isOverdue) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.priorityHigh.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${l10n.overdue} (${closest.getRelativeOverdueText(l10n, localeCode)})',
                                  style: TextStyle(
                                    fontFamily: tokens.fontBody,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: tokens.priorityHigh,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Text(
                                '${l10n.upNext}: ${DateTimeFormatter.formatDate(closest.fullDueDateTime)}' +
                                    (closest.hasTime && closest.dueTime != null
                                        ? ' ${closest.dueTime}'
                                        : ''),
                                style: TextStyle(
                                  fontFamily: tokens.fontBody,
                                  fontSize: 12,
                                  color: tokens.inkMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(ThemeTokens tokens, AppLocalizations l10n) {
    final menuItems = [
      (0, l10n.navNotes, Icons.notes_rounded, 3),
      (1, l10n.navTasks, Icons.check_circle_outline_rounded, 1),
      (2, l10n.navTimer, Icons.timer_outlined, 2),
      (3, l10n.navLinks, Icons.link_rounded, 4),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: menuItems.map((item) {
        final title = item.$2;
        final icon = item.$3;
        final tabIndex = item.$4;

        return GestureDetector(
          onTap: () => onNavigateTab(tabIndex),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
              boxShadow: tokens.isPixel
                  ? [
                      BoxShadow(
                        color: tokens.line,
                        offset: const Offset(3, 3),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: tokens.accent, size: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tokens.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickLinksRow(ThemeTokens tokens, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickLinks,
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tokens.ink,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () => onNavigateTab(4),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(tokens.radius),
                  border: Border.all(
                    color: tokens.line,
                    width: tokens.borderWidth,
                  ),
                ),
                child: Icon(Icons.add, color: tokens.inkMuted, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
