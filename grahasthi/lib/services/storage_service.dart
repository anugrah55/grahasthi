import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  Future<Box> openBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }
    return await Hive.openBox(name);
  }

  // === Generic CRUD Operations ===

  Future<void> put(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  Future<dynamic> get(String boxName, String key, {dynamic defaultValue}) async {
    final box = await openBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  Future<Map<String, dynamic>> getAll(String boxName) async {
    final box = await openBox(boxName);
    final map = <String, dynamic>{};
    for (var key in box.keys) {
      map[key.toString()] = box.get(key);
    }
    return map;
  }

  Future<List<MapEntry<String, dynamic>>> getAllEntries(String boxName) async {
    final box = await openBox(boxName);
    final entries = <MapEntry<String, dynamic>>[];
    for (var key in box.keys) {
      entries.add(MapEntry(key.toString(), box.get(key)));
    }
    return entries;
  }

  Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }

  // === Query helpers ===

  /// Get all entries for a specific month (keys starting with YYYY_MM)
  Future<Map<String, dynamic>> getMonthEntries(
    String boxName,
    int year,
    int month,
  ) async {
    final prefix = '${year}_${month.toString().padLeft(2, '0')}';
    final box = await openBox(boxName);
    final result = <String, dynamic>{};
    for (var key in box.keys) {
      if (key.toString().startsWith(prefix)) {
        result[key.toString()] = box.get(key);
      }
    }
    return result;
  }

  /// Get all entries with a specific prefix
  Future<Map<String, dynamic>> getByPrefix(
    String boxName,
    String prefix,
  ) async {
    final box = await openBox(boxName);
    final result = <String, dynamic>{};
    for (var key in box.keys) {
      if (key.toString().startsWith(prefix)) {
        result[key.toString()] = box.get(key);
      }
    }
    return result;
  }

  // === Backup/Restore ===

  Future<Map<String, dynamic>> exportAllData() async {
    final allBoxNames = [
      AppConstants.milkBox,
      AppConstants.milkTypesBox,
      AppConstants.maidsBox,
      AppConstants.maidAttendanceBox,
      AppConstants.maidAdvancesBox,
      AppConstants.groceryBox,
      AppConstants.shopsBox,
      AppConstants.creditBox,
      AppConstants.lpgBox,
      AppConstants.electricityBox,
      AppConstants.waterBox,
      AppConstants.watchmenBox,
      AppConstants.watchmanAttendanceBox,
      AppConstants.vehicleFuelBox,
      AppConstants.vehicleMaintenanceBox,
      AppConstants.vehicleInfoBox,
      AppConstants.emiBox,
      AppConstants.emiPaymentsBox,
      AppConstants.festivalsBox,
      AppConstants.festivalExpensesBox,
      AppConstants.settingsBox,
    ];

    final backup = <String, dynamic>{};
    for (final boxName in allBoxNames) {
      backup[boxName] = await getAll(boxName);
    }
    backup['_backup_date'] = DateTime.now().toIso8601String();
    backup['_app_version'] = AppConstants.appVersion;
    return backup;
  }

  Future<void> importAllData(Map<String, dynamic> backup) async {
    for (final entry in backup.entries) {
      if (entry.key.startsWith('_')) continue; // skip metadata keys
      if (entry.value is Map) {
        final box = await openBox(entry.key);
        await box.clear();
        for (final dataEntry in (entry.value as Map).entries) {
          await box.put(dataEntry.key, dataEntry.value);
        }
      }
    }
  }
}
