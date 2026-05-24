import 'dart:math';

import 'models.dart';

class TimerEngineSettlement {
  static Map<String, dynamic> calculateSessionOutcome({
    required double elapsedHours,
    required List<ToggleType> activeToggles,
    required BaseStats currentBaseStats,
    required StatusConditions currentStatus,
    required bool isDailyClear,
    required bool isHourglassActive,
    required bool isWeakened,
  }) {
    final stats = BaseStats(
      spd: currentBaseStats.spd,
      intel: currentBaseStats.intel,
      mem: currentBaseStats.mem,
      str: currentBaseStats.str,
      sen: currentBaseStats.sen,
      agi: currentBaseStats.agi,
    );
    final status = StatusConditions(
      eye: currentStatus.eye,
      fatigue: currentStatus.fatigue,
      continuousScreenTime: currentStatus.continuousScreenTime,
      lastUpdateTimestamp: currentStatus.lastUpdateTimestamp,
    );

    final fatigueMultiplier = status.fatigue >= 80 && status.fatigue < 100 ? 0.5 : 1.0;
    final gainMultiplier =
        fatigueMultiplier * (isWeakened ? 0.5 : 1.0) * (isHourglassActive ? 2.0 : 1.0);
    double fatigueDelta = 0;

    if (activeToggles.contains(ToggleType.study)) {
      final studyMinutes = elapsedHours * 60;
      final unit = (studyMinutes / 45).floor();
      stats.intel += (unit * 0.5 + (elapsedHours >= 2 ? 1 : 0)) * gainMultiplier;
      stats.agi += elapsedHours * 0.48 * gainMultiplier;
      fatigueDelta += elapsedHours * 5;
    }

    if (activeToggles.contains(ToggleType.screen)) {
      stats.agi += elapsedHours * 0.4 * gainMultiplier;
      fatigueDelta += elapsedHours * 4;

      final nextScreen = _applyScreenDamage(
        eye: status.eye,
        fatigue: fatigueDelta,
        continuousScreenTime: status.continuousScreenTime,
        elapsedHours: elapsedHours,
      );
      status.eye = nextScreen.eye;
      status.continuousScreenTime = nextScreen.continuousScreenTime;
      fatigueDelta = nextScreen.fatigueDelta;
    }

    if (activeToggles.contains(ToggleType.detox)) {
      stats.sen += (elapsedHours * 2).floorToDouble() * gainMultiplier;
      fatigueDelta -= elapsedHours * 10;
    }

    if (activeToggles.contains(ToggleType.lookFar)) {
      status.eye = clampDouble(status.eye + elapsedHours * 18);
      fatigueDelta -= elapsedHours * 5;
      if (elapsedHours >= 10 / 60) {
        status.continuousScreenTime = 0;
      }
    }

    if (activeToggles.contains(ToggleType.sleep)) {
      fatigueDelta -= elapsedHours * 20;
      status.eye = clampDouble(status.eye + elapsedHours * 8);
    }

    if (activeToggles.isEmpty) {
      fatigueDelta -= (elapsedHours.floor() * 2).toDouble();
      status.continuousScreenTime = 0;
    }

    status.fatigue = clampDouble(status.fatigue + fatigueDelta, 0, 100);
    status.eye = clampDouble(status.eye);
    status.continuousScreenTime = max(0, status.continuousScreenTime);

    final bonus = isDailyClear ? 1.2 : 1.0;
    return {
      'baseStats': stats.toJson(),
      'status': status.toJson(),
      'meta': {
        'dailyBonus': bonus,
        'hourglass': isHourglassActive,
      }
    };
  }

  static _ScreenResult _applyScreenDamage({
    required double eye,
    required double fatigue,
    required double continuousScreenTime,
    required double elapsedHours,
  }) {
    var tempEye = eye;
    var tempFatigue = fatigue;
    var tempContinuous = continuousScreenTime;
    final steps = max(1, (elapsedHours * 12).round());
    final stepHours = elapsedHours / steps;
    for (var i = 0; i < steps; i++) {
      tempContinuous += stepHours;
      final total = tempContinuous;
      final hourlyDmgRate = total <= 2
          ? 2.0
          : total <= 4
              ? 5.0
              : 10.0;
      final stepEyeDmg = hourlyDmgRate * stepHours;
      if (tempEye > 0) {
        final after = tempEye - stepEyeDmg;
        if (after >= 0) {
          tempEye = after;
        } else {
          final overflow = -after;
          tempEye = 0;
          tempFatigue += overflow * 1.0 + stepHours * 10.0;
        }
      } else {
        tempFatigue += stepEyeDmg * 1.0 + stepHours * 10.0;
      }
    }
    return _ScreenResult(
      eye: tempEye,
      fatigueDelta: tempFatigue,
      continuousScreenTime: tempContinuous,
    );
  }
}

