import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  String _selectedLanguage = 'system'; // 'system', 'id', 'en'

  String get selectedLanguage => _selectedLanguage;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _selectedLanguage = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (_selectedLanguage == code) return;
    _selectedLanguage = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  Locale? get locale {
    if (_selectedLanguage == 'id') return const Locale('id');
    if (_selectedLanguage == 'en') return const Locale('en');
    return null; // System default
  }

  Locale resolveLocale(Locale? deviceLocale) {
    if (_selectedLanguage == 'id') return const Locale('id');
    if (_selectedLanguage == 'en') return const Locale('en');
    if (deviceLocale != null && deviceLocale.languageCode == 'id') {
      return const Locale('id');
    }
    return const Locale('en');
  }
}

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'))..loadSyncDefault();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(
        locale.languageCode == 'id'
            ? 'lib/core/l10n/app_id.arb'
            : 'lib/core/l10n/app_en.arb',
      );
    } catch (_) {
      jsonString = await rootBundle.loadString(
        locale.languageCode == 'id'
            ? 'assets/l10n/app_id.arb'
            : 'assets/l10n/app_en.arb',
      );
    }

    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  void loadSyncDefault() {
    _localizedStrings = {};
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getters for all keys
  String get appTitle => translate('appTitle');
  String get splashTagline => translate('splashTagline');
  String get onboardingNameTitle => translate('onboardingNameTitle');
  String get onboardingNameHint => translate('onboardingNameHint');
  String get onboardingNext => translate('onboardingNext');
  String get onboardingLanguageTitle => translate('onboardingLanguageTitle');
  String get onboardingThemeTitle => translate('onboardingThemeTitle');
  String get onboardingThemeSubtitle => translate('onboardingThemeSubtitle');
  String get onboardingStart => translate('onboardingStart');
  String get systemDefault => translate('systemDefault');
  String get navHome => translate('navHome');
  String get navTasks => translate('navTasks');
  String get navTimer => translate('navTimer');
  String get navNotes => translate('navNotes');
  String get navLinks => translate('navLinks');
  String get greeting => translate('greeting');
  String get todayTasks => translate('todayTasks');
  String get tasksRemaining => translate('tasksRemaining');
  String get upNext => translate('upNext');
  String get activeTimer => translate('activeTimer');
  String get quickLinks => translate('quickLinks');
  String get filterAll => translate('filterAll');
  String get filterToday => translate('filterToday');
  String get filterUpcoming => translate('filterUpcoming');
  String get filterDone => translate('filterDone');
  String get filterRepeating => translate('filterRepeating');
  String get sortDue => translate('sortDue');
  String get sortPriority => translate('sortPriority');
  String get sortAlphabetical => translate('sortAlphabetical');
  String get priorityChill => translate('priorityChill');
  String get priorityImportant => translate('priorityImportant');
  String get priorityCritical => translate('priorityCritical');
  String get overdue => translate('overdue');
  String get add => translate('add');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get undo => translate('undo');
  String get deleted => translate('deleted');
  String get taskTitle => translate('taskTitle');
  String get date => translate('date');
  String get timeOptional => translate('timeOptional');
  String get timeDefaultHint => translate('timeDefaultHint');
  String get repeat => translate('repeat');
  String get repeatNever => translate('repeatNever');
  String get repeatDaily => translate('repeatDaily');
  String get repeatWeekly => translate('repeatWeekly');
  String get repeatMonthly => translate('repeatMonthly');
  String get repeatYearly => translate('repeatYearly');
  String get remindMe => translate('remindMe');
  String get remindOnTime => translate('remindOnTime');
  String get remind10Min => translate('remind10Min');
  String get remind1Hour => translate('remind1Hour');
  String get remind1Day => translate('remind1Day');
  String get priority => translate('priority');
  String get completedHistory => translate('completedHistory');
  String get clearHistory => translate('clearHistory');
  String get emptyState => translate('emptyState');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get daysAgo => translate('daysAgo');
  String get tabTimer => translate('tabTimer');
  String get tabStopwatch => translate('tabStopwatch');
  String get tabGaming => translate('tabGaming');
  String get tabReading => translate('tabReading');
  String get tabStudying => translate('tabStudying');
  String get tabEyeRest => translate('tabEyeRest');
  String get focus => translate('focus');
  String get rest => translate('rest');
  String get cycle => translate('cycle');
  String get cycleOf => translate('cycleOf');
  String get unlimited => translate('unlimited');
  String get autoStart => translate('autoStart');
  String get recommended => translate('recommended');
  String get custom => translate('custom');
  String get minutes => translate('minutes');
  String get start => translate('start');
  String get pause => translate('pause');
  String get reset => translate('reset');
  String get lap => translate('lap');
  String get simulateFinish => translate('simulateFinish');
  String get timerName => translate('timerName');
  String get timesUp => translate('timesUp');
  String get nextPhaseStarted => translate('nextPhaseStarted');
  String get eyeRestNotificationText => translate('eyeRestNotificationText');
  String get eyeRestStartAction => translate('eyeRestStartAction');
  String get eyeRestSnoozeAction => translate('eyeRestSnoozeAction');
  String get eyeRestSkipAction => translate('eyeRestSkipAction');
  String get eyeRestEnableReminders => translate('eyeRestEnableReminders');
  String get eyeRestActiveHoursHint => translate('eyeRestActiveHoursHint');
  String get eyeRestKilledWarning => translate('eyeRestKilledWarning');
  String get searchNotes => translate('searchNotes');
  String get newNote => translate('newNote');
  String get noteTitle => translate('noteTitle');
  String get pin => translate('pin');
  String get linkName => translate('linkName');
  String get linkUrl => translate('linkUrl');
  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get dateFormat => translate('dateFormat');
  String get timeFormat => translate('timeFormat');
  String get hour24 => translate('hour24');
  String get hour12 => translate('hour12');
  String get mp3Sound => translate('mp3Sound');
  String get vibrateHint => translate('vibrateHint');
  String get dataBackup => translate('dataBackup');
  String get exportDevice => translate('exportDevice');
  String get importBackup => translate('importBackup');
  String get googleDriveBackup => translate('googleDriveBackup');
  String get comingSoon => translate('comingSoon');
  String get saved => translate('saved');
  String get ok => translate('ok');
  String get name => translate('name');
  String get themeDefault => translate('themeDefault');
  String get themeDark => translate('themeDark');
  String get themeAesthetic => translate('themeAesthetic');
  String get themeVintage => translate('themeVintage');
  String get themeRetro => translate('themeRetro');
  String get themePixel => translate('themePixel');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationGetter on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
