import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';
import '../../core/db/user_provider.dart';
import '../../core/utils/date_time_formatter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

          // Google Drive Button (Dialog "Segera hadir" per PRD)
          _buildSectionHeader(l10n.dataBackup, tokens),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cloud_outlined, color: tokens.accent),
                  title: Text(
                    l10n.googleDriveBackup,
                    style: TextStyle(
                      fontFamily: tokens.fontBody,
                      fontSize: 14,
                      color: tokens.ink,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: tokens.surface,
                        title: Text(
                          l10n.googleDriveBackup,
                          style: TextStyle(
                            fontFamily: tokens.fontTitle,
                            color: tokens.ink,
                          ),
                        ),
                        content: Text(
                          l10n.comingSoon,
                          style: TextStyle(
                            fontFamily: tokens.fontBody,
                            color: tokens.inkMuted,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              l10n.ok,
                              style: TextStyle(color: tokens.accent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
