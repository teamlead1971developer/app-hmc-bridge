import 'package:flutter/material.dart';

enum NoteLayer { top, heart, base }

extension NoteLayerX on NoteLayer {
  String get label => switch (this) {
        NoteLayer.top => 'TOP NOTE',
        NoteLayer.heart => 'HEART NOTE',
        NoteLayer.base => 'BASE NOTE',
      };

  String get groupLabel => switch (this) {
        NoteLayer.top => 'TOP NOTES',
        NoteLayer.heart => 'HEART NOTES',
        NoteLayer.base => 'BASE NOTES',
      };

  int get unlockCost => switch (this) {
        NoteLayer.top => 500,
        NoteLayer.heart => 800,
        NoteLayer.base => 1200,
      };

  String get shortLabel => switch (this) {
        NoteLayer.top => 'TOP',
        NoteLayer.heart => 'HEART',
        NoteLayer.base => 'BASE',
      };

  Color get accentColor => switch (this) {
        NoteLayer.top => const Color(0xFFDCC94C),
        NoteLayer.heart => const Color(0xFFC97B8F),
        NoteLayer.base => const Color(0xFF8B5E3C),
      };
}

enum GameSection { table, shelf, journal, ranks, redeem, upgrades }

enum IngredientRarity { common, uncommon, rare }

extension IngredientRarityX on IngredientRarity {
  String get label => switch (this) {
        IngredientRarity.common => 'COMMON',
        IngredientRarity.uncommon => 'UNCOMMON',
        IngredientRarity.rare => 'RARE',
      };

  Color get tagColor => switch (this) {
        IngredientRarity.common => const Color(0xFF6E8B4E),
        IngredientRarity.uncommon => const Color(0xFFE8A33D),
        IngredientRarity.rare => const Color(0xFFAC0F0D),
      };

  Color get tagTextColor => switch (this) {
        IngredientRarity.uncommon => const Color(0xFF3A2618),
        IngredientRarity.common => const Color(0xFFF3E5C7),
        IngredientRarity.rare => const Color(0xFFF3E5C7),
      };

  int get unlockCost => switch (this) {
        IngredientRarity.common => 500,
        IngredientRarity.uncommon => 800,
        IngredientRarity.rare => 1200,
      };
}

class ScentProfileBar {
  const ScentProfileBar({
    required this.label,
    required this.percent,
    required this.color1,
    required this.color2,
  });

  final String label;
  final int percent;
  final Color color1;
  final Color color2;
}

class GameIngredient {
  const GameIngredient({
    required this.name,
    required this.layer,
    required this.color,
    required this.rarity,
    required this.flavorText,
    required this.profile,
    required this.personalityTags,
    required this.pairsWith,
    this.owned = false,
    this.qty = 0,
  });

  final String name;
  final NoteLayer layer;
  final Color color;
  final IngredientRarity rarity;
  final String flavorText;
  final List<ScentProfileBar> profile;
  final List<(String label, Color color)> personalityTags;
  final List<(String name, Color color)> pairsWith;
  final bool owned;
  final int qty;

  GameIngredient copyWith({bool? owned, int? qty}) {
    return GameIngredient(
      name: name,
      layer: layer,
      color: color,
      rarity: rarity,
      flavorText: flavorText,
      profile: profile,
      personalityTags: personalityTags,
      pairsWith: pairsWith,
      owned: owned ?? this.owned,
      qty: qty ?? this.qty,
    );
  }

  String get rarityLabel => rarity.label;

  int get unlockCost => rarity.unlockCost;
}

class DiscoveredScent {
  const DiscoveredScent({
    required this.name,
    required this.notes,
    required this.bestMatch,
    required this.outcomeRarity,
    required this.color1,
    required this.color2,
  });

  final String name;
  final String notes;
  final int bestMatch;
  final OutcomeRarity outcomeRarity;
  final Color color1;
  final Color color2;
}

