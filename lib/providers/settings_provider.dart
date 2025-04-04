import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/language.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  Language _language = Language.en;
  
  ThemeMode get themeMode => _themeMode;
  Language get language => _language;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    final languageIndex = _prefs.getInt(_languageKey) ?? 0;
    _language = Language.values[languageIndex];

    final themeModeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    notifyListeners();
  }
  
  void setLanguage(Language language) {
    _language = language;
    _prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
  
  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }
} 