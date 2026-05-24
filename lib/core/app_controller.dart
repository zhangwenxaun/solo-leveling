import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';
import 'rules_engine.dart';
import 'storage.dart';

class AppController extends ChangeNotifier {
  AppController._(this._storage);

  final AppStorage _storage;
  late UserProfile profile;
  late BaseStats stats;
  late StatusConditions status;
  List<HabitTracker> habits = [];
  List<InventoryItem> inventory = [];
  List<ShadowSoldier> barracks = [];
  List<String> logs = [];

  static Future<AppController> create() async {
    final storage = await AppStorage.open();
    final controller = AppController._(storage);
    await controller._loadOrSeed();
    return controller;
  }

  Future<void> _loadOrSeed() async {
    profile = _storage.loadProfile() ??
        UserProfile(
          id: 'user_1',
          nickname: 'Shadow',
          currentLevel: 1,
          accumulatedExp: 0,
          currentCoins: 0,
          isWeakened: false,
          hasPenaltyActive: false,
          activePenaltyType: null,
          lastLoginTimestamp: DateTime.now().millisecondsSinceEpoch,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
    stats = _storage.loadStats() ??
        BaseStats(spd: 5, intel: 5, mem: 5, str: 5, sen: 5, agi: 5);
    status = _storage.loadStatus() ??
        StatusConditions(
          eye: 100,
          fatigue: 0,
          continuousScreenTime: 0,
          lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch,
        );
    habits = _storage.loadHabits();
    if (habits.isEmpty) {
      habits = [
        for (final def in [
          ...HabitEngine.dailyTemplates,
          ...HabitEngine.weeklyTemplates,
        ])
          HabitEngine.createFromTemplate(profile.id, def),
      ];
    }
    inventory = _storage.loadInventory();
    barracks = _storage.loadBarracks();
    logs = _storage.loadLog();
    await _applyOfflineGap();
    await _persist();
  }

  Future<void> _applyOfflineGap() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final gapMs = max(0, now - status.lastUpdateTimestamp);
    final gapHours = gapMs / 3600000.0;
    if (gapHours <= 0) return;
    final result = TimerEngineSettlement.calculateSessionOutcome(
      elapsedHours: gapHours,
      activeToggles: const [],
      currentBaseStats: stats,
      currentStatus: status,
      isDailyClear: isDailyClear,
      isHourglassActive: hasItem('greedy_hourglass'),
      isWeakened: profile.isWeakened,
    );
    stats = BaseStats.fromJson(result['baseStats'] as Map<String, dynamic>);
    status = StatusConditions.fromJson(result['status'] as Map<String, dynamic>);
    status.lastUpdateTimestamp = now;
  }

  Future<void> _persist() async {
    await _storage.saveProfile(profile);
    await _storage.saveStats(stats);
    await _storage.saveStatus(status);
    await _storage.saveHabits(habits);
    await _storage.saveInventory(inventory);
    await _storage.saveBarracks(barracks);
    notifyListeners();
  }

  Future<void> addLog(String text) async {
    logs = [text, ...logs].take(20).toList();
    await _storage.saveLog(text);
    notifyListeners();
  }

  Future<void> applyActivity(ToggleType type, double hours) async {
    final result = TimerEngineSettlement.calculateSessionOutcome(
      elapsedHours: hours,
      activeToggles: [type],
      currentBaseStats: stats,
      currentStatus: status,
      isDailyClear: isDailyClear,
      isHourglassActive: hasItem('greedy_hourglass'),
      isWeakened: profile.isWeakened,
    );
    stats = BaseStats.fromJson(result['baseStats'] as Map<String, dynamic>);
    status = StatusConditions.fromJson(result['status'] as Map<String, dynamic>);
    status.lastUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
    profile.currentCoins += ((hours * 5) * (profile.isWeakened ? 0.5 : 1.0)).round();
    await _persist();
    await addLog('${type.name} +${hours.toStringAsFixed(1)}h');
  }

  Future<void> addProgress(String habitCode, double amount) async {
    final habit = habits.firstWhere((h) => h.habitCode == habitCode);
    HabitEngine.applyProgress(habit, amount);
    await _persist();
    await addLog('$habitCode +$amount');
  }

  Future<void> refreshTasks() async {
    for (final habit in habits.where((h) => h.habitType == HabitType.daily)) {
      habit.currentProgress = 0;
      habit.isCompletedToday = false;
      habit.updatedAt = DateTime.now().millisecondsSinceEpoch;
    }
    await _persist();
    await addLog('任务刷新券已生效');
  }

  Future<void> settleDay() async {
    final dailyHabits = habits.where((habit) => habit.habitType == HabitType.daily).toList();
    final missedDaily = dailyHabits.any((habit) => habit.currentProgress < habit.targetValue);
    for (final habit in dailyHabits) {
      final outcome = HabitEngine.settleDay(habit);
      profile.currentCoins += outcome.coins;
      profile.accumulatedExp += outcome.exp;
      for (final loot in outcome.loot) {
        _addItem(loot, 1);
      }
    }
    profile.hasPenaltyActive = missedDaily;
    profile.isWeakened = missedDaily;
    profile.activePenaltyType = missedDaily ? 'daily_miss' : null;
    for (final habit in dailyHabits) {
      habit.currentProgress = 0;
      habit.isCompletedToday = false;
    }
    _levelAdjust();
    await _persist();
    await addLog(missedDaily ? '日结完成，进入虚弱状态' : '日结完成，今日全通');
  }

  Future<void> runBattle() async {
    final result = BattleEngine.runBattle(
      stats: stats,
      dailyClear: isDailyClear,
      weakened: profile.isWeakened,
      hasHourglass: hasItem('greedy_hourglass'),
      hasResetCard: hasItem('king_reborn_break'),
    );
    profile.currentCoins += result.coins;
    profile.accumulatedExp += result.exp;
    for (final item in result.loot) {
      _addItem(item, 1);
    }
    _levelAdjust();
    await _persist();
    for (final line in result.log.reversed) {
      await addLog(line);
    }
  }

  bool get isDailyClear => habits
      .where((h) => h.habitType == HabitType.daily)
      .every((h) => h.isCompletedToday || h.currentProgress >= h.targetValue);

  bool hasItem(String itemId) => inventory.any((i) => i.itemId == itemId && i.quantity > 0);

  void _addItem(String itemId, int quantity) {
    final existing = inventory.where((i) => i.itemId == itemId).toList();
    if (existing.isEmpty) {
      inventory.add(InventoryItem(
        id: '${itemId}_${DateTime.now().microsecondsSinceEpoch}',
        userId: profile.id,
        itemId: itemId,
        quantity: quantity,
      ));
    } else {
      existing.first.quantity += quantity;
    }
  }

  void _levelAdjust() {
    while (profile.accumulatedExp >= expForNextLevel(profile.currentLevel)) {
      profile.accumulatedExp -= expForNextLevel(profile.currentLevel);
      profile.currentLevel += 1;
    }
    while (profile.accumulatedExp < 0 && profile.currentLevel > 1) {
      profile.currentLevel -= 1;
      profile.accumulatedExp += expForNextLevel(profile.currentLevel);
    }
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppControllerScope>();
    return scope!.notifier!;
  }
}
