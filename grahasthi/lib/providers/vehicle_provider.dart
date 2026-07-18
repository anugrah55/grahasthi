import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class VehicleProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _fuelEntries = [];
  List<Map<String, dynamic>> _maintenanceEntries = [];
  Map<String, dynamic> _vehicleInfo = {};

  List<Map<String, dynamic>> get fuelEntries => _fuelEntries;
  List<Map<String, dynamic>> get maintenanceEntries => _maintenanceEntries;
  Map<String, dynamic> get vehicleInfo => _vehicleInfo;

  Future<void> init() async {
    await loadFuelEntries();
    await loadMaintenanceEntries();
    await loadVehicleInfo();
  }

  Future<void> loadFuelEntries() async {
    final data = await _storage.getAll(AppConstants.vehicleFuelBox);
    _fuelEntries = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _fuelEntries.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> loadMaintenanceEntries() async {
    final data = await _storage.getAll(AppConstants.vehicleMaintenanceBox);
    _maintenanceEntries = data.entries.map((e) {
      final val = Map<String, dynamic>.from(e.value as Map);
      val['id'] = e.key;
      return val;
    }).toList();
    _maintenanceEntries.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    notifyListeners();
  }

  Future<void> loadVehicleInfo() async {
    final data = await _storage.get(AppConstants.vehicleInfoBox, 'info');
    if (data != null && data is Map) {
      _vehicleInfo = Map<String, dynamic>.from(data);
    }
    notifyListeners();
  }

  Future<void> saveVehicleInfo({
    String insuranceDate = '',
    String pucExpiry = '',
    int insuranceReminderDays = 30,
    int pucReminderDays = 30,
  }) async {
    _vehicleInfo = {
      'insuranceDate': insuranceDate,
      'pucExpiry': pucExpiry,
      'insuranceReminderDays': insuranceReminderDays,
      'pucReminderDays': pucReminderDays,
    };
    await _storage.put(AppConstants.vehicleInfoBox, 'info', _vehicleInfo);
    notifyListeners();
  }

  Future<void> addFuelEntry({
    required String date,
    required String fuelType,
    required double litres,
    required double amount,
    double odometer = 0,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.vehicleFuelBox, id, {
      'date': date,
      'fuelType': fuelType,
      'litres': litres,
      'amount': amount,
      'odometer': odometer,
    });
    await loadFuelEntries();
  }

  Future<void> deleteFuelEntry(String id) async {
    await _storage.delete(AppConstants.vehicleFuelBox, id);
    await loadFuelEntries();
  }

  Future<void> addMaintenanceEntry({
    required String date,
    required String type,
    required double amount,
    String description = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.put(AppConstants.vehicleMaintenanceBox, id, {
      'date': date,
      'type': type,
      'amount': amount,
      'description': description,
    });
    await loadMaintenanceEntries();
  }

  Future<void> deleteMaintenanceEntry(String id) async {
    await _storage.delete(AppConstants.vehicleMaintenanceBox, id);
    await loadMaintenanceEntries();
  }

  /// Calculate mileage between two consecutive fuel entries
  double? getLastMileage() {
    if (_fuelEntries.length < 2) return null;
    final sorted = List<Map<String, dynamic>>.from(_fuelEntries)
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    final latest = sorted.last;
    final prev = sorted[sorted.length - 2];
    final odoLatest = (latest['odometer'] as num?)?.toDouble() ?? 0;
    final odoPrev = (prev['odometer'] as num?)?.toDouble() ?? 0;
    final litres = (latest['litres'] as num).toDouble();
    if (odoLatest > 0 && odoPrev > 0 && litres > 0) {
      return (odoLatest - odoPrev) / litres;
    }
    return null;
  }

  double get currentMonthFuelSpend {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _fuelEntries.where((e) => (e['date'] as String).startsWith(monthStr))
        .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  double get currentMonthMaintenanceSpend {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _maintenanceEntries.where((e) => (e['date'] as String).startsWith(monthStr))
        .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  double get totalCurrentMonthSpend => currentMonthFuelSpend + currentMonthMaintenanceSpend;

  double get annualSpend {
    final now = DateTime.now();
    final yearStr = '${now.year}';
    final fuelTotal = _fuelEntries.where((e) => (e['date'] as String).startsWith(yearStr))
        .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
    final maintTotal = _maintenanceEntries.where((e) => (e['date'] as String).startsWith(yearStr))
        .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
    return fuelTotal + maintTotal;
  }
}
