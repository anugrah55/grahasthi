import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class GroceryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _items = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _filterCategory = '';
  String _filterPaymentMode = '';
  String _searchQuery = '';

  List<Map<String, dynamic>> get items => _filteredItems;
  List<Map<String, dynamic>> get allItems => _items;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  List<Map<String, dynamic>> get _filteredItems {
    var filtered = List<Map<String, dynamic>>.from(_items);
    if (_filterCategory.isNotEmpty) {
      filtered = filtered.where((i) => i['category'] == _filterCategory).toList();
    }
    if (_filterPaymentMode.isNotEmpty) {
      filtered = filtered.where((i) => i['paymentMode'] == _filterPaymentMode).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) =>
        (i['name'] as String).toLowerCase().contains(q) ||
        (i['store'] as String? ?? '').toLowerCase().contains(q)
      ).toList();
    }
    filtered.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return filtered;
  }

  Future<void> init() async {
    await loadItems();
  }

  Future<void> loadItems() async {
    final prefix = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}';
    final data = await _storage.getByPrefix(AppConstants.groceryBox, prefix);
    _items = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required double amount,
    required String date,
    String store = '',
    String paymentMode = 'cash',
    String note = '',
    String? photoPath,
  }) async {
    final key = '${_selectedYear}_${_selectedMonth.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.put(AppConstants.groceryBox, key, {
      'name': name,
      'category': category,
      'amount': amount,
      'date': date,
      'store': store,
      'paymentMode': paymentMode,
      'note': note,
      'photoPath': photoPath,
    });
    await loadItems();
  }

  Future<void> updateItem(String id, {
    required String name,
    required String category,
    required double amount,
    required String date,
    String store = '',
    String paymentMode = 'cash',
    String note = '',
    String? photoPath,
  }) async {
    await _storage.put(AppConstants.groceryBox, id, {
      'name': name,
      'category': category,
      'amount': amount,
      'date': date,
      'store': store,
      'paymentMode': paymentMode,
      'note': note,
      'photoPath': photoPath,
    });
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _storage.delete(AppConstants.groceryBox, id);
    await loadItems();
  }

  void setFilter({String? category, String? paymentMode}) {
    if (category != null) _filterCategory = category;
    if (paymentMode != null) _filterPaymentMode = paymentMode;
    notifyListeners();
  }

  void clearFilters() {
    _filterCategory = '';
    _filterPaymentMode = '';
    _searchQuery = '';
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  double get monthlyTotal {
    return _items.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (var item in _items) {
      final cat = item['category'] as String;
      totals[cat] = (totals[cat] ?? 0) + (item['amount'] as num).toDouble();
    }
    return totals;
  }

  /// Get unique item names for suggestions
  Future<List<String>> getItemSuggestions() async {
    final allData = await _storage.getAll(AppConstants.groceryBox);
    final names = <String>{};
    for (var val in allData.values) {
      if (val is Map && val['name'] != null) {
        names.add(val['name'] as String);
      }
    }
    return names.toList()..sort();
  }

  /// Get unique store names for suggestions
  Future<List<String>> getStoreSuggestions() async {
    final allData = await _storage.getAll(AppConstants.groceryBox);
    final stores = <String>{};
    for (var val in allData.values) {
      if (val is Map && val['store'] != null && (val['store'] as String).isNotEmpty) {
        stores.add(val['store'] as String);
      }
    }
    return stores.toList()..sort();
  }

  void setMonth(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    loadItems();
  }

  void previousMonth() {
    if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; } else { _selectedMonth--; }
    loadItems();
  }

  void nextMonth() {
    if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; } else { _selectedMonth++; }
    loadItems();
  }

  String getShareText(String lang) {
    final buffer = StringBuffer();
    final monthName = lang == 'hi' ? _getMonthNameHi(_selectedMonth) : _getMonthNameEn(_selectedMonth);
    buffer.writeln(lang == 'hi' ? '🛒 किराना खर्च — $monthName $_selectedYear' : '🛒 Grocery Expenses — $monthName $_selectedYear');
    buffer.writeln('─────────────────');
    final catTotals = categoryTotals;
    for (var entry in catTotals.entries) {
      buffer.writeln('${_getCatName(entry.key, lang)}: ₹${entry.value.toInt()}');
    }
    buffer.writeln('─────────────────');
    buffer.writeln(lang == 'hi' ? 'कुल: ₹${monthlyTotal.toInt()}' : 'Total: ₹${monthlyTotal.toInt()}');
    return buffer.toString();
  }

  String _getCatName(String key, String lang) {
    final names = lang == 'hi' ? {
      'sabzi': 'सब्ज़ी', 'fruits': 'फल', 'dairy': 'डेयरी', 'grains': 'आटा-दाल-चावल',
      'spices': 'मसाले', 'cleaning': 'सफाई', 'personal': 'व्यक्तिगत', 'medicines': 'दवाइयाँ',
      'snacks': 'नाश्ता', 'other': 'अन्य',
    } : {
      'sabzi': 'Vegetables', 'fruits': 'Fruits', 'dairy': 'Dairy', 'grains': 'Grains',
      'spices': 'Spices', 'cleaning': 'Cleaning', 'personal': 'Personal', 'medicines': 'Medicines',
      'snacks': 'Snacks', 'other': 'Other',
    };
    return names[key] ?? key;
  }

  String _getMonthNameEn(int m) => ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m];
  String _getMonthNameHi(int m) => ['', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर'][m];
}
