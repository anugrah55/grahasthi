import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class WatchmanProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _watchmen = [];
  Map<String, String> _attendance = {};
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Map<String, dynamic>> get watchmen => _watchmen;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  Future<void> init() async {
    await loadWatchmen();
    await loadAttendance();
  }

  Future<void> loadWatchmen() async {
    final data = await _storage.getAll(AppConstants.watchmenBox);
    _watchmen = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    notifyListeners();
  }

  Future<void> addWatchman({required String name, required double salary, String salaryType = 'monthly'}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.watchmenBox, id, {
      'name': name, 'salary': salary, 'salaryType': salaryType,
    });
    await loadWatchmen();
  }

  Future<void> updateWatchman(String id, {required String name, required double salary, String salaryType = 'monthly'}) async {
    await _storage.put(AppConstants.watchmenBox, id, {'name': name, 'salary': salary, 'salaryType': salaryType});
    await loadWatchmen();
  }

  Future<void> deleteWatchman(String id) async {
    await _storage.delete(AppConstants.watchmenBox, id);
    await loadWatchmen();
  }

  Future<void> loadAttendance() async {
    final monthPrefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final allData = await _storage.getAll(AppConstants.watchmanAttendanceBox);
    _attendance = {};
    for (var entry in allData.entries) {
      if (entry.key.contains(monthPrefix)) {
        _attendance[entry.key] = entry.value.toString();
      }
    }
    notifyListeners();
  }

  Future<void> setAttendance(String watchmanId, int day, String status) async {
    final key = '${watchmanId}_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    if (status.isEmpty) {
      await _storage.delete(AppConstants.watchmanAttendanceBox, key);
    } else {
      await _storage.put(AppConstants.watchmanAttendanceBox, key, status);
    }
    await loadAttendance();
  }

  String getAttendance(String watchmanId, int day) {
    final key = '${watchmanId}_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    return _attendance[key] ?? '';
  }

  int getDaysPresent(String id) {
    int count = 0;
    _attendance.forEach((key, value) {
      if (key.startsWith('${id}_') && value == AppConstants.statusPresent) count++;
    });
    return count;
  }

  int getHalfDays(String id) {
    int count = 0;
    _attendance.forEach((key, value) {
      if (key.startsWith('${id}_') && value == AppConstants.statusHalfDay) count++;
    });
    return count;
  }

  double get totalWatchmanExpense {
    double total = 0;
    for (var w in _watchmen) {
      total += (w['salary'] as num).toDouble();
    }
    return total;
  }

  void setMonth(int year, int month) {
    _selectedYear = year; _selectedMonth = month; loadAttendance();
  }
  void previousMonth() {
    if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; } else { _selectedMonth--; }
    loadAttendance();
  }
  void nextMonth() {
    if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; } else { _selectedMonth++; }
    loadAttendance();
  }
}
