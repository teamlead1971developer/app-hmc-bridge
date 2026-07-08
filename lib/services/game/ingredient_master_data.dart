import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../widgets/game/pixel_theme.dart';

/// Master catalog of [GameIngredient] records for The Blending Room.
///
/// Edit [all] to add or change ingredients. Each field maps to in-game UI:
///
/// | Field | Shown on |
/// |-------|----------|
/// | [name] | Catalog, shelf, tray, detail, shop |
/// | [layer] | Catalog section, layer tag, slot assignment |
/// | [color] | Bottle swatch (catalog/shelf/tray/detail/shop) |
/// | [rarity] | Rarity tag + unlock price (500 / 800 / 1200 C) |
/// | [owned], [qty] | OWNED badge, shelf/tray visibility, IN STOCK |
/// | [flavorText] | Quoted flavor line on detail + shop |
/// | [profile] | PERSONALITY striped bars on detail + shop |
/// | [personalityTags] | Personality tag chips on detail + shop |
/// | [pairsWith] | PAIRS WELL WITH chips on detail + shop |
class IngredientMasterData {
  IngredientMasterData._();

  static List<GameIngredient> get all => List.unmodifiable(_ingredients);

  static final _ingredients = <GameIngredient>[
    // --- TOP NOTES ---
    ingredient(
      name: 'Bergamot',
      layer: NoteLayer.top,
      color: const Color(0xFFDCC94C),
      owned: true,
      qty: 4,
      flavor: '"Bright citrus peel — lifts a blend like morning sun through curtains."',
      profile: IngredientProfiles.citrus(woody: 15, sweet: 30, fresh: 90),
      tags: IngredientTags.citrusFresh,
      pairs: IngredientPairs.citrusTop,
    ),
    ingredient(
      name: 'Lemon',
      layer: NoteLayer.top,
      color: const Color(0xFFE8D96B),
      owned: true,
      qty: 6,
      flavor: '"Clean and sharp. Cuts through heavy bases without stealing the stage."',
      profile: IngredientProfiles.citrus(fresh: 95, sweet: 25),
      tags: IngredientTags.citrusFresh,
      pairs: IngredientPairs.citrusTop,
    ),
    ingredient(
      name: 'Mint',
      layer: NoteLayer.top,
      color: const Color(0xFF9BC48E),
      owned: true,
      qty: 3,
      flavor: '"Cool green leaf — a brisk opening that fades into something softer."',
      profile: IngredientProfiles.citrus(woody: 10, sweet: 20, fresh: 88),
      tags: const [('FRESH', kPixelGreen), ('COOL', Color(0xFF7FA8A0)), ('BRIGHT', Color(0xFFD4E07A))],
      pairs: const [('Jasmine', Color(0xFFEADFA8)), ('Musk', Color(0xFFA89684)), ('Rose', Color(0xFFC97B8F))],
    ),
    ingredient(
      name: 'Pepper',
      layer: NoteLayer.top,
      color: const Color(0xFF8A8070),
      rarity: IngredientRarity.uncommon,
      flavor: '"Dry spice crackle — adds edge to sweet hearts and creamy bases."',
      profile: IngredientProfiles.spicy(woody: 40, sweet: 25, fresh: 55),
      tags: const [('SPICY', kPixelSpice), ('DRY', Color(0xFF8A8070)), ('WARM', kPixelWood)],
      pairs: const [('Rose', Color(0xFFC97B8F)), ('Sandalwood', kPixelWoodNote), ('Amber', kPixelAmber)],
    ),
    ingredient(
      name: 'Yuzu',
      layer: NoteLayer.top,
      color: const Color(0xFFD4E07A),
      rarity: IngredientRarity.uncommon,
      flavor: '"Japanese citrus — tart, floral, and a little mysterious."',
      profile: IngredientProfiles.citrus(fresh: 92, sweet: 35, woody: 12),
      tags: const [('CITRUS', Color(0xFFD4E07A)), ('FLORAL', Color(0xFFC97B8F)), ('BRIGHT', Color(0xFFE8D96B))],
      pairs: const [('Neroli', Color(0xFFE8C06B)), ('Jasmine', Color(0xFFEADFA8)), ('Oud', kPixelShowcase)],
    ),

    // --- HEART NOTES ---
    ingredient(
      name: 'Rose',
      layer: NoteLayer.heart,
      color: const Color(0xFFC97B8F),
      owned: true,
      qty: 2,
      flavor: '"Soft petals with a honeyed edge — romantic without being sugary."',
      profile: IngredientProfiles.floral(sweet: 70, woody: 30, fresh: 35),
      tags: IngredientTags.floralRomantic,
      pairs: const [('Bergamot', Color(0xFFDCC94C)), ('Amber', kPixelAmber), ('Musk', Color(0xFFA89684))],
    ),
    ingredient(
      name: 'Jasmine',
      layer: NoteLayer.heart,
      color: const Color(0xFFEADFA8),
      owned: true,
      qty: 5,
      flavor: '"Night-blooming white flowers — lush, indolic, unforgettable."',
      profile: IngredientProfiles.floral(sweet: 65, woody: 20, fresh: 40),
      tags: const [('FLORAL', Color(0xFFC97B8F)), ('CREAMY', kPixelAmber), ('LUSH', Color(0xFFEADFA8))],
      pairs: const [('Lemon', Color(0xFFE8D96B)), ('Sandalwood', kPixelWoodNote), ('Musk', Color(0xFFA89684))],
    ),
    ingredient(
      name: 'Cinnamon',
      layer: NoteLayer.heart,
      color: kPixelSpice,
      owned: true,
      qty: 4,
      flavor: '"Warm bark spice — cozy, festive, and a little dangerous in large doses."',
      profile: IngredientProfiles.spicy(sweet: 55, woody: 50, fresh: 25),
      tags: const [('SPICE', kPixelSpice), ('WARM', kPixelWood), ('SWEET', kPixelAmber)],
      pairs: const [('Bergamot', Color(0xFFDCC94C)), ('Amber', kPixelAmber), ('Sandalwood', kPixelWoodNote)],
    ),
    ingredient(
      name: 'Lavender',
      layer: NoteLayer.heart,
      color: const Color(0xFF9B8FC0),
      rarity: IngredientRarity.uncommon,
      flavor: '"Herbal calm — purple fields and linen sheets on a slow afternoon."',
      profile: IngredientProfiles.floral(fresh: 60, sweet: 40, woody: 25),
      tags: const [('HERBAL', kPixelGreen), ('FLORAL', Color(0xFF9B8FC0)), ('CALM', Color(0xFF7FA8A0))],
      pairs: const [('Neroli', Color(0xFFE8C06B)), ('Vetiver', kPixelGreen), ('Musk', Color(0xFFA89684))],
    ),
    ingredient(
      name: 'Neroli',
      layer: NoteLayer.heart,
      color: const Color(0xFFE8C06B),
      rarity: IngredientRarity.uncommon,
      flavor: '"Orange blossom distillate — green, honeyed, and elegantly bitter."',
      profile: IngredientProfiles.floral(fresh: 75, sweet: 50, woody: 15),
      tags: const [('FLORAL', Color(0xFFE8C06B)), ('CITRUS', Color(0xFFDCC94C)), ('GREEN', kPixelGreen)],
      pairs: const [('Yuzu', Color(0xFFD4E07A)), ('Sandalwood', kPixelWoodNote), ('Vanilla', Color(0xFFE3C88F))],
    ),

    // --- BASE NOTES ---
    ingredient(
      name: 'Sandalwood',
      layer: NoteLayer.base,
      color: kPixelWoodNote,
      owned: true,
      qty: 3,
      rarity: IngredientRarity.uncommon,
      flavor: '"Warm heartwood from old temple gardens. Settles a blend like evening light on a wooden floor."',
      profile: IngredientProfiles.woody(woody: 85, sweet: 45, fresh: 20),
      tags: IngredientTags.woodyWarm,
      pairs: IngredientPairs.woodyBase,
    ),
    ingredient(
      name: 'Amber',
      layer: NoteLayer.base,
      color: kPixelAmber,
      owned: true,
      qty: 4,
      flavor: '"Resinous glow — sweet, balsamic, and endlessly comforting."',
      profile: IngredientProfiles.woody(woody: 55, sweet: 80, fresh: 15),
      tags: const [('SWEET', kPixelAmber), ('WARM', kPixelWood), ('RESINOUS', kPixelWoodNote)],
      pairs: const [('Rose', Color(0xFFC97B8F)), ('Cinnamon', kPixelSpice), ('Bergamot', Color(0xFFDCC94C))],
    ),
    ingredient(
      name: 'Musk',
      layer: NoteLayer.base,
      color: const Color(0xFFA89684),
      owned: true,
      qty: 2,
      flavor: '"Soft skin scent — clean, intimate, and smooths every rough edge."',
      profile: IngredientProfiles.woody(woody: 35, sweet: 50, fresh: 30),
      tags: const [('CLEAN', Color(0xFFA89684)), ('CREAMY', kPixelAmber), ('SOFT', Color(0xFFEADFA8))],
      pairs: const [('Jasmine', Color(0xFFEADFA8)), ('Rose', Color(0xFFC97B8F)), ('Mint', Color(0xFF9BC48E))],
    ),
    ingredient(
      name: 'Oud',
      layer: NoteLayer.base,
      color: kPixelShowcase,
      rarity: IngredientRarity.rare,
      flavor: '"Dark resinous wood — smoky, animalic, and impossibly luxurious."',
      profile: IngredientProfiles.woody(woody: 95, sweet: 35, fresh: 10),
      tags: const [('WOODY', kPixelShowcase), ('SMOKY', Color(0xFF4E3320)), ('RICH', kPixelWoodNote)],
      pairs: const [('Yuzu', Color(0xFFD4E07A)), ('Rose', Color(0xFFC97B8F)), ('Saffron', kPixelSpice)],
    ),
    ingredient(
      name: 'Vetiver',
      layer: NoteLayer.base,
      color: kPixelGreen,
      owned: true,
      qty: 1,
      rarity: IngredientRarity.uncommon,
      flavor: '"Earthy grass roots — dry, smoky, and grounding like wet soil after rain."',
      profile: IngredientProfiles.woody(woody: 70, sweet: 20, fresh: 45),
      tags: const [('EARTHY', kPixelGreen), ('DRY', Color(0xFF8A8070)), ('GREEN', Color(0xFF5D7A3F))],
      pairs: const [('Lavender', Color(0xFF9B8FC0)), ('Neroli', Color(0xFFE8C06B)), ('Pepper', Color(0xFF8A8070))],
    ),
    ingredient(
      name: 'Vanilla',
      layer: NoteLayer.base,
      color: const Color(0xFFE3C88F),
      rarity: IngredientRarity.rare,
      flavor: '"Sweet orchid pod — gourmand, cozy, and melts into almost anything."',
      profile: IngredientProfiles.woody(woody: 25, sweet: 90, fresh: 15),
      tags: const [('SWEET', Color(0xFFE3C88F)), ('CREAMY', kPixelAmber), ('GOURMAND', kPixelSpice)],
      pairs: const [('Neroli', Color(0xFFE8C06B)), ('Rose', Color(0xFFC97B8F)), ('Sandalwood', kPixelWoodNote)],
    ),
  ];
}