class _ScreenResult {
  _ScreenResult({
    required this.eye,
    required this.fatigueDelta,
    required this.continuousScreenTime,
  });

  final double eye;
  final double fatigueDelta;
  final double continuousScreenTime;
}

class HabitEngine {
  static final List<TaskDefinition> dailyTemplates = [
    TaskDefinition(
      code: 'far_look',
      name: '远望',
      type: HabitType.daily,
      unitLabel: 'min',
      target: 10,
      baseRewardCoins: 20,
      baseRewardExp: 30,
      minValue: 1,
      maxValue: 120,
    ),
    TaskDefinition(
      code: 'vocab',
      name: '背单词',
      type: HabitType.daily,
      unitLabel: 'word',
      target: 20,
      baseRewardCoins: 30,
      baseRewardExp: 40,
      minValue: 5,
      maxValue: 50,
    ),
    TaskDefinition(
      code: 'deep_study',
      name: '深度学习',
      type: HabitType.daily,
      unitLabel: 'min',
      target: 60,
      baseRewardCoins: 50,
      baseRewardExp: 80,
      minValue: 30,
      maxValue: 180,
    ),
  ];

  static final List<TaskDefinition> weeklyTemplates = [
    TaskDefinition(
      code: 'speed_break',
      name: '速度突破',
      type: HabitType.weekly,
      unitLabel: 'km',
      target: 5,
      baseRewardCoins: 120,
      baseRewardExp: 160,
      minValue: 1,
      maxValue: 20,
    ),
    TaskDefinition(
      code: 'core_training',
      name: '核心训练',
      type: HabitType.weekly,
      unitLabel: 'min',
      target: 40,
      baseRewardCoins: 100,
      baseRewardExp: 140,
      minValue: 20,
      maxValue: 180,
    ),
  ];

  static List<TaskDefinition> get allTemplates => [
        ...dailyTemplates,
        ...weeklyTemplates,
      ];

  static TaskDefinition definitionFor(String code) {
    return allTemplates.firstWhere((task) => task.code == code);
  }

  static HabitTracker createFromTemplate(String userId, TaskDefinition def) {
    return HabitTracker(
      id: '${def.code}_${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      habitCode: def.code,
      habitType: def.type,
      targetValue: def.target,
      currentProgress: 0,
      streakDays: 0,
      evolutionState: EvolutionState.normal,
      isCompletedToday: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      rewardCoins: def.baseRewardCoins,
    );
  }

  static void applyProgress(
    HabitTracker habit,
    double amount,
  ) {
    habit.currentProgress += amount;
    habit.isCompletedToday = habit.currentProgress >= habit.targetValue;
    habit.updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  static HabitOutcome settleDay(HabitTracker habit) {
    final completed = habit.currentProgress >= habit.targetValue;
    if (completed) {
      habit.streakDays = habit.streakDays < 0 ? 1 : habit.streakDays + 1;
    } else {
      habit.streakDays = habit.streakDays > 0 ? -1 : habit.streakDays - 1;
    }

    var coins = completed ? habit.rewardCoins : 0;
    var exp = completed ? (habit.rewardCoins * 1.5).round() : -max(20, habit.rewardCoins ~/ 2);
    final loot = <String>[];
    final cap = _capFor(habit.habitCode);

    if (completed && habit.streakDays >= 3) {
      habit.evolutionState = EvolutionState.evolved;
      habit.targetValue = min(habit.targetValue * 1.1, cap);
      if (habit.targetValue >= cap) {
        habit.evolutionState = EvolutionState.capped;
      }
      coins = (coins * 1.5).round();
      if (Random().nextDouble() < 0.2) {
        loot.add('专属道具');
      }
    }

    if (!completed && habit.streakDays <= -2 && habit.targetValue > 0) {
      habit.targetValue = max(habit.targetValue * 0.9, _floorTarget(habit.habitCode));
      habit.rewardCoins = max(10, (habit.rewardCoins * 0.8).round());
    }

    if (completed && habit.evolutionState == EvolutionState.capped && habit.streakDays >= 5) {
      habit.evolutionState = EvolutionState.harvested;
      habit.targetValue = _initialTarget(habit.habitCode);
      coins += 500;
      loot.add(Random().nextBool()
          ? 'daily_quest_exemption'
          : 'demon_castle_invitation');
    }

    if (habit.evolutionState == EvolutionState.capped &&
        completed &&
        habit.streakDays >= 6 &&
        Random().nextBool()) {
      habit.targetValue = max(_floorTarget(habit.habitCode) / 2, habit.targetValue / 2);
    }

    return HabitOutcome(
      completed: completed,
      coins: coins,
      exp: exp,
      loot: loot,
    );
  }

  static double _floorTarget(String code) {
    switch (code) {
      case 'vocab':
        return 20;
      case 'deep_study':
        return 60;
      default:
        return 10;
    }
  }

  static double _initialTarget(String code) {
    switch (code) {
      case 'vocab':
        return 20;
      case 'deep_study':
        return 60;
      case 'speed_break':
        return 5;
      case 'core_training':
        return 40;
      default:
        return 10;
    }
  }

  static double _capFor(String code) {
    switch (code) {
      case 'vocab':
        return 50;
      case 'deep_study':
        return 180;
      default:
        return 999;
    }
  }
}

class HabitOutcome {
  HabitOutcome({
    required this.completed,
    required this.coins,
    required this.exp,
    required this.loot,
  });

