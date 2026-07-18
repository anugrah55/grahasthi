import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class FestivalProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _festivals = [];
  Map<String, List<Map<String, dynamic>>> _expenses = {};

  List<Map<String, dynamic>> get festivals => _festivals;
  List<Map<String, dynamic>> get activeFestivals => _festivals.where((f) => f['isActive'] != false).toList();
  List<Map<String, dynamic>> get pastFestivals => _festivals.where((f) => f['isActive'] == false).toList();

  Future<void> init() async {
    await loadFestivals();
    await loadAllExpenses();
  }

  Future<void> loadFestivals() async {
    final data = await _storage.getAll(AppConstants.festivalsBox);
    _festivals = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _festivals.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> loadAllExpenses() async {
    final data = await _storage.getAll(AppConstants.festivalExpensesBox);
    _expenses = {};
    for (var entry in data.entries) {
      final val = Map<String, dynamic>.from(entry.value as Map);
      val['key'] = entry.key;
      final festivalId = entry.key.split('_exp_')[0];
      _expenses[festivalId] ??= [];
      _expenses[festivalId]!.add(val);
    }
    notifyListeners();
  }

  Future<void> addFestival({
    required String name,
    required String date,
    required double totalBudget,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.festivalsBox, id, {
      'name': name,
      'date': date,
      'totalBudget': totalBudget,
      'isActive': true,
    });
    await loadFestivals();
  }

  Future<void> updateFestival(String id, {
    required String name,
    required String date,
    required double totalBudget,
  }) async {
    final existing = await _storage.get(AppConstants.festivalsBox, id);
    final data = existing is Map ? Map<String, dynamic>.from(existing) : <String, dynamic>{};
    data['name'] = name;
    data['date'] = date;
    data['totalBudget'] = totalBudget;
    await _storage.put(AppConstants.festivalsBox, id, data);
    await loadFestivals();
  }

  Future<void> moveFestivalToHistory(String id) async {
    final existing = await _storage.get(AppConstants.festivalsBox, id);
    if (existing is Map) {
      final data = Map<String, dynamic>.from(existing);
      data['isActive'] = false;
      await _storage.put(AppConstants.festivalsBox, id, data);
      await loadFestivals();
    }
  }

  Future<void> deleteFestival(String id) async {
    await _storage.delete(AppConstants.festivalsBox, id);
    // Delete expenses
    final allExpenses = await _storage.getAll(AppConstants.festivalExpensesBox);
    for (var key in allExpenses.keys) {
      if (key.startsWith('${id}_exp_')) {
        await _storage.delete(AppConstants.festivalExpensesBox, key);
      }
    }
    await loadFestivals();
    await loadAllExpenses();
  }

  Future<void> addExpense(String festivalId, {
    required String category,
    required String item,
    required double amount,
  }) async {
    final key = '${festivalId}_exp_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.festivalExpensesBox, key, {
      'category': category,
      'item': item,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    });
    await loadAllExpenses();
  }

  Future<void> deleteExpense(String key) async {
    await _storage.delete(AppConstants.festivalExpensesBox, key);
    await loadAllExpenses();
  }

  List<Map<String, dynamic>> getExpensesForFestival(String festivalId) {
    return _expenses[festivalId] ?? [];
  }

  double getTotalSpentForFestival(String festivalId) {
    return (_expenses[festivalId] ?? []).fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  double getBudgetRemainingForFestival(String festivalId) {
    final festival = _festivals.firstWhere((f) => f['id'] == festivalId, orElse: () => {});
    if (festival.isEmpty) return 0;
    return (festival['totalBudget'] as num).toDouble() - getTotalSpentForFestival(festivalId);
  }

  double get currentMonthSpend {
    final now = DateTime.now();
    double total = 0;
    for (var fest in activeFestivals) {
      final expenses = getExpensesForFestival(fest['id']);
      for (var exp in expenses) {
        try {
          final date = DateTime.parse(exp['date']);
          if (date.year == now.year && date.month == now.month) {
            total += (exp['amount'] as num).toDouble();
          }
        } catch (_) {}
      }
    }
    return total;
  }
}
