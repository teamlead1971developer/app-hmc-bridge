import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import 'game_mock_data.dart';

String formatBlendWait(Duration duration) {
  if (duration.inSeconds <= 0) return '0s';
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  if (duration.inMinutes >= 1) return '${duration.inMinutes}m';
  return '${duration.inSeconds}s';
}

class GameState extends ChangeNotifier {
  GameState._() {
    _seedData();
  }

  int coins = GameMockData.initialCoins;
  int bridgeCoins = GameMockData.initialBridgeCoins;

  CustomerOrder get currentOrder => GameMockData.currentOrder;

  final Map<NoteLayer, String?> slots = {
    NoteLayer.top: null,
    NoteLayer.heart: null,
    NoteLayer.base: null,
  };

  String? pendingAssignName;
  BlendResult? lastBlendResult;
  ActiveBlend? activeBlend;
  Timer? _blendTimer;
  GameSection shellSection = GameSection.table;

  /// Journal scent whose bottle colors decorate the blending flask, or null for default amber.
  String? selectedFlaskScentName;

  late List<GameIngredient> ingredients;
  late List<DiscoveredScent> discoveredScents;
  late List<RedeemItem> redeemItems;
  late List<RedeemHistoryEntry> redeemHistory;
  late List<GameUpgrade> upgrades;
  late List<ScoreboardRow> leaderboard;

  static int get totalJournalScents => GameMockData.journalCapacity;

  static final instance = GameState._();

  void _seedData() {
    ingredients = List<GameIngredient>.from(GameMockData.ingredients);
    discoveredScents = List<DiscoveredScent>.from(GameMockData.discoveredScents);
    redeemItems = List<RedeemItem>.from(GameMockData.redeemItems);
    redeemHistory = List<RedeemHistoryEntry>.from(GameMockData.redeemHistory);
    upgrades = List<GameUpgrade>.from(GameMockData.upgrades);
    leaderboard = List<ScoreboardRow>.from(GameMockData.leaderboard);
  }

  List<GameIngredient> get ownedIngredients =>
      ingredients.where((i) => i.owned && i.qty > 0).toList();

  int get ownedCount => ownedIngredients.length;

  List<GameIngredient> get trayItems {
    final owned = ingredients.where((i) => i.owned && i.qty > 0).toList();
    if (owned.length <= 8) return owned;
    return owned.take(8).toList();
  }

  int get filledSlotCount =>
      slots.values.where((name) => name != null).length;

  bool get canBlend => filledSlotCount == 3 && activeBlend == null;

  bool get isBlending => activeBlend != null;

  bool get isBlendReady => activeBlend?.isReady ?? false;

  bool get slotsLocked => isBlending;

  static const Color defaultFlaskColor1 = Color(0xFFD89B3F);
  static const Color defaultFlaskColor2 = Color(0xFFC9822C);

  Color get flaskColor1 {
    final name = selectedFlaskScentName;
    if (name == null) return defaultFlaskColor1;
    for (final scent in discoveredScents) {
      if (scent.name == name) return scent.color1;
    }
    return defaultFlaskColor1;
  }

  Color get flaskColor2 {
    final name = selectedFlaskScentName;
    if (name == null) return defaultFlaskColor2;
    for (final scent in discoveredScents) {
      if (scent.name == name) return scent.color2;
    }
    return defaultFlaskColor2;
  }

  void setFlaskColorFromScent(String? scentName) {
    if (scentName == null) {
      if (selectedFlaskScentName == null) return;
      selectedFlaskScentName = null;
      notifyListeners();
      return;
    }
    if (!discoveredScents.any((s) => s.name == scentName)) return;
    if (selectedFlaskScentName == scentName) return;
    selectedFlaskScentName = scentName;
    notifyListeners();
  }

  void setShellSection(GameSection section) {
    if (shellSection == section) return;
    shellSection = section;
    notifyListeners();
  }

  GameIngredient? ingredientByName(String name) {
    try {
      return ingredients.firstWhere((i) => i.name == name);
    } catch (_) {
      return null;
    }
  }

  List<GameIngredient> ingredientsForLayer(NoteLayer layer) =>
      ingredients.where((i) => i.layer == layer).toList();

