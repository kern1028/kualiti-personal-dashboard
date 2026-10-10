import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const String _userNameKey = 'user_name';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  String _userName = '';
  bool _isOnboardingComplete = false;
  bool _isLoaded = false;

  String get userName => _userName;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoaded => _isLoaded;

  UserProvider() {
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey) ?? '';
    _isOnboardingComplete = (prefs.getBool(_onboardingCompleteKey) ?? false) || _userName.isNotEmpty;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    if (_userName.isNotEmpty) {
      _isOnboardingComplete = true;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
    if (_userName.isNotEmpty) {
      await prefs.setBool(_onboardingCompleteKey, true);
    }
  }

  Future<void> completeOnboarding(String name) async {
    _userName = name.trim();
    _isOnboardingComplete = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, _userName);
    await prefs.setBool(_onboardingCompleteKey, true);
  }
}
