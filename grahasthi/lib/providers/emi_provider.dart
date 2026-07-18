import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class EmiProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _emis = [];
  Map<String, bool> _payments = {}; // key: emiId_YYYY_MM -> paid

  List<Map<String, dynamic>> get emis => _emis;
  Map<String, bool> get payments => _payments;

  Future<void> init() async {
    await loadEmis();
    await loadPayments();
  }

  Future<void> loadEmis() async {
    final data = await _storage.getAll(AppConstants.emiBox);
    _emis = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _emis.sort((a, b) => ((a['dueDate'] as num?)?.toInt() ?? 1).compareTo((b['dueDate'] as num?)?.toInt() ?? 1));
    notifyListeners();
  }

  Future<void> loadPayments() async {
    final data = await _storage.getAll(AppConstants.emiPaymentsBox);
    _payments = {};
    data.forEach((key, value) {
      _payments[key] = value == true || value == 'true';
    });
    notifyListeners();
  }

  Future<void> addEmi({
    required String name,
    required double amount,
    required int dueDate,
    bool isAutoDebit = false,
    String category = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.emiBox, id, {
      'name': name,
      'amount': amount,
      'dueDate': dueDate,
      'isAutoDebit': isAutoDebit,
      'category': category,
    });
    await loadEmis();
  }

  Future<void> updateEmi(String id, {
    required String name,
    required double amount,
    required int dueDate,
    bool isAutoDebit = false,
    String category = '',
  }) async {
    await _storage.put(AppConstants.emiBox, id, {
      'name': name, 'amount': amount, 'dueDate': dueDate,
      'isAutoDebit': isAutoDebit, 'category': category,
    });
    await loadEmis();
  }

  Future<void> deleteEmi(String id) async {
    await _storage.delete(AppConstants.emiBox, id);
    await loadEmis();
  }

  Future<void> markPaid(String emiId, int year, int month, bool paid) async {
    final key = '${emiId}_${year}_${month.toString().padLeft(2, '0')}';
    await _storage.put(AppConstants.emiPaymentsBox, key, paid);
    await loadPayments();
  }

  bool isPaid(String emiId, int year, int month) {
    final key = '${emiId}_${year}_${month.toString().padLeft(2, '0')}';
    return _payments[key] ?? false;
  }

  double get totalMonthlyObligations {
    return _emis.fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  int get paidCount {
    final now = DateTime.now();
    int count = 0;
    for (var emi in _emis) {
      if (isPaid(emi['id'], now.year, now.month)) count++;
    }
    return count;
  }

  int get unpaidCount => _emis.length - paidCount;

  double get currentMonthPaid {
    final now = DateTime.now();
    double total = 0;
    for (var emi in _emis) {
      if (isPaid(emi['id'], now.year, now.month)) {
        total += (emi['amount'] as num).toDouble();
      }
    }
    return total;
  }

  /// Get EMIs due today or overdue
  List<Map<String, dynamic>> get dueSoon {
    final now = DateTime.now();
    return _emis.where((emi) {
      final dueDay = (emi['dueDate'] as num).toInt();
      final paid = isPaid(emi['id'], now.year, now.month);
      return !paid && dueDay <= now.day + 3; // Due within 3 days
    }).toList();
  }
}