  void selectIngredientForAssign(String name) {
    pendingAssignName = name;
    notifyListeners();
  }

  void assignToSlot(NoteLayer layer, String name) {
    if (slotsLocked) return;
    final ing = ingredientByName(name);
    if (ing == null || !ing.owned || ing.qty <= 0) return;
    if (ing.layer != layer) return;
    slots[layer] = name;
    pendingAssignName = null;
    notifyListeners();
  }

  void assignIngredient(String name) {
    if (slotsLocked) return;
    final ing = ingredientByName(name);
    if (ing == null) return;
    assignToSlot(ing.layer, name);
  }

  void clearSlot(NoteLayer layer) {
    if (slotsLocked) return;
    slots[layer] = null;
    notifyListeners();
  }

  void resetSlots() {
    slots[NoteLayer.top] = null;
    slots[NoteLayer.heart] = null;
    slots[NoteLayer.base] = null;
    pendingAssignName = null;
    notifyListeners();
  }

  bool startBlend() {
    if (activeBlend != null || !canBlend) return false;

    final top = ingredientByName(slots[NoteLayer.top]!)!;
    final heart = ingredientByName(slots[NoteLayer.heart]!)!;
    final base = ingredientByName(slots[NoteLayer.base]!)!;

    for (final ing in [top, heart, base]) {
      final idx = ingredients.indexWhere((i) => i.name == ing.name);
      if (idx < 0 || ingredients[idx].qty <= 0) return false;
      ingredients[idx] = ingredients[idx].copyWith(qty: ingredients[idx].qty - 1);
    }

    final result = _buildBlendResult(top, heart, base);
    final wait = _waitForOutcome(result.outcomeRarity, result.matchPercent);
    final now = DateTime.now();

    activeBlend = ActiveBlend(
      startedAt: now,
      completesAt: now.add(wait),
      result: result,
      outcomeRarity: result.outcomeRarity,
    );
    _startBlendTimer();
    notifyListeners();
    return true;
  }

  BlendResult? claimBlendResult() {
    final blend = activeBlend;
    if (blend == null || !blend.isReady) return null;

    _applyBlendRewards(blend.result);
    lastBlendResult = blend.result;
    activeBlend = null;
    _blendTimer?.cancel();
    _blendTimer = null;
    resetSlots();
    notifyListeners();
    return lastBlendResult;
  }

