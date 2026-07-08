import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../widgets/game/pixel_theme.dart';

import 'ingredient_master_data.dart';

/// Mock content for The Blending Room POC.
///
/// Edit the lists below to add content.
///
/// **Ingredients** → [IngredientMasterData] in `ingredient_master_data.dart`
/// (catalog, shelf, tray, detail, shop all read from there).
class GameMockData {
  GameMockData._();

  static const initialCoins = 1240;
  static const initialBridgeCoins = 350;

  /// Total journal slots (discovered + empty placeholders).
  static const journalCapacity = 24;

  static const currentOrder = CustomerOrder(
    customerInitial: 'P',
    customerName: 'Khun Ploy',
    request: '"Something warm and woody for a rainy evening, please."',
    tags: [
      ('WOODY BASE', kPixelWoodNote),
      ('SPICE HEART', kPixelSpice),
    ],
  );

  // ---------------------------------------------------------------------------
  // Ingredients — see ingredient_master_data.dart
  // ---------------------------------------------------------------------------
  static List<GameIngredient> get ingredients => IngredientMasterData.all;

  // ---------------------------------------------------------------------------
  // Journal perfumes — add rows here
  // ---------------------------------------------------------------------------
  static final discoveredScents = <DiscoveredScent>[
    mockPerfume(
      name: 'Amber Hearth',
      notes: 'Bergamot · Cinnamon · Sandalwood',
      bestMatch: 92,
      color1: const Color(0xFFD89B3F),
      color2: const Color(0xFFC9822C),
    ),
    mockPerfume(
      name: 'Citrus Rain',
      notes: 'Lemon · Jasmine · Musk',
      bestMatch: 88,
      color1: const Color(0xFFD4E07A),
      color2: const Color(0xFFB8C45E),
    ),
    mockPerfume(
      name: 'Rose Ember',
      notes: 'Bergamot · Rose · Amber',
      bestMatch: 81,
      color1: const Color(0xFFC97B8F),
      color2: const Color(0xFFB06276),
    ),
    mockPerfume(
      name: 'Mint Grove',
      notes: 'Mint · Jasmine · Musk',
      bestMatch: 74,
      color1: const Color(0xFF9BC48E),
      color2: const Color(0xFF7FAA72),
    ),
    mockPerfume(
      name: 'Spice Lantern',
      notes: 'Lemon · Cinnamon · Amber',
      bestMatch: 69,
      color1: const Color(0xFFB05A2A),
      color2: const Color(0xFF9A4A20),
    ),
    mockPerfume(
      name: 'Musk Meadow',
      notes: 'Mint · Rose · Musk',
      bestMatch: 77,
      color1: const Color(0xFFA89684),
      color2: const Color(0xFF8F7E6C),
    ),
  ];

  /// Named blend outcomes: (top, heart, base) → perfume name.
  /// Add entries here when you want a fixed name instead of auto-generated.
  static const blendRecipes = <(String top, String heart, String base), String>{
    ('Bergamot', 'Cinnamon', 'Sandalwood'): 'Amber Hearth',
    ('Lemon', 'Jasmine', 'Musk'): 'Citrus Rain',
    ('Bergamot', 'Rose', 'Amber'): 'Rose Ember',
    ('Mint', 'Jasmine', 'Musk'): 'Mint Grove',
    ('Lemon', 'Cinnamon', 'Amber'): 'Spice Lantern',
    ('Mint', 'Rose', 'Musk'): 'Musk Meadow',
  };

