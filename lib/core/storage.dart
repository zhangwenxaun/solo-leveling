import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStorage {
  AppStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppStorage> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorage._(prefs);
  }

  static const _profileKey = 'profile';
  static const _statsKey = 'stats';
  static const _statusKey = 'status';
  static const _habitsKey = 'habits';
  static const _inventoryKey = 'inventory';
  static const _barracksKey = 'barracks';
  static const _logKey = 'logs';

  UserProfile? loadProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(UserProfile profile) =>
      _prefs.setString(_profileKey, jsonEncode(profile.toJson()));

  BaseStats? loadStats() {
    final raw = _prefs.getString(_statsKey);
    if (raw == null) return null;
    return BaseStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStats(BaseStats stats) =>
      _prefs.setString(_statsKey, jsonEncode(stats.toJson()));

  StatusConditions? loadStatus() {
    final raw = _prefs.getString(_statusKey);
    if (raw == null) return null;
    return StatusConditions.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStatus(StatusConditions status) =>
      _prefs.setString(_statusKey, jsonEncode(status.toJson()));

  List<HabitTracker> loadHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(HabitTracker.fromJson)
        .toList();
  }

  Future<void> saveHabits(List<HabitTracker> habits) =>
      _prefs.setString(_habitsKey, jsonEncode(habits.map((e) => e.toJson()).toList()));

  List<InventoryItem> loadInventory() {
    final raw = _prefs.getString(_inventoryKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(InventoryItem.fromJson)
        .toList();
  }

  Future<void> saveInventory(List<InventoryItem> items) => _prefs.setString(
        _inventoryKey,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );

  List<ShadowSoldier> loadBarracks() {
    final raw = _prefs.getString(_barracksKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(ShadowSoldier.fromJson)
        .toList();
  }

  Future<void> saveBarracks(List<ShadowSoldier> units) => _prefs.setString(
        _barracksKey,
        jsonEncode(units.map((e) => e.toJson()).toList()),
      );

  Future<void> saveLog(String message) async {
    final current = _prefs.getStringList(_logKey) ?? [];
    current.insert(0, message);
    await _prefs.setStringList(_logKey, current.take(20).toList());
  }

  List<String> loadLog() => _prefs.getStringList(_logKey) ?? [];
}
