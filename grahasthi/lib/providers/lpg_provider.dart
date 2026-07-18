import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class LpgProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _refills = [];
  int _reminderDays = AppConstants.defaultLpgReminderDays;

  List<Map<String, dynamic>> get refills => _refills;
  int get reminderDays => _reminderDays;

  Future<void> init() async {
    await loadRefills();
    final settings = await _storage.get(AppConstants.settingsBox, 'lpg_settings');
    if (settings != null && settings is Map) {
      _reminderDays = (settings['reminderDays'] as num?)?.toInt() ?? AppConstants.defaultLpgReminderDays;
    }
  }

  Future<void> loadRefills() async {
    final data = await _storage.getAll(AppConstants.lpgBox);
    _refills = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _refills.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> addRefill({
    required String date,
    required double amount,
    String deliveryPerson = '',
    String bookingRef = '',
    double subsidyAmount = 0,
    String subsidyDate = '',
    String connectionName = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.lpgBox, id, {
      'date': date,
      'amount': amount,
      'deliveryPerson': deliveryPerson,
      'bookingRef': bookingRef,
      'subsidyAmount': subsidyAmount,
      'subsidyDate': subsidyDate,
      'connectionName': connectionName,
    });
    await loadRefills();
  }

  Future<void> deleteRefill(String id) async {
    await _storage.delete(AppConstants.lpgBox, id);
    await loadRefills();
  }

  Future<void> setReminderDays(int days) async {
    _reminderDays = days;
    await _storage.put(AppConstants.settingsBox, 'lpg_settings', {
      'reminderDays': days,
    });
    notifyListeners();
  }

  double get avgDaysPerCylinder {
    if (_refills.length < 2) return 0;
    final sorted = List<Map<String, dynamic>>.from(_refills)
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    int totalDays = 0;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]['date']);
      final curr = DateTime.parse(sorted[i]['date']);
      totalDays += curr.difference(prev).inDays;
    }
    return totalDays / (sorted.length - 1);
  }

  double get annualSpend {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    return _refills.where((r) {
      final date = DateTime.parse(r['date']);
      return date.isAfter(yearStart) || date.isAtSameMomentAs(yearStart);
    }).fold(0.0, (sum, r) => sum + (r['amount'] as num).toDouble());
  }

  double get totalSubsidy {
    return _refills.fold(0.0, (sum, r) => sum + ((r['subsidyAmount'] as num?)?.toDouble() ?? 0));
  }

  DateTime? get lastRefillDate {
    if (_refills.isEmpty) return null;
    return DateTime.parse(_refills.first['date']);
  }

  DateTime? get nextReminderDate {
    final last = lastRefillDate;
    if (last == null) return null;
    return last.add(Duration(days: _reminderDays));
  }

  double get currentMonthSpend {
    final now = DateTime.now();
    return _refills.where((r) {
      final date = DateTime.parse(r['date']);
      return date.year == now.year && date.month == now.month;
    }).fold(0.0, (sum, r) => sum + (r['amount'] as num).toDouble());
  }
}