  final bool completed;
  final int coins;
  final int exp;
  final List<String> loot;
}

class BattleEngine {
  static BattleResult runBattle({
    required BaseStats stats,
    required bool dailyClear,
    required bool weakened,
    required bool hasHourglass,
    required bool hasResetCard,
  }) {
    final log = <String>[];
    final player = CardUnit(
      name: '本命卡',
      hp: stats.str * 10,
      attack: stats.str * 1.5,
      magicAttack: stats.intel * 1.5,
      speed: stats.spd,
      critRate: stats.agi * 0.2,
    );
    final enemy = CardUnit(
      name: '门之守卫',
      hp: weakened ? 220 : 300,
      attack: weakened ? 8 : 16,
      magicAttack: 0,
      speed: 8,
      critRate: 5,
    );

    final deck = <BattleCard>[
      if (hasResetCard)
        BattleCard(
          id: 'king_reborn_break',
          title: '君王转生·破灭斩',
          kind: 'special',
          power: 2.0,
          shadowCost: 0,
          empowered: true,
          description: '削减Boss 50%最大生命值',
        ),
      BattleCard(
        id: 'slash',
        title: '斩击',
        kind: 'physical',
        power: 1.0,
        shadowCost: 0,
        empowered: false,
        description: '物理单体伤害',
      ),
      BattleCard(
        id: 'fire',
        title: '冥火',
        kind: 'magic',
        power: 1.2,
        shadowCost: 0,
        empowered: false,
        description: '魔法伤害',
      ),
      BattleCard(
        id: 'shadow',
        title: '影袭',
        kind: 'physical',
        power: 1.4,
        shadowCost: 10,
        empowered: false,
        description: '带暗影值消耗',
      ),
      BattleCard(
        id: 'empower',
        title: '今日强化牌',
        kind: 'special',
        power: 1.8,
        shadowCost: 0,
        empowered: true,
        description: '本场强化',
      ),
    ];

    var round = 1;
    var bonusApplied = false;
    while (round <= 5 && player.hp > 0 && enemy.hp > 0) {
      log.add('回合 $round 抽 3 打 1');
      final hand = deck.skip((round - 1) % deck.length).take(3).toList();
      final card = hand.first;
      log.add('打出 ${card.title}');
      var damage = card.kind == 'magic' ? player.magicAttack : player.attack;
      damage *= card.power;
      if (card.empowered || hasHourglass) {
        damage *= 1.5;
        bonusApplied = true;
      }
      if (card.id == 'king_reborn_break') {
        enemy.hp -= enemy.hp * 0.5;
        log.add('破灭斩触发，Boss 生命削减 50%');
      } else {
        enemy.hp -= damage;
      }
      if (enemy.hp <= 0) break;
      player.hp -= enemy.attack * (weakened ? 0.6 : 1.0);
      log.add('敌方反击，玩家血量 ${player.hp.toStringAsFixed(1)}');
      round += 1;
    }

    final win = enemy.hp <= 0 && player.hp > 0;
    final baseCoins = win ? 120 : 30;
    final coins = ((baseCoins * (dailyClear ? 1.2 : 1.0)) * (weakened ? 0.5 : 1.0)).round();
    final exp = win ? 180 : 20;
    final loot = <String>[];
    if (win) {
      loot.add('基础奖励');
      if (hasHourglass || bonusApplied) {
        loot.add('额外掉落');
      }
    }
    log.add(win ? '胜利' : '失败');
    return BattleResult(win: win, log: log, coins: coins, exp: exp, loot: loot);
  }
}
