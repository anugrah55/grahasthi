import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class MaidProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _maids = [];
  Map<String, String> _attendance = {}; // key: maidId_YYYY_MM_DD -> status
  Map<String, List<Map<String, dynamic>>> _advances = {}; // key: maidId -> list of advances
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Map<String, dynamic>> get maids => _maids;
  Map<String, String> get attendance => _attendance;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  Future<void> init() async {
    await loadMaids();
    await loadAttendance();
    await loadAdvances();
  }

  Future<void> loadMaids() async {
    final data = await _storage.getAll(AppConstants.maidsBox);
    _maids = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    notifyListeners();
  }

  Future<void> addMaid({
    required String name,
    required double dailyWage,
    String tasks = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.maidsBox, id, {
      'name': name,
      'dailyWage': dailyWage,
      'tasks': tasks,
    });
    await loadMaids();
  }

  Future<void> updateMaid(String id, {
    required String name,
    required double dailyWage,
    String tasks = '',
  }) async {
    await _storage.put(AppConstants.maidsBox, id, {
      'name': name,
      'dailyWage': dailyWage,
      'tasks': tasks,
    });
    await loadMaids();
  }

  Future<void> deleteMaid(String id) async {
    await _storage.delete(AppConstants.maidsBox, id);
    // Delete attendance and advances
    final allAttendance = await _storage.getAll(AppConstants.maidAttendanceBox);
    for (var key in allAttendance.keys) {
      if (key.startsWith('${id}_')) {
        await _storage.delete(AppConstants.maidAttendanceBox, key);
      }
    }
    final allAdvances = await _storage.getAll(AppConstants.maidAdvancesBox);
    for (var key in allAdvances.keys) {
      if (key.startsWith('${id}_')) {
        await _storage.delete(AppConstants.maidAdvancesBox, key);
      }
    }
    await loadMaids();
    await loadAttendance();
    await loadAdvances();
  }

  Future<void> loadAttendance() async {
    final monthPrefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final allData = await _storage.getAll(AppConstants.maidAttendanceBox);
    _attendance = {};
    allData.forEach((key, value) {
      // key format: maidId_YYYY_MM_DD
      final parts = key.split('_');
      if (parts.length >= 4) {
        final dateStr = '${parts[1]}_${parts[2]}_${parts[3]}';
        if (dateStr.startsWith(monthPrefix.replaceAll('_', '_'))) {
          _attendance[key] = value.toString();
        }
      }
    });
    // Fix: re-parse with proper key format
    _attendance = {};
    for (var entry in allData.entries) {
      // Check if this entry belongs to current month
      if (entry.key.contains(monthPrefix)) {
        _attendance[entry.key] = entry.value.toString();
      }
    }
    notifyListeners();
  }

  Future<void> loadAdvances() async {
    final monthPrefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final allData = await _storage.getAll(AppConstants.maidAdvancesBox);
    _advances = {};
    allData.forEach((key, value) {
      if (key.contains(monthPrefix)) {
        final maidId = key.split('_adv_')[0];
        _advances[maidId] ??= [];
        final advData = Map<String, dynamic>.from(value as Map);
        advData['key'] = key;
        _advances[maidId]!.add(advData);
      }
    });
    notifyListeners();
  }

  Future<void> setAttendance(String maidId, int day, String status) async {
    final key = '${maidId}_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    if (status.isEmpty) {
      await _storage.delete(AppConstants.maidAttendanceBox, key);
    } else {
      await _storage.put(AppConstants.maidAttendanceBox, key, status);
    }
    await loadAttendance();
  }

  String getAttendance(String maidId, int day) {
    final key = '${maidId}_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    return _attendance[key] ?? '';
  }

  Future<void> addAdvance(String maidId, double amount, String note) async {
    final key = '${maidId}_adv_${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.maidAdvancesBox, key, {
      'amount': amount,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    });
    await loadAdvances();
  }

  Future<void> deleteAdvance(String key) async {
    await _storage.delete(AppConstants.maidAdvancesBox, key);
    await loadAdvances();
  }

  List<Map<String, dynamic>> getAdvancesForMaid(String maidId) {
    return _advances[maidId] ?? [];
  }

  double getTotalAdvanceForMaid(String maidId) {
    final list = _advances[maidId] ?? [];
    return list.fold(0.0, (sum, adv) => sum + (adv['amount'] as num).toDouble());
  }

  int getDaysPresentForMaid(String maidId) {
    int count = 0;
    _attendance.forEach((key, value) {
      if (key.startsWith('${maidId}_') && value == AppConstants.statusPresent) {
        count++;
      }
    });
    return count;
  }

  int getHalfDaysForMaid(String maidId) {
    int count = 0;
    _attendance.forEach((key, value) {
      if (key.startsWith('${maidId}_') && value == AppConstants.statusHalfDay) {
        count++;
      }
    });
    return count;
  }

  double getEffectiveDaysForMaid(String maidId) {
    return getDaysPresentForMaid(maidId) + (getHalfDaysForMaid(maidId) * 0.5);
  }

  double getGrossAmountForMaid(String maidId) {
    final maid = _maids.firstWhere((m) => m['id'] == maidId, orElse: () => {});
    if (maid.isEmpty) return 0;
    final wage = (maid['dailyWage'] as num).toDouble();
    return getEffectiveDaysForMaid(maidId) * wage;
  }

  double getNetAmountForMaid(String maidId) {
    return getGrossAmountForMaid(maidId) - getTotalAdvanceForMaid(maidId);
  }

  double get totalMaidExpense {
    double total = 0;
    for (var maid in _maids) {
      total += getNetAmountForMaid(maid['id']);
    }
    return total;
  }

  void setMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    loadAttendance();
    loadAdvances();
  }

  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    loadAttendance();
    loadAdvances();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    loadAttendance();
    loadAdvances();
  }

  String getShareTextForMaid(String maidId, String lang) {
    final maid = _maids.firstWhere((m) => m['id'] == maidId, orElse: () => {});
    if (maid.isEmpty) return '';

    final name = maid['name'];
    final daysPresent = getDaysPresentForMaid(maidId);
    final halfDays = getHalfDaysForMaid(maidId);
    final effectiveDays = getEffectiveDaysForMaid(maidId);
    final wage = (maid['dailyWage'] as num).toDouble();
    final gross = getGrossAmountForMaid(maidId);
    final advance = getTotalAdvanceForMaid(maidId);
    final net = getNetAmountForMaid(maidId);
    final monthName = lang == 'hi' ? _getMonthNameHi(_selectedMonth) : _getMonthNameEn(_selectedMonth);

    final buffer = StringBuffer();
    buffer.writeln('🧹 $name — $monthName $_selectedYear');
    buffer.writeln('─────────────────');

    if (lang == 'hi') {
      buffer.writeln('उपस्थित: $daysPresent दिन');
      if (halfDays > 0) buffer.writeln('आधे दिन: $halfDays');
      buffer.writeln('कुल: $effectiveDays दिन × ₹${wage.toInt()} = ₹${gross.toInt()}');
      if (advance > 0) buffer.writeln('एडवांस: ₹${advance.toInt()} कटा');
      buffer.writeln('─────────────────');
      buffer.writeln('बकाया: ₹${net.toInt()}');
    } else {
      buffer.writeln('Present: $daysPresent days');
      if (halfDays > 0) buffer.writeln('Half days: $halfDays');
      buffer.writeln('Total: $effectiveDays days × ₹${wage.toInt()} = ₹${gross.toInt()}');
      if (advance > 0) buffer.writeln('Advance: ₹${advance.toInt()} deducted');
      buffer.writeln('─────────────────');
      buffer.writeln('Due: ₹${net.toInt()}');
    }
    return buffer.toString();
  }

  String _getMonthNameEn(int m) => ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
  String _getMonthNameHi(int m) => ['', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर'][m];
}
