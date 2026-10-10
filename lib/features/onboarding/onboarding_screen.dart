import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_tokens.dart';
import '../../core/db/user_provider.dart';
import '../navigation/main_navigation_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0; // 0: Name, 1: Language, 2: Theme
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userName.isNotEmpty) {
        _nameController.text = userProvider.userName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_step == 0) {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserName(name);
    }
    if (_step < 2) {
      setState(() {
        _step++;
      });
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.completeOnboarding(_nameController.text.trim());

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(tokens, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeTokens tokens, AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return _buildNameStep(tokens, l10n);
      case 1:
        return _buildLanguageStep(tokens, l10n);
      case 2:
        return _buildThemeStep(tokens, l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNameStep(ThemeTokens tokens, AppLocalizations l10n) {
    return Column(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingNameTitle,
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: tokens.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(
              color: tokens.line,
              width: tokens.borderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _nameController,
            style: TextStyle(
              color: tokens.ink,
              fontFamily: tokens.fontBody,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: l10n.onboardingNameHint,
              hintStyle: TextStyle(
                color: tokens.inkMuted,
                fontFamily: tokens.fontBody,
              ),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _nextStep(),
          ),
        ),
        const SizedBox(height: 28),
        _buildPrimaryButton(
          label: l10n.onboardingNext,
          tokens: tokens,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  Widget _buildLanguageStep(ThemeTokens tokens, AppLocalizations l10n) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingLanguageTitle,
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: tokens.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _buildChoiceItem(
          title: l10n.systemDefault,
          selected: localeProvider.selectedLanguage == 'system',
          tokens: tokens,
          onTap: () => localeProvider.setLanguage('system'),
        ),
        const SizedBox(height: 12),
        _buildChoiceItem(
          title: 'Bahasa Indonesia',
          selected: localeProvider.selectedLanguage == 'id',
          tokens: tokens,
          onTap: () => localeProvider.setLanguage('id'),
        ),
        const SizedBox(height: 12),
        _buildChoiceItem(
          title: 'English',
          selected: localeProvider.selectedLanguage == 'en',
          tokens: tokens,
          onTap: () => localeProvider.setLanguage('en'),
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: l10n.onboardingNext,
          tokens: tokens,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  Widget _buildThemeStep(ThemeTokens tokens, AppLocalizations l10n) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final themeOptions = [
      (AppThemeMode.defaultTheme, l10n.themeDefault),
      (AppThemeMode.darkMode, l10n.themeDark),
      (AppThemeMode.aestheticBrown, l10n.themeAesthetic),
      (AppThemeMode.vintage, l10n.themeVintage),
      (AppThemeMode.retroXp, l10n.themeRetro),
      (AppThemeMode.pixel, l10n.themePixel),
    ];

    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingThemeTitle,
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: tokens.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingThemeSubtitle,
          style: TextStyle(
            fontFamily: tokens.fontBody,
            fontSize: 13,
            color: tokens.inkMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: themeOptions.length,
            itemBuilder: (context, index) {
              final item = themeOptions[index];
              final itemMode = item.$1;
              final itemTitle = item.$2;
              final isSelected = themeProvider.currentTheme == itemMode;
              final itemTokens = ThemeTokens.getTokens(itemMode);

              return GestureDetector(
                onTap: () => themeProvider.setTheme(itemMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: itemTokens.surface,
                    borderRadius: BorderRadius.circular(itemTokens.radius),
                    border: Border.all(
                      color: isSelected ? tokens.accent : itemTokens.line,
                      width: isSelected ? 2.5 : itemTokens.borderWidth,
                    ),
                    boxShadow: itemTokens.isPixel
                        ? [
                            const BoxShadow(
                              color: Color(0xFF2B2540),
                              offset: Offset(2, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: itemTokens.accent,
                          shape: itemTokens.isPixel ? BoxShape.rectangle : BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemTitle,
                          style: TextStyle(
                            fontFamily: itemTokens.fontTitle,
                            fontSize: 13,
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
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(
          label: l10n.onboardingStart,
          tokens: tokens,
          onPressed: _finishOnboarding,
        ),
      ],
    );
  }

  Widget _buildChoiceItem({
    required String title,
    required bool selected,
    required ThemeTokens tokens,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radius),
          border: Border.all(
            color: selected ? tokens.accent : tokens.line,
            width: selected ? 2.0 : tokens.borderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: tokens.fontBody,
                fontSize: 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: tokens.ink,
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: tokens.accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required ThemeTokens tokens,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.accent,
          foregroundColor: tokens.onAccent,
          elevation: tokens.isPixel ? 0 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius),
            side: tokens.isPixel
                ? BorderSide(color: tokens.line, width: tokens.borderWidth)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: tokens.fontTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