// ---------------------------------------------------------------------------
// Ingredient builder — pass every field the game can display
// ---------------------------------------------------------------------------

GameIngredient ingredient({
  required String name,
  required NoteLayer layer,
  required Color color,
  IngredientRarity rarity = IngredientRarity.common,
  bool owned = false,
  int qty = 0,
  required String flavor,
  required List<ScentProfileBar> profile,
  required List<(String label, Color color)> tags,
  required List<(String name, Color color)> pairs,
}) {
  final quote = flavor.startsWith('"') ? flavor : '"$flavor"';
  return GameIngredient(
    name: name,
    layer: layer,
    color: color,
    rarity: rarity,
    flavorText: quote,
    profile: profile,
    personalityTags: tags,
    pairsWith: pairs,
    owned: owned,
    qty: qty,
  );
}

// ---------------------------------------------------------------------------
// Profile presets (PERSONALITY bars)
// ---------------------------------------------------------------------------

class IngredientProfiles {
  IngredientProfiles._();

  static List<ScentProfileBar> woody({
    int woody = 85,
    int sweet = 45,
    int fresh = 20,
  }) =>
      [
        profileBar('WOODY', woody, kPixelWoodNote, const Color(0xFF7A4F30)),
        profileBar('SWEET', sweet, kPixelAmber, const Color(0xFFC9822C)),
        profileBar('FRESH', fresh, kPixelGreen, const Color(0xFF5D7A3F)),
      ];

