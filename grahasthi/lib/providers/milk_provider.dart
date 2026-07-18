import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class MilkProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  List<Map<String, dynamic>> _milkTypes = [];
  Map<String, double> _entries = {}; // key: YYYY_MM_DD_typeId -> litres
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  List<Map<String, dynamic>> get milkTypes => _milkTypes;
  Map<String, double> get entries => _entries;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  Future<void> init() async {
    await loadMilkTypes();
    await loadEntries();
  }

  Future<void> loadMilkTypes() async {
    final data = await _storage.getAll(AppConstants.milkTypesBox);
    _milkTypes = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    notifyListeners();
  }

  Future<void> addMilkType({
    required String name,
    required double pricePerLitre,
    double defaultQty = 1.0,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.milkTypesBox, id, {
      'name': name,
      'pricePerLitre': pricePerLitre,
      'defaultQty': defaultQty,
    });
    await loadMilkTypes();
  }

  Future<void> updateMilkType(String id, {
    required String name,
    required double pricePerLitre,
    double defaultQty = 1.0,
  }) async {
    await _storage.put(AppConstants.milkTypesBox, id, {
      'name': name,
      'pricePerLitre': pricePerLitre,
      'defaultQty': defaultQty,
    });
    await loadMilkTypes();
  }

  Future<void> deleteMilkType(String id) async {
    await _storage.delete(AppConstants.milkTypesBox, id);
    // Also delete all entries for this type
    final allEntries = await _storage.getAll(AppConstants.milkBox);
    for (var key in allEntries.keys) {
      if (key.endsWith('_$id')) {
        await _storage.delete(AppConstants.milkBox, key);
      }
    }
    await loadMilkTypes();
    await loadEntries();
  }

  Future<void> loadEntries() async {
    final prefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final data = await _storage.getByPrefix(AppConstants.milkBox, prefix);
    _entries = data.map((key, value) => MapEntry(key, (value as num).toDouble()));
    notifyListeners();
  }

  Future<void> logMilk(int day, String typeId, double litres) async {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}_$typeId';
    if (litres == 0) {
      await _storage.delete(AppConstants.milkBox, key);
    } else {
      await _storage.put(AppConstants.milkBox, key, litres);
    }
    await loadEntries();
  }

  Future<void> logNoMilk(int day, String typeId) async {
    await logMilk(day, typeId, AppConstants.noMilkSentinel);
  }

  Future<void> setDefaultForMonth(String typeId, double defaultQty) async {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    for (var day = 1; day <= daysInMonth; day++) {
      final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}_$typeId';
      await _storage.put(AppConstants.milkBox, key, defaultQty);
    }
    await loadEntries();
  }

  bool isNoMilkDay(int day, String typeId) {
    return getLitresForDay(day, typeId) == AppConstants.noMilkSentinel;
  }

  bool hasLoggedEntryForDay(int day, String typeId) {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}_$typeId';
    return _entries.containsKey(key);
  }

  double getLitresForDay(int day, String typeId) {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}_$typeId';
    return _entries[key] ?? 0.0;
  }

  double getTotalLitresForDay(int day) {
    final prefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    double total = 0;
    _entries.forEach((key, value) {
      if (key.startsWith(prefix)) total += value;
    });
    return total;
  }

  bool hasEntryForDay(int day) {
    final prefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${day.toString().padLeft(2, '0')}';
    return _entries.keys.any((key) => key.startsWith(prefix));
  }

  double get totalLitresThisMonth {
    return _entries.values.where((litres) => litres > 0).fold(0.0, (sum, litres) => sum + litres);
  }

  double getTotalLitresForType(String typeId) {
    double total = 0;
    _entries.forEach((key, value) {
      if (key.endsWith('_$typeId') && value > 0) total += value;
    });
    return total;
  }

  double get totalAmountThisMonth {
    double total = 0;
    for (var type in _milkTypes) {
      final typeId = type['id'] as String;
      final pricePerLitre = (type['pricePerLitre'] as num).toDouble();
      total += getTotalLitresForType(typeId) * pricePerLitre;
    }
    return total;
  }

  double getAmountForType(String typeId) {
    final type = _milkTypes.firstWhere((t) => t['id'] == typeId, orElse: () => {});
    if (type.isEmpty) return 0;
    final pricePerLitre = (type['pricePerLitre'] as num).toDouble();
    return getTotalLitresForType(typeId) * pricePerLitre;
  }

  void setMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    loadEntries();
  }

  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    loadEntries();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    loadEntries();
  }

  String getShareText(String lang) {
    final buffer = StringBuffer();
    if (lang == 'hi') {
      buffer.writeln('🥛 दूध का बिल — ${_getMonthNameHi(_selectedMonth)} $_selectedYear');
    } else {
      buffer.writeln('🥛 Milk bill — ${_getMonthNameEn(_selectedMonth)} $_selectedYear');
    }
    buffer.writeln('─────────────────');
    for (var type in _milkTypes) {
      final typeId = type['id'] as String;
      final litres = getTotalLitresForType(typeId);
      final price = (type['pricePerLitre'] as num).toDouble();
      final amount = litres * price;
      if (litres > 0) {
        buffer.writeln('${type['name']}: ${litres}L × ₹${price.toInt()} = ₹${amount.toInt()}');
      }
    }
    buffer.writeln('─────────────────');
    if (lang == 'hi') {
      buffer.writeln('कुल: ${totalLitresThisMonth}L = ₹${totalAmountThisMonth.toInt()}');
    } else {
      buffer.writeln('Total: ${totalLitresThisMonth}L = ₹${totalAmountThisMonth.toInt()}');
    }
    return buffer.toString();
  }

  String _getMonthNameEn(int m) => ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
  String _getMonthNameHi(int m) => ['', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर'][m];
}
