import 'dart:math';

enum ToggleType { study, screen, detox, lookFar, sleep }

enum HabitType { daily, weekly }

enum EvolutionState { normal, evolved, capped, harvested }

class UserProfile {
  UserProfile({
    required this.id,
    required this.nickname,
    required this.currentLevel,
    required this.accumulatedExp,
    required this.currentCoins,
    required this.isWeakened,
    required this.hasPenaltyActive,
    required this.activePenaltyType,
    required this.lastLoginTimestamp,
    required this.createdAt,
  });

  final String id;
  final String nickname;
  int currentLevel;
  int accumulatedExp;
  int currentCoins;
  bool isWeakened;
  bool hasPenaltyActive;
  String? activePenaltyType;
  int lastLoginTimestamp;
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'currentLevel': currentLevel,
        'accumulatedExp': accumulatedExp,
        'currentCoins': currentCoins,
        'isWeakened': isWeakened,
        'hasPenaltyActive': hasPenaltyActive,
        'activePenaltyType': activePenaltyType,
        'lastLoginTimestamp': lastLoginTimestamp,
        'createdAt': createdAt,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        currentLevel: json['currentLevel'] as int,
        accumulatedExp: json['accumulatedExp'] as int,
        currentCoins: json['currentCoins'] as int,
        isWeakened: json['isWeakened'] as bool,
        hasPenaltyActive: json['hasPenaltyActive'] as bool,
        activePenaltyType: json['activePenaltyType'] as String?,
        lastLoginTimestamp: json['lastLoginTimestamp'] as int,
        createdAt: json['createdAt'] as int,
      );
}

class BaseStats {
  BaseStats({
    required this.spd,
    required this.intel,
    required this.mem,
    required this.str,
    required this.sen,
    required this.agi,
  });

  double spd;
  double intel;
  double mem;
  double str;
  double sen;
  double agi;

  Map<String, dynamic> toJson() => {
        'spd': spd,
        'intel': intel,
        'mem': mem,
        'str': str,
        'sen': sen,
        'agi': agi,
      };

  factory BaseStats.fromJson(Map<String, dynamic> json) => BaseStats(
        spd: (json['spd'] as num).toDouble(),
        intel: (json['intel'] as num).toDouble(),
        mem: (json['mem'] as num).toDouble(),
        str: (json['str'] as num).toDouble(),
        sen: (json['sen'] as num).toDouble(),
        agi: (json['agi'] as num).toDouble(),
      );
}

class StatusConditions {
  StatusConditions({
    required this.eye,
    required this.fatigue,
    required this.continuousScreenTime,
    required this.lastUpdateTimestamp,
  });

  double eye;
  double fatigue;
  double continuousScreenTime;
  int lastUpdateTimestamp;

  Map<String, dynamic> toJson() => {
        'eye': eye,
        'fatigue': fatigue,
        'continuousScreenTime': continuousScreenTime,
        'lastUpdateTimestamp': lastUpdateTimestamp,
      };

  factory StatusConditions.fromJson(Map<String, dynamic> json) => StatusConditions(
        eye: (json['eye'] as num).toDouble(),
        fatigue: (json['fatigue'] as num).toDouble(),
        continuousScreenTime: (json['continuousScreenTime'] as num).toDouble(),
        lastUpdateTimestamp: json['lastUpdateTimestamp'] as int,
      );
}

class HabitTracker {
  HabitTracker({
    required this.id,
    required this.userId,
    required this.habitCode,
    required this.habitType,
    required this.targetValue,
    required this.currentProgress,
    required this.streakDays,
    required this.evolutionState,
    required this.isCompletedToday,
    required this.updatedAt,
    required this.rewardCoins,
  });

  final String id;
  final String userId;
  final String habitCode;
  final HabitType habitType;
  double targetValue;
  double currentProgress;
  int streakDays;
  EvolutionState evolutionState;
  bool isCompletedToday;
  int updatedAt;
  int rewardCoins;

  bool get isCapped => evolutionState == EvolutionState.capped;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'habitCode': habitCode,
        'habitType': habitType.name,
        'targetValue': targetValue,
        'currentProgress': currentProgress,
        'streakDays': streakDays,
        'evolutionState': evolutionState.name,
        'isCompletedToday': isCompletedToday,
        'updatedAt': updatedAt,
        'rewardCoins': rewardCoins,
      };

  factory HabitTracker.fromJson(Map<String, dynamic> json) => HabitTracker(
        id: json['id'] as String,
        userId: json['userId'] as String,
        habitCode: json['habitCode'] as String,
        habitType: HabitType.values.byName(json['habitType'] as String),
        targetValue: (json['targetValue'] as num).toDouble(),
        currentProgress: (json['currentProgress'] as num).toDouble(),
        streakDays: json['streakDays'] as int,
        evolutionState:
            EvolutionState.values.byName(json['evolutionState'] as String),
        isCompletedToday: json['isCompletedToday'] as bool,
        updatedAt: json['updatedAt'] as int,
        rewardCoins: json['rewardCoins'] as int,
      );
}

class InventoryItem {
  InventoryItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.quantity,
  });

  final String id;
  final String userId;
  final String itemId;
  int quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'itemId': itemId,
        'quantity': quantity,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        userId: json['userId'] as String,
        itemId: json['itemId'] as String,
        quantity: json['quantity'] as int,
      );
}

class ShadowSoldier {
  ShadowSoldier({
    required this.id,
    required this.userId,
    required this.soldierType,
    required this.level,
    required this.deployedSlot,
    required this.unlockedAt,
  });

  final String id;
  final String userId;
  final String soldierType;
  int level;
  int? deployedSlot;
  final int unlockedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'soldierType': soldierType,
        'level': level,
        'deployedSlot': deployedSlot,
        'unlockedAt': unlockedAt,
      };

  factory ShadowSoldier.fromJson(Map<String, dynamic> json) => ShadowSoldier(
        id: json['id'] as String,
        userId: json['userId'] as String,
        soldierType: json['soldierType'] as String,
        level: json['level'] as int,
        deployedSlot: json['deployedSlot'] as int?,
        unlockedAt: json['unlockedAt'] as int,
      );
}

class BattleCard {
  BattleCard({
    required this.id,
    required this.title,
    required this.kind,
    required this.power,
    required this.shadowCost,
    required this.empowered,
    required this.description,
  });

  final String id;
  final String title;
  final String kind;
  final double power;
  final int shadowCost;
  final bool empowered;
  final String description;
}

class BattleResult {
  BattleResult({
    required this.win,
    required this.log,
    required this.coins,
    required this.exp,
    required this.loot,
  });

  final bool win;
  final List<String> log;
  final int coins;
  final int exp;
  final List<String> loot;
}

class CardUnit {
  CardUnit({
    required this.name,
    required this.hp,
    required this.attack,
    required this.magicAttack,
    required this.speed,
    required this.critRate,
  });

  final String name;
  double hp;
  double attack;
  double magicAttack;
  double speed;
  double critRate;
}

class TaskDefinition {
  TaskDefinition({
    required this.code,
    required this.name,
    required this.type,
    required this.unitLabel,
    required this.target,
    required this.baseRewardCoins,
    required this.baseRewardExp,
    required this.minValue,
    required this.maxValue,
  });

  final String code;
  final String name;
  final HabitType type;
  final String unitLabel;
  final double target;
  final int baseRewardCoins;
  final int baseRewardExp;
  final double minValue;
  final double maxValue;
}

double clampDouble(double value, [double min = 0, double max = 100]) =>
    value.clamp(min, max).toDouble();

int expForNextLevel(int level) => (100 * pow(level, 1.5)).round();
