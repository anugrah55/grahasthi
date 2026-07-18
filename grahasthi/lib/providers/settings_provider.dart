import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SettingsProvider extends ChangeNotifier {
  double _monthlyBudget = AppConstants.defaultMonthlyBudget;
  String _userName = '';
  int _reminderHour = 20; // 8 PM default
  int _reminderMinute = 0;
  bool _darkMode = true; // Dark mode by default

  double get monthlyBudget => _monthlyBudget;
  String get userName => _userName;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get darkMode => _darkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble(AppConstants.keyMonthlyBudget) ?? AppConstants.defaultMonthlyBudget;
    _userName = prefs.getString(AppConstants.keyUserName) ?? '';
    _reminderHour = prefs.getInt('${AppConstants.keyReminderTime}_hour') ?? 20;
    _reminderMinute = prefs.getInt('${AppConstants.keyReminderTime}_minute') ?? 0;
    _darkMode = prefs.getBool(AppConstants.keyDarkMode) ?? true;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyMonthlyBudget, budget);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, name);
    notifyListeners();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${AppConstants.keyReminderTime}_hour', hour);
    await prefs.setInt('${AppConstants.keyReminderTime}_minute', minute);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, value);
    notifyListeners();
  }
}