  static List<ScentProfileBar> citrus({
    int woody = 10,
    int sweet = 30,
    int fresh = 90,
  }) =>
      [
        profileBar('WOODY', woody, kPixelWoodNote, const Color(0xFF7A4F30)),
        profileBar('SWEET', sweet, kPixelAmber, const Color(0xFFC9822C)),
        profileBar('FRESH', fresh, kPixelGreen, const Color(0xFF5D7A3F)),
      ];

  static List<ScentProfileBar> floral({
    int woody = 25,
    int sweet = 65,
    int fresh = 40,
  }) =>
      [
        profileBar('WOODY', woody, kPixelWoodNote, const Color(0xFF7A4F30)),
        profileBar('SWEET', sweet, const Color(0xFFC97B8F), const Color(0xFFB06276)),
        profileBar('FRESH', fresh, kPixelGreen, const Color(0xFF5D7A3F)),
      ];

  static List<ScentProfileBar> spicy({
    int woody = 45,
    int sweet = 40,
    int fresh = 35,
  }) =>
      [
        profileBar('WOODY', woody, kPixelWoodNote, const Color(0xFF7A4F30)),
        profileBar('SWEET', sweet, kPixelSpice, const Color(0xFF9A4A20)),
        profileBar('FRESH', fresh, kPixelGreen, const Color(0xFF5D7A3F)),
      ];
}

