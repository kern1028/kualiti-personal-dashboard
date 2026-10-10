import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';
import '../tasks/screens/tasks_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    final screens = [
      DashboardScreen(
        onNavigateTab: _onTabChanged,
        onOpenSettings: _openSettings,
      ),
      const TasksScreen(),
      _buildPlaceholderTab(l10n.navTimer, Icons.timer_outlined, tokens, l10n),
      _buildPlaceholderTab(l10n.navNotes, Icons.notes_rounded, tokens, l10n),
      _buildPlaceholderTab(l10n.navLinks, Icons.link_rounded, tokens, l10n),
    ];

    return Scaffold(
      backgroundColor: tokens.bg,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNav(tokens, l10n),
    );
  }

  Widget _buildPlaceholderTab(
    String title,
    IconData icon,
    ThemeTokens tokens,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: tokens.bg,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: tokens.inkMuted),
            const SizedBox(height: 12),
            Text(
              l10n.emptyState,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 14,
                color: tokens.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(ThemeTokens tokens, AppLocalizations l10n) {
    final navItems = [
      (0, l10n.navHome, Icons.home_rounded),
      (1, l10n.navTasks, Icons.check_circle_outline_rounded),
      (2, l10n.navTimer, Icons.timer_outlined),
      (3, l10n.navNotes, Icons.notes_rounded),
      (4, l10n.navLinks, Icons.link_rounded),
    ];

    BoxDecoration decoration;
    if (tokens.isRetroXp) {
      decoration = const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF245EDC), Color(0xFF3F8CF3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2),
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: tokens.surface,
        border: Border(
          top: BorderSide(
            color: tokens.line,
            width: tokens.borderWidth,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: navItems.map((item) {
              final index = item.$1;
              final label = item.$2;
              final icon = item.$3;
              final isSelected = _currentIndex == index;

              Color itemColor;
              if (tokens.isRetroXp) {
                itemColor = isSelected ? Colors.white : const Color(0xFFCFE0FF);
              } else {
                itemColor = isSelected ? tokens.accent : tokens.inkMuted;
              }

              return Expanded(
                child: InkWell(
                  onTap: () => _onTabChanged(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: itemColor, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