  // ---------------------------------------------------------------------------
  // Coupon shop — add rows here (Bridge Coin vouchers)
  // ---------------------------------------------------------------------------
  static final redeemItems = <RedeemItem>[
    mockCoupon(
      name: '20% Off Café Pastry',
      description: 'Valid at BRIDGE HQ café counter',
      cost: 60,
      color: kPixelClay,
      glyph: '%',
    ),
    mockCoupon(
      name: 'Free Drip Coffee',
      description: 'One complimentary drink · café only',
      cost: 80,
      color: const Color(0xFF7FA8A0),
      glyph: 'C',
    ),
    mockCoupon(
      name: '฿100 Store Voucher',
      description: 'Min spend ฿500 · lifestyle stores',
      cost: 120,
      color: kPixelCoinGold,
      glyph: 'B',
    ),
    mockCoupon(
      name: 'Partner Spa 15% Off',
      description: 'Wellness partners · weekday only',
      cost: 200,
      color: const Color(0xFF9B8FC0),
      glyph: 'S',
    ),
    mockCoupon(
      name: 'HQ Lunch Set Coupon',
      description: 'Buy 1 get 1 · canteen only',
      cost: 100,
      color: kPixelGreen,
      glyph: 'L',
      owned: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Coupon history — add rows here (newest first)
  // ---------------------------------------------------------------------------
  static final redeemHistory = <RedeemHistoryEntry>[
    mockRedeemHistory(
      itemName: 'HQ Lunch Set Coupon',
      description: 'Buy 1 get 1 · canteen only',
      cost: 100,
      glyph: 'L',
      color: kPixelGreen,
      daysAgo: 2,
    ),
    mockRedeemHistory(
      itemName: '20% Off Café Pastry',
      description: 'Valid at BRIDGE HQ café counter',
      cost: 60,
      glyph: '%',
      color: kPixelClay,
      daysAgo: 9,
    ),
    mockRedeemHistory(
      itemName: 'Free Drip Coffee',
      description: 'One complimentary drink · café only',
      cost: 80,
      glyph: 'C',
      color: const Color(0xFF7FA8A0),
      daysAgo: 18,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Upgrades — add rows here
  // ---------------------------------------------------------------------------
  static final upgrades = <GameUpgrade>[
    mockUpgrade(
      id: 'quick_stir',
      name: 'Quick Stir',
      description: 'Blends finish 20% faster',
      tier: UpgradeTier.standard,
      cost: 300,
      color: kPixelGreen,
      glyph: 'Q',
      currentLevel: 1,
      maxLevel: 3,
    ),
    mockUpgrade(
      id: 'tip_jar',
      name: 'Tip Jar',
      description: '+10% Coins per order',
      tier: UpgradeTier.standard,
      cost: 600,
      color: kPixelClay,
      glyph: 'J',
      currentLevel: 3,
      maxLevel: 5,
    ),
    mockUpgrade(
      id: 'nose_master',
      name: 'Nose of the Master',
      description: 'Hints show best note match',
      tier: UpgradeTier.premium,
      cost: 450,
      color: const Color(0xFF9B8FC0),
      glyph: 'N',
      currentLevel: 1,
      maxLevel: 3,
    ),
    mockUpgrade(
      id: 'golden_counter',
      name: 'Golden Counter',
      description: 'Shop cosmetic + rare visitors',
      tier: UpgradeTier.premium,
      cost: 500,
      color: kPixelCoinGold,
      glyph: 'G',
      currentLevel: 0,
      maxLevel: 1,
    ),
  ];

  static const leaderboard = <ScoreboardRow>[
    ScoreboardRow(rank: 1, name: 'Ploy', scent: 'Amber Hearth', score: '9,840', reward: '+500'),
    ScoreboardRow(rank: 2, name: 'Beam', scent: 'Rose Ember', score: '9,120', reward: '+300'),
    ScoreboardRow(rank: 3, name: 'Mild', scent: 'Citrus Rain', score: '8,760', reward: '+200'),
    ScoreboardRow(rank: 4, name: 'Golf', scent: 'Cedar Dusk', score: '7,940', reward: '+100'),
    ScoreboardRow(rank: 5, name: 'Fern', scent: 'Jasmine Fog', score: '7,410', reward: '+100'),
    ScoreboardRow(rank: 6, name: 'Aom', scent: 'Mint Grove', score: '6,880', reward: '+100'),
    ScoreboardRow(rank: 7, name: 'Bank', scent: 'Spice Lantern', score: '6,300', reward: '+50'),
    ScoreboardRow(rank: 8, name: 'June', scent: 'Musk Meadow', score: '5,720', reward: '+50'),
    ScoreboardRow(rank: 9, name: 'Toey', scent: 'Lemon Attic', score: '5,140', reward: '+50'),
    ScoreboardRow(rank: 10, name: 'Nan', scent: 'Velvet Oud', score: '4,660', reward: '+50'),
  ];
}

// ---------------------------------------------------------------------------
// Builders — perfumes, redeem, upgrades (ingredients → ingredient_master_data.dart)
// ---------------------------------------------------------------------------

DiscoveredScent mockPerfume({
  required String name,
  required String notes,
  required int bestMatch,
  required Color color1,
  required Color color2,
  OutcomeRarity? outcomeRarity,
}) {
  return DiscoveredScent(
    name: name,
    notes: notes,
    bestMatch: bestMatch,
    outcomeRarity: outcomeRarity ?? outcomeRarityFromMatch(bestMatch),
    color1: color1,
    color2: color2,
  );
}

RedeemItem mockCoupon({
  required String name,
  required String description,
  required int cost,
  required Color color,
  required String glyph,
  bool owned = false,
}) {
  return RedeemItem(
    name: name,
    description: description,
    cost: cost,
    color: color,
    glyph: glyph,
    owned: owned,
  );
}

RedeemHistoryEntry mockRedeemHistory({
  required String itemName,
  required String description,
  required int cost,
  required String glyph,
  required Color color,
  int daysAgo = 0,
  int hoursAgo = 0,
}) {
  final now = DateTime.now();
  return RedeemHistoryEntry(
    itemName: itemName,
    description: description,
    cost: cost,
    glyph: glyph,
    color: color,
    redeemedAt: now.subtract(Duration(days: daysAgo, hours: hoursAgo)),
  );
}

GameUpgrade mockUpgrade({
  required String id,
  required String name,
  required String description,
  required UpgradeTier tier,
  required int cost,
  required Color color,
  required String glyph,
  required int currentLevel,
  required int maxLevel,
}) {
  return GameUpgrade(
    id: id,
    name: name,
    description: description,
    tier: tier,
    cost: cost,
    color: color,
    glyph: glyph,
    currentLevel: currentLevel,
    maxLevel: maxLevel,
  );
}