  void _startBlendTimer() {
    _blendTimer?.cancel();
    _blendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (activeBlend == null) {
        _blendTimer?.cancel();
        return;
      }
      if (activeBlend!.isReady) {
        _blendTimer?.cancel();
        _blendTimer = null;
      }
      notifyListeners();
    });
  }

  BlendResult? blend() {
    if (!startBlend()) return null;
    return activeBlend?.result;
  }

  BlendResult _buildBlendResult(
    GameIngredient top,
    GameIngredient heart,
    GameIngredient base,
  ) {
    final scentName = _generateScentName(top, heart, base);
    final notesLine = '${top.name} · ${heart.name} · ${base.name}';
    final matchPercent = _computeMatch(top, heart, base);
    final outcomeRarity = _outcomeRarity(top, heart, base, matchPercent);
    final playScore = matchPercent * 42 + 1200;
    final coinReward = 80 + (matchPercent ~/ 3);
    final stars = switch (outcomeRarity) {
      OutcomeRarity.mystic || OutcomeRarity.legendary => 4,
      _ => (matchPercent / 25).ceil().clamp(1, 4),
    };

    return BlendResult(
      scentName: scentName,
      notesLine: notesLine,
      matchPercent: matchPercent,
      playScore: playScore,
      coinReward: coinReward,
      bridgeCoinReward: outcomeRarity.bridgeCoinReward,
      outcomeRarity: outcomeRarity,
      isNew: !discoveredScents.any((s) => s.name == scentName),
      bottleColor1: heart.color,
      bottleColor2: base.color,
      stars: stars,
    );
  }

  void _applyBlendRewards(BlendResult result) {
    coins += result.coinReward;
    if (result.bridgeCoinReward > 0) {
      bridgeCoins += result.bridgeCoinReward;
    }

    if (result.isNew) {
      discoveredScents = [
        ...discoveredScents,
        DiscoveredScent(
          name: result.scentName,
          notes: result.notesLine,
          bestMatch: result.matchPercent,
          outcomeRarity: result.outcomeRarity,
          color1: result.bottleColor1,
          color2: result.bottleColor2,
        ),
      ];
    } else {
      discoveredScents = discoveredScents.map((s) {
        if (s.name != result.scentName) return s;
        return DiscoveredScent(
          name: s.name,
          notes: s.notes,
          bestMatch: result.matchPercent > s.bestMatch ? result.matchPercent : s.bestMatch,
          outcomeRarity: maxOutcomeRarity(s.outcomeRarity, result.outcomeRarity),
          color1: s.color1,
          color2: s.color2,
        );
      }).toList();
    }
  }

  OutcomeRarity _outcomeRarity(
    GameIngredient top,
    GameIngredient heart,
    GameIngredient base,
    int matchPercent,
  ) {
    final ingredientRarity = _maxRarity([top.rarity, heart.rarity, base.rarity]);
    if (matchPercent >= 98) return OutcomeRarity.mystic;
    if (matchPercent >= 94) return OutcomeRarity.legendary;
    if (matchPercent >= 90 || ingredientRarity == IngredientRarity.rare) {
      return OutcomeRarity.rare;
    }
    if (matchPercent >= 75 || ingredientRarity == IngredientRarity.uncommon) {
      return OutcomeRarity.uncommon;
    }
    return OutcomeRarity.common;
  }

  IngredientRarity _maxRarity(List<IngredientRarity> values) {
    return values.reduce(
      (a, b) => a.index >= b.index ? a : b,
    );
  }

  Duration _waitForOutcome(OutcomeRarity rarity, int matchPercent) {
    return rarity.blendWaitFor(matchPercent);
  }

  bool buyIngredient(String name, int qty) {
    if (qty <= 0) return false;
    final idx = ingredients.indexWhere((i) => i.name == name);
    if (idx < 0) return false;
    final ing = ingredients[idx];
    final total = ing.unlockCost * qty;
    if (coins < total) return false;
    coins -= total;
    ingredients[idx] = ing.copyWith(
      owned: true,
      qty: (ing.owned ? ing.qty : 0) + qty,
    );
    notifyListeners();
    return true;
  }

  bool redeem(RedeemItem item) {
    if (item.owned) return false;
    if (bridgeCoins < item.cost) return false;
    bridgeCoins -= item.cost;
    final idx = redeemItems.indexWhere((r) => r.name == item.name);
    if (idx >= 0) {
      redeemItems[idx] = redeemItems[idx].copyWith(owned: true);
    }
    redeemHistory = [
      RedeemHistoryEntry.fromItem(item, DateTime.now()),
      ...redeemHistory,
    ];
    notifyListeners();
    return true;
  }

  bool upgrade(GameUpgrade upgrade) {
    if (upgrade.isMaxed) return false;
    if (upgrade.tier == UpgradeTier.standard) {
      if (coins < upgrade.cost) return false;
      coins -= upgrade.cost;
    } else {
      if (bridgeCoins < upgrade.cost) return false;
      bridgeCoins -= upgrade.cost;
    }
    final idx = upgrades.indexWhere((u) => u.id == upgrade.id);
    if (idx < 0) return false;
    upgrades[idx] =
        upgrades[idx].copyWith(currentLevel: upgrades[idx].currentLevel + 1);
    notifyListeners();
    return true;
  }

  String _generateScentName(GameIngredient top, GameIngredient heart, GameIngredient base) {
    return GameMockData.blendRecipes[(top.name, heart.name, base.name)] ??
        '${top.name.split(' ').first} ${base.name.split(' ').first}';
  }

  int _computeMatch(GameIngredient top, GameIngredient heart, GameIngredient base) {
    var score = 55;
    if (base.name == 'Sandalwood' || base.name == 'Amber') score += 15;
    if (heart.name == 'Cinnamon' || heart.name == 'Rose') score += 12;
    if (top.name == 'Bergamot' || top.name == 'Lemon') score += 10;
    return score.clamp(60, 98);
  }
}
