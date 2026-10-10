import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: BorderSide(color: tokens.line, width: tokens.borderWidth),
      ),
      title: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: tokens.accent),
          const SizedBox(width: 10),
          Text(
            l10n.notificationsTitle,
            style: TextStyle(
              fontFamily: tokens.fontTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tokens.ink,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsDesc,
            style: TextStyle(
              fontFamily: tokens.fontBody,
              fontSize: 14,
              color: tokens.ink,
            ),
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.alarm,
            title: 'Alarm Tepat Waktu',
            subtitle: 'Supaya pengingat tugas berbunyi tepat waktu.',
            tokens: tokens,
          ),
          const SizedBox(height: 8),
          _buildPermissionItem(
            icon: Icons.battery_saver,
            title: 'Pengecualian Latar Belakang',
            subtitle: 'Supaya aplikasi tidak dimatikan oleh sistem hemat baterai.',
            tokens: tokens,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.later,
            style: TextStyle(color: tokens.inkMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.accent,
            foregroundColor: tokens.onAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius > 8 ? 8 : tokens.radius),
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            await NotificationService.instance.requestPermissions();
          },
          child: Text(
            l10n.allow,
            style: TextStyle(
              fontFamily: tokens.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeTokens tokens,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: tokens.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: tokens.fontTitle,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: tokens.ink,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: tokens.fontBody,
                  fontSize: 11,
                  color: tokens.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
