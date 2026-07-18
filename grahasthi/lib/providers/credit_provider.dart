import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class CreditProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _shops = [];
  Map<String, List<Map<String, dynamic>>> _entries = {};

  List<Map<String, dynamic>> get shops => _shops;

  Future<void> init() async {
    await loadShops();
    await loadAllEntries();
  }

  Future<void> loadShops() async {
    final data = await _storage.getAll(AppConstants.shopsBox);
    _shops = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    notifyListeners();
  }

  Future<void> addShop(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.shopsBox, id, {'name': name});
    await loadShops();
  }

  Future<void> updateShop(String id, String name) async {
    await _storage.put(AppConstants.shopsBox, id, {'name': name});
    await loadShops();
  }

  Future<void> deleteShop(String id) async {
    await _storage.delete(AppConstants.shopsBox, id);
    final allEntries = await _storage.getAll(AppConstants.creditBox);
    for (var key in allEntries.keys) {
      if (key.startsWith('${id}_')) {
        await _storage.delete(AppConstants.creditBox, key);
      }
    }
    await loadShops();
    await loadAllEntries();
  }

  Future<void> loadAllEntries() async {
    _entries = {};
    final allData = await _storage.getAll(AppConstants.creditBox);
    for (var entry in allData.entries) {
      final val = Map<String, dynamic>.from(entry.value as Map);
      val['key'] = entry.key;
      final shopId = entry.key.split('_')[0];
      _entries[shopId] ??= [];
      _entries[shopId]!.add(val);
    }
    // Sort each shop's entries by date
    for (var shopEntries in _entries.values) {
      shopEntries.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    }
    notifyListeners();
  }

  Future<void> addCreditEntry(String shopId, {
    required String item,
    required double amount,
    required String date,
    String note = '',
  }) async {
    final key = '${shopId}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.creditBox, key, {
      'item': item,
      'amount': amount,
      'date': date,
      'isPayment': false,
      'note': note,
    });
    await loadAllEntries();
  }

  Future<void> addPayment(String shopId, {
    required double amount,
    required String date,
    String note = '',
  }) async {
    final key = '${shopId}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.creditBox, key, {
      'item': 'Payment',
      'amount': amount,
      'date': date,
      'isPayment': true,
      'note': note,
    });
    await loadAllEntries();
  }

  Future<void> deleteEntry(String key) async {
    await _storage.delete(AppConstants.creditBox, key);
    await loadAllEntries();
  }

  List<Map<String, dynamic>> getEntriesForShop(String shopId) {
    return _entries[shopId] ?? [];
  }

  double getOutstandingBalance(String shopId) {
    final entries = _entries[shopId] ?? [];
    double balance = 0;
    for (var entry in entries) {
      final amount = (entry['amount'] as num).toDouble();
      if (entry['isPayment'] == true) {
        balance -= amount;
      } else {
        balance += amount;
      }
    }
    return balance;
  }

  double get totalOutstanding {
    double total = 0;
    for (var shop in _shops) {
      total += getOutstandingBalance(shop['id']);
    }
    return total;
  }

  String getShareTextForShop(String shopId, String lang) {
    final shop = _shops.firstWhere((s) => s['id'] == shopId, orElse: () => {});
    if (shop.isEmpty) return '';

    final entries = getEntriesForShop(shopId);
    final balance = getOutstandingBalance(shopId);
    final buffer = StringBuffer();

    buffer.writeln(lang == 'hi' ? '🏪 ${shop['name']} — उधार खाता' : '🏪 ${shop['name']} — Credit Account');
    buffer.writeln('─────────────────');

    for (var entry in entries) {
      final date = entry['date'] as String;
      final amount = (entry['amount'] as num).toInt();
      if (entry['isPayment'] == true) {
        buffer.writeln('✅ $date: ${lang == 'hi' ? 'भुगतान' : 'Payment'} ₹$amount');
      } else {
        buffer.writeln('📝 $date: ${entry['item']} ₹$amount');
      }
    }

    buffer.writeln('─────────────────');
    buffer.writeln(lang == 'hi' ? 'बकाया: ₹${balance.toInt()}' : 'Balance Due: ₹${balance.toInt()}');
    return buffer.toString();
  }
}