class RedeemItem {
  const RedeemItem({
    required this.name,
    required this.description,
    required this.cost,
    required this.color,
    required this.glyph,
    this.owned = false,
  });

  final String name;
  final String description;
  final int cost;
  final Color color;
  final String glyph;
  final bool owned;

  RedeemItem copyWith({bool? owned}) {
    return RedeemItem(
      name: name,
      description: description,
      cost: cost,
      color: color,
      glyph: glyph,
      owned: owned ?? this.owned,
    );
  }
}

class RedeemHistoryEntry {
  const RedeemHistoryEntry({
    required this.itemName,
    required this.description,
    required this.cost,
    required this.redeemedAt,
    required this.glyph,
    required this.color,
  });

  final String itemName;
  final String description;
  final int cost;
  final DateTime redeemedAt;
  final String glyph;
  final Color color;

  factory RedeemHistoryEntry.fromItem(RedeemItem item, DateTime redeemedAt) {
    return RedeemHistoryEntry(
      itemName: item.name,
      description: item.description,
      cost: item.cost,
      redeemedAt: redeemedAt,
      glyph: item.glyph,
      color: item.color,
    );
  }
}

enum UpgradeTier { standard, premium }

class GameUpgrade {
  const GameUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.cost,
    required this.color,
    required this.glyph,
    required this.currentLevel,
    required this.maxLevel,
  });

  final String id;
  final String name;
  final String description;
  final UpgradeTier tier;
  final int cost;
  final Color color;
  final String glyph;
  final int currentLevel;
  final int maxLevel;

  bool get isMaxed => currentLevel >= maxLevel;

  String get levelLabel => 'LV $currentLevel / $maxLevel';

  GameUpgrade copyWith({int? currentLevel}) {
    return GameUpgrade(
      id: id,
      name: name,
      description: description,
      tier: tier,
      cost: cost,
      color: color,
      glyph: glyph,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel,
    );
  }
}

class ScoreboardRow {
  const ScoreboardRow({
    required this.rank,
    required this.name,
    required this.scent,
    required this.score,
    required this.reward,
  });

  final int rank;
  final String name;
  final String scent;
  final String score;
  final String reward;

  bool get isTopThree => rank <= 3;
}

class BlendResult {
  const BlendResult({
    required this.scentName,
    required this.notesLine,
    required this.matchPercent,
    required this.playScore,
    required this.coinReward,
    required this.bridgeCoinReward,
    required this.outcomeRarity,
    required this.isNew,
    required this.bottleColor1,
    required this.bottleColor2,
    required this.stars,
  });

  final String scentName;
  final String notesLine;
  final int matchPercent;
  final int playScore;
  final int coinReward;
  final int bridgeCoinReward;
  final OutcomeRarity outcomeRarity;
  final bool isNew;
  final Color bottleColor1;
  final Color bottleColor2;
  final int stars;
}

enum OutcomeRarity { common, uncommon, rare, legendary, mystic }

extension OutcomeRarityX on OutcomeRarity {
  String get label => switch (this) {
        OutcomeRarity.common => 'COMMON',
        OutcomeRarity.uncommon => 'UNCOMMON',
        OutcomeRarity.rare => 'RARE',
        OutcomeRarity.legendary => 'LEGENDARY',
        OutcomeRarity.mystic => 'MYSTIC',
      };

  Color get tagColor => switch (this) {
        OutcomeRarity.common => const Color(0xFF6E8B4E),
        OutcomeRarity.uncommon => const Color(0xFFE8A33D),
        OutcomeRarity.rare => const Color(0xFFAC0F0D),
        OutcomeRarity.legendary => const Color(0xFFB8860B),
        OutcomeRarity.mystic => const Color(0xFF6B5B95),
      };

  Color get tagTextColor => switch (this) {
        OutcomeRarity.uncommon => const Color(0xFF3A2618),
        OutcomeRarity.common => const Color(0xFFF3E5C7),
        OutcomeRarity.rare => const Color(0xFFF3E5C7),
        OutcomeRarity.legendary => const Color(0xFF3A2618),
        OutcomeRarity.mystic => const Color(0xFFF3E5C7),
      };

