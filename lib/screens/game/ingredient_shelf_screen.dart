import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class IngredientShelfSection extends StatelessWidget {
  const IngredientShelfSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        return Column(
          children: [
            GameHeader(
              title: 'INGREDIENT SHELF',
              subtitle: '${state.ownedCount} owned · more in catalog',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  for (final layer in NoteLayer.values) ...[
                    _ShelfGroup(state: state, layer: layer),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: kPixelWood,
                border: Border(top: BorderSide(color: kPixelWoodDark, width: 4)),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _JournalIconButton(
                    onTap: () =>
                        GameState.instance.setShellSection(GameSection.journal),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PixelButton(
                      label: 'OPEN UNLOCK CATALOG →',
                      backgroundColor: kPixelWoodDark,
                      onPressed: () => context.pushNamed('gameCatalog'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _JournalIconButton extends StatelessWidget {
  const _JournalIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Scent journal',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: kPixelWoodDark,
            border: Border.all(color: kPixelWoodDarkest, width: 3),
            boxShadow: const [kPixelCardShadow],
          ),
          child: Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: kPixelGreen,
                border: Border.all(color: kPixelWoodDarkest, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShelfGroup extends StatelessWidget {
  const _ShelfGroup({required this.state, required this.layer});

  final GameState state;
  final NoteLayer layer;

  @override
  Widget build(BuildContext context) {
    final items = state.ingredientsForLayer(layer).where((i) => i.owned && i.qty > 0).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(layer.groupLabel, style: pixelStyle(size: 14, letterSpacing: 1)),
        const SizedBox(height: 8),
        PixelPanel(
          color: kPixelWood,
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final ing in items)
                IngredientTile(
                  name: ing.name,
                  color: ing.color,
                  qtyLabel: 'x${ing.qty}',
                  rarity: ing.rarity,
                  onTap: () => context.pushNamed(
                    'gameIngredient',
                    pathParameters: {'name': ing.name},
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