ScentProfileBar profileBar(String label, int percent, Color color1, Color color2) {
  return ScentProfileBar(
    label: label,
    percent: percent,
    color1: color1,
    color2: color2,
  );
}

// ---------------------------------------------------------------------------
// Tag / pair presets (personality chips + pairs well with)
// ---------------------------------------------------------------------------

class IngredientTags {
  IngredientTags._();

  static const woodyWarm = [
    ('WOODY', kPixelWoodNote),
    ('CREAMY', kPixelAmber),
    ('WARM', kPixelWood),
  ];

  static const citrusFresh = [
    ('CITRUS', Color(0xFFDCC94C)),
    ('BRIGHT', Color(0xFFE8D96B)),
    ('FRESH', kPixelGreen),
  ];

  static const floralRomantic = [
    ('FLORAL', Color(0xFFC97B8F)),
    ('SWEET', kPixelAmber),
    ('SOFT', Color(0xFFEADFA8)),
  ];
}

class IngredientPairs {
  IngredientPairs._();

  static const woodyBase = [
    ('Cinnamon', kPixelSpice),
    ('Amber', kPixelAmber),
    ('Bergamot', Color(0xFFDCC94C)),
  ];

  static const citrusTop = [
    ('Jasmine', Color(0xFFEADFA8)),
    ('Musk', Color(0xFFA89684)),
    ('Sandalwood', kPixelWoodNote),
  ];
}