  int get bridgeCoinReward => switch (this) {
        OutcomeRarity.legendary => 5,
        OutcomeRarity.mystic => 10,
        OutcomeRarity.common => 0,
        OutcomeRarity.uncommon => 0,
        OutcomeRarity.rare => 0,
      };

  /// Min/max blend wait for scaled tiers; [fixedBlendWait] for legendary/mystic.
  (Duration min, Duration max) get scaledBlendWaitRange => switch (this) {
        OutcomeRarity.common => (
            const Duration(minutes: 30),
            const Duration(hours: 1),
          ),
        OutcomeRarity.uncommon => (
            const Duration(hours: 1, minutes: 30),
            const Duration(hours: 3),
          ),
        OutcomeRarity.rare => (
            const Duration(hours: 2, minutes: 30),
            const Duration(hours: 4),
          ),
        OutcomeRarity.legendary => (
            const Duration(hours: 4, minutes: 30),
            const Duration(hours: 5),
          ),
        OutcomeRarity.mystic => (
            const Duration(hours: 8),
            const Duration(hours: 8),
          ),
      };

  Duration? get fixedBlendWait => switch (this) {
        OutcomeRarity.legendary => null,
        OutcomeRarity.mystic => const Duration(hours: 8),
        OutcomeRarity.common => null,
        OutcomeRarity.uncommon => null,
        OutcomeRarity.rare => null,
      };

  /// Match band used to interpolate wait within a scaled tier.
  (int minMatch, int maxMatch) get tierMatchBand => switch (this) {
        OutcomeRarity.common => (60, 74),
        OutcomeRarity.uncommon => (75, 89),
        OutcomeRarity.rare => (90, 93),
        OutcomeRarity.legendary => (94, 97),
        OutcomeRarity.mystic => (98, 98),
      };

  Duration blendWaitFor(int matchPercent) {
    final fixed = fixedBlendWait;
    if (fixed != null) return fixed;

    final (waitMin, waitMax) = scaledBlendWaitRange;
    final (bandMin, bandMax) = tierMatchBand;
    final bandSpan = (bandMax - bandMin).clamp(1, 100);
    final progress = ((matchPercent - bandMin) / bandSpan).clamp(0.0, 1.0);
    final spanMs = waitMax.inMilliseconds - waitMin.inMilliseconds;
    final waitMs = waitMin.inMilliseconds + (spanMs * progress).round();
    return Duration(milliseconds: waitMs);
  }
}

OutcomeRarity outcomeRarityFromMatch(int matchPercent) {
  if (matchPercent >= 98) return OutcomeRarity.mystic;
  if (matchPercent >= 94) return OutcomeRarity.legendary;
  if (matchPercent >= 90) return OutcomeRarity.rare;
  if (matchPercent >= 75) return OutcomeRarity.uncommon;
  return OutcomeRarity.common;
}

OutcomeRarity maxOutcomeRarity(OutcomeRarity a, OutcomeRarity b) {
  return a.index >= b.index ? a : b;
}

class ActiveBlend {
  const ActiveBlend({
    required this.startedAt,
    required this.completesAt,
    required this.result,
    required this.outcomeRarity,
  });

  final DateTime startedAt;
  final DateTime completesAt;
  final BlendResult result;
  final OutcomeRarity outcomeRarity;

  bool get isReady => DateTime.now().isAfter(completesAt);

  Duration get remaining {
    final left = completesAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  double get progress {
    final total = completesAt.difference(startedAt);
    if (total.inMilliseconds <= 0) return 1;
    final elapsed = DateTime.now().difference(startedAt);
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }
}

class CustomerOrder {
  const CustomerOrder({
    required this.customerInitial,
    required this.customerName,
    required this.request,
    required this.tags,
  });

  final String customerInitial;
  final String customerName;
  final String request;
  final List<(String label, Color color)> tags;
}
