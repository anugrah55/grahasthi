import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class WaterProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _entries = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Map<String, dynamic>> get entries => _entries;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  Future<void> init() async {
    await loadEntries();
  }

  Future<void> loadEntries() async {
    final prefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final data = await _storage.getByPrefix(AppConstants.waterBox, prefix);
    _entries = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _entries.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> addCanDelivery({
    required String date,
    required int numCans,
    required double pricePerCan,
  }) async {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.waterBox, key, {
      'date': date,
      'type': 'can',
      'numCans': numCans,
      'pricePerCan': pricePerCan,
      'totalAmount': numCans * pricePerCan,
    });
    await loadEntries();
  }

  Future<void> addTankerDelivery({
    required String date,
    required double tankerSize,
    required double amount,
  }) async {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.waterBox, key, {
      'date': date,
      'type': 'tanker',
      'tankerSize': tankerSize,
      'totalAmount': amount,
    });
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _storage.delete(AppConstants.waterBox, id);
    await loadEntries();
  }

  double get monthlyTotal {
    return _entries.fold(0.0, (sum, e) => sum + (e['totalAmount'] as num).toDouble());
  }

  void setMonth(int year, int month) {
    _selectedYear = year; _selectedMonth = month; loadEntries();
  }
  void previousMonth() {
    if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; } else { _selectedMonth--; }
    loadEntries();
  }
  void nextMonth() {
    if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; } else { _selectedMonth++; }
    loadEntries();
  }
}
