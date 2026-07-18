import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class ElectricityProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _bills = [];
  String _consumerNumber = '';
  String _discomName = '';
  double _perUnitRate = 0;

  List<Map<String, dynamic>> get bills => _bills;
  String get consumerNumber => _consumerNumber;
  String get discomName => _discomName;
  double get perUnitRate => _perUnitRate;

  Future<void> init() async {
    await loadBills();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await _storage.get(AppConstants.settingsBox, 'electricity_settings');
    if (settings != null && settings is Map) {
      _consumerNumber = settings['consumerNumber'] ?? '';
      _discomName = settings['discomName'] ?? '';
      _perUnitRate = (settings['perUnitRate'] as num?)?.toDouble() ?? 0;
    }
    notifyListeners();
  }

  Future<void> saveSettings({
    required String consumerNumber,
    required String discomName,
    required double perUnitRate,
  }) async {
    _consumerNumber = consumerNumber;
    _discomName = discomName;
    _perUnitRate = perUnitRate;
    await _storage.put(AppConstants.settingsBox, 'electricity_settings', {
      'consumerNumber': consumerNumber,
      'discomName': discomName,
      'perUnitRate': perUnitRate,
    });
    notifyListeners();
  }

  Future<void> loadBills() async {
    final data = await _storage.getAll(AppConstants.electricityBox);
    _bills = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _bills.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> addBill({
    required String date,
    required double prevReading,
    required double currReading,
    required double billAmount,
    String paymentDate = '',
    String paymentMode = '',
  }) async {
    final id = '${date.substring(0, 7).replaceAll('-', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    final units = currReading - prevReading;
    await _storage.put(AppConstants.electricityBox, id, {
      'date': date,
      'prevReading': prevReading,
      'currReading': currReading,
      'units': units,
      'billAmount': billAmount,
      'paymentDate': paymentDate,
      'paymentMode': paymentMode,
    });
    await loadBills();
  }

  Future<void> deleteBill(String id) async {
    await _storage.delete(AppConstants.electricityBox, id);
    await loadBills();
  }

  double get threeMonthAvgUnits {
    if (_bills.length < 3) return 0;
    final recent = _bills.take(3).toList();
    return recent.fold(0.0, (sum, b) => sum + (b['units'] as num).toDouble()) / 3;
  }

  bool get isHighUsage {
    if (_bills.isEmpty || threeMonthAvgUnits == 0) return false;
    final latest = (_bills.first['units'] as num).toDouble();
    return latest > threeMonthAvgUnits * 1.3; // 30% higher
  }

  double get currentMonthSpend {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _bills.where((b) => (b['date'] as String).startsWith(monthStr))
        .fold(0.0, (sum, b) => sum + (b['billAmount'] as num).toDouble());
  }
}
