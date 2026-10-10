import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';
import '../../core/db/user_provider.dart';
import '../../core/utils/date_time_formatter.dart';
import '../backup/backup_provider.dart';
import '../tasks/providers/task_provider.dart';
import '../links/providers/link_provider.dart';
import '../notes/providers/note_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.userName);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _toggleSound(bool val) async {
    setState(() {
      _soundEnabled = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', val);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleExportBackup(BuildContext context, ThemeTokens tokens, AppLocalizations l10n) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final provider = LocalFileBackupProvider();
    await provider.exportBackupData(userProvider.userName);
    final fileName = LocalFileBackupProvider.sanitizeFileName(userProvider.userName);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surface,
        title: Text('Ekspor Cadangan ($fileName)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File cadangan siap disimpan:', style: TextStyle(color: tokens.ink)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                fileName,
                style: TextStyle(fontFamily: tokens.fontTitle, fontWeight: FontWeight.bold, color: tokens.accent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImportBackup(BuildContext context, ThemeTokens tokens, AppLocalizations l10n) async {
    final importController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surface,
        title: Text(l10n.importBackup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tempel teks JSON cadangan (kualiti...backup.json):', style: TextStyle(color: tokens.ink, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: importController,
              maxLines: 6,
              style: TextStyle(fontFamily: tokens.fontBody, fontSize: 12, color: tokens.ink),
              decoration: const InputDecoration(
                hintText: '{"app": "kualiti", ...}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tokens.accent, foregroundColor: tokens.onAccent),
            onPressed: () async {
              final jsonStr = importController.text.trim();
              Navigator.pop(ctx);
              if (jsonStr.isEmpty) return;

              final provider = LocalFileBackupProvider();
              final backupMap = await provider.readBackupData(jsonStr);

              if (backupMap == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Format file cadangan tidak valid!'), backgroundColor: tokens.priorityHigh),
                  );
                }
                return;
              }

              // Confirm restore dialog
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (confirmCtx) => AlertDialog(
                    backgroundColor: tokens.surface,
                    title: const Text('Konfirmasi Impor Data'),
                    content: Text(
                      'Data lokal saat ini akan ditimpa dengan cadangan dari tanggal ${backupMap["createdAt"] ?? "tidak diketahui"}.\n\nLanjutkan?',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(l10n.cancel)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tokens.priorityHigh, foregroundColor: Colors.white),
                        onPressed: () async {
                          Navigator.pop(confirmCtx);
                          final success = await provider.restoreBackupData(backupMap);
                          if (success && context.mounted) {
                            // Reload all providers
                            Provider.of<TaskProvider>(context, listen: false).loadTasks();
                            Provider.of<LinkProvider>(context, listen: false).loadLinks();
                            Provider.of<NoteProvider>(context, listen: false).loadNotes();
                            Provider.of<UserProvider>(context, listen: false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.saved)),
                            );
                          }
                        },
                        child: const Text('Impor & Timpa'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(l10n.importBackup),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: tokens.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section: Name
          _buildSectionHeader(l10n.name, tokens),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: TextField(
              controller: _nameController,
              style: TextStyle(color: tokens.ink, fontFamily: tokens.fontBody),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.onboardingNameHint,
              ),
              onChanged: (val) {
                userProvider.setUserName(val);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Section: Sound & Notifications
          _buildSectionHeader('Notifikasi & Suara', tokens),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.mp3Sound,
                style: TextStyle(fontFamily: tokens.fontBody, fontSize: 14, color: tokens.ink),
              ),
              subtitle: Text(
                l10n.vibrateHint,
                style: TextStyle(fontFamily: tokens.fontBody, fontSize: 11, color: tokens.inkMuted),
              ),
              activeColor: tokens.accent,
              value: _soundEnabled,
              onChanged: _toggleSound,
            ),
          ),
          const SizedBox(height: 20),

          // Section: Language
          _buildSectionHeader(l10n.language, tokens),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              children: [
                _buildRadioTile(
                  title: l10n.systemDefault,
                  value: 'system',
                  groupValue: localeProvider.selectedLanguage,
                  tokens: tokens,
                  onChanged: (val) => localeProvider.setLanguage(val!),
                ),
                _buildRadioTile(
                  title: 'Bahasa Indonesia',
                  value: 'id',
                  groupValue: localeProvider.selectedLanguage,
                  tokens: tokens,
                  onChanged: (val) => localeProvider.setLanguage(val!),
                ),
                _buildRadioTile(
                  title: 'English',
                  value: 'en',
                  groupValue: localeProvider.selectedLanguage,
                  tokens: tokens,
                  onChanged: (val) => localeProvider.setLanguage(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Theme
          _buildSectionHeader(l10n.theme, tokens),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _buildThemeTile(AppThemeMode.defaultTheme, l10n.themeDefault, themeProvider),
                _buildThemeTile(AppThemeMode.darkMode, l10n.themeDark, themeProvider),
                _buildThemeTile(AppThemeMode.aestheticBrown, l10n.themeAesthetic, themeProvider),
                _buildThemeTile(AppThemeMode.vintage, l10n.themeVintage, themeProvider),
                _buildThemeTile(AppThemeMode.retroXp, l10n.themeRetro, themeProvider),
                _buildThemeTile(AppThemeMode.pixel, l10n.themePixel, themeProvider),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Date & Time Format
          _buildSectionHeader(l10n.dateFormat, tokens),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              children: [
                _buildRadioTile(
                  title: 'DD/MM/YYYY (24/10/2026)',
                  value: DateFormatOption.dmy,
                  groupValue: DateTimeFormatter.currentDateFormat,
                  tokens: tokens,
                  onChanged: (val) {
                    setState(() {
                      DateTimeFormatter.setDateFormat(val!);
                    });
                  },
                ),
                _buildRadioTile(
                  title: 'MM/DD/YYYY (10/24/2026)',
                  value: DateFormatOption.mdy,
                  groupValue: DateTimeFormatter.currentDateFormat,
                  tokens: tokens,
                  onChanged: (val) {
                    setState(() {
                      DateTimeFormatter.setDateFormat(val!);
                    });
                  },
                ),
                _buildRadioTile(
                  title: 'YYYY/MM/DD (2026/10/24)',
                  value: DateFormatOption.ymd,
                  groupValue: DateTimeFormatter.currentDateFormat,
                  tokens: tokens,
                  onChanged: (val) {
                    setState(() {
                      DateTimeFormatter.setDateFormat(val!);
                    });
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    DateTimeFormatter.is24Hour ? l10n.hour24 : l10n.hour12,
                    style: TextStyle(
                      fontFamily: tokens.fontBody,
                      fontSize: 14,
                      color: tokens.ink,
                    ),
                  ),
                  activeColor: tokens.accent,
                  value: DateTimeFormatter.is24Hour,
                  onChanged: (val) {
                    setState(() {
                      DateTimeFormatter.set24Hour(val);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Data Backup
          _buildSectionHeader(l10n.dataBackup, tokens),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.download_rounded, color: tokens.accent),
                  title: Text(l10n.exportDevice, style: TextStyle(color: tokens.ink, fontSize: 14)),
                  onTap: () => _handleExportBackup(context, tokens, l10n),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.upload_rounded, color: tokens.accent),
                  title: Text(l10n.importBackup, style: TextStyle(color: tokens.ink, fontSize: 14)),
                  onTap: () => _handleImportBackup(context, tokens, l10n),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.cloud_outlined, color: tokens.accent),
                  title: Text(l10n.googleDriveBackup, style: TextStyle(color: tokens.ink, fontSize: 14)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: tokens.surface,
                        title: Text(l10n.googleDriveBackup),
                        content: Text(l10n.comingSoon),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.ok, style: TextStyle(color: tokens.accent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: About App
          _buildSectionHeader('Tentang Aplikasi', tokens),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kualiti v1.0.0', style: TextStyle(fontFamily: tokens.fontTitle, fontWeight: FontWeight.bold, color: tokens.ink)),
                const SizedBox(height: 4),
                Text('Your Cozy Personal Dashboard', style: TextStyle(color: tokens.inkMuted, fontSize: 12)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse('https://github.com/kern1028/kualiti-personal-dashboard'), mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.code_rounded, size: 16, color: tokens.accent),
                      const SizedBox(width: 6),
                      Text(
                        'GitHub: kern1028/kualiti-personal-dashboard',
                        style: TextStyle(color: tokens.accent, fontSize: 12, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: tokens.fontTitle,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: tokens.inkMuted,
        ),
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ThemeTokens tokens,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: tokens.fontBody,
          fontSize: 14,
          color: tokens.ink,
        ),
      ),
      activeColor: tokens.accent,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  Widget _buildThemeTile(
    AppThemeMode mode,
    String title,
    ThemeProvider provider,
  ) {
    final isSelected = provider.currentTheme == mode;
    final itemTokens = ThemeTokens.getTokens(mode);

    return GestureDetector(
      onTap: () => provider.setTheme(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: itemTokens.surface,
          borderRadius: BorderRadius.circular(itemTokens.radius),
          border: Border.all(
            color: isSelected ? provider.tokens.accent : itemTokens.line,
            width: isSelected ? 2.0 : itemTokens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: itemTokens.accent,
                shape: itemTokens.isPixel ? BoxShape.rectangle : BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: itemTokens.fontTitle,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: itemTokens.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
