import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class UnlockCatalogScreen extends StatelessWidget {
  const UnlockCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        return Scaffold(
          backgroundColor: kPixelCream,
          body: Column(
            children: [
              GameHeader(
                title: 'UNLOCK CATALOG',
                subtitle: 'All ingredients by layer',
                showBack: true,
                showBridge: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    for (final layer in NoteLayer.values) ...[
                      _CatalogSection(state: state, layer: layer),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Unlocks are paid in Coins only · price by rarity',
                  textAlign: TextAlign.center,
                  style: vtStyle(size: 15, color: kPixelMutedLight),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({required this.state, required this.layer});

  final GameState state;
  final NoteLayer layer;

  @override
  Widget build(BuildContext context) {
    final items = state.ingredientsForLayer(layer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(layer.groupLabel, style: pixelStyle(size: 14, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final ing in items)
              _CatalogTile(
                ingredient: ing,
                coins: state.coins,
                onTap: () => context.pushNamed(
                  'gameShopItem',
                  pathParameters: {'name': ing.name},
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.ingredient,
    required this.coins,
    this.onTap,
  });

  final GameIngredient ingredient;
  final int coins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final owned = ingredient.owned;
    final price = ingredient.unlockCost;
    final canAfford = coins >= price;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: owned ? kPixelCream : kPixelLockedTile,
          border: Border.all(color: kPixelWoodDark, width: 4),
          boxShadow: const [kPixelCardShadow],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                PixelBottle(
                  color: owned ? ingredient.color : kPixelLockedBottle,
                  width: 26,
                  height: 37,
                ),
                const SizedBox(height: 5),
                Text(
                  ingredient.name,
                  textAlign: TextAlign.center,
                  style: pixelStyle(size: 11, color: owned ? kPixelInk : kPixelMutedLight),
                ),
                const SizedBox(height: 4),
                RarityTag(rarity: ingredient.rarity, compact: true),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: canAfford ? kPixelSpice : kPixelDisabled,
                    border: Border.all(color: kPixelWoodDark, width: 2),
                  ),
                  child: Text(
                    '${formatGameNumber(price)} C',
                    textAlign: TextAlign.center,
                    style: vtStyle(
                      size: 13,
                      color: canAfford ? kPixelCream : kPixelOnWoodMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (owned)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: kPixelGreen,
                    border: Border.all(color: kPixelWoodDark, width: 2),
                  ),
                  child: Text(
                    'OWNED',
                    style: vtStyle(size: 10, color: kPixelCream),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
