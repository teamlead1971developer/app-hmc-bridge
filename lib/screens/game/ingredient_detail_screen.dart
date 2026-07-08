import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class IngredientDetailScreen extends StatelessWidget {
  const IngredientDetailScreen({super.key, required this.ingredientName});

  final String ingredientName;

  @override
  Widget build(BuildContext context) {
    final ing = GameState.instance.ingredientByName(ingredientName);
    if (ing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pop();
      });
      return const Scaffold(backgroundColor: kPixelWoodDarkest);
    }

    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final current = GameState.instance.ingredientByName(ingredientName)!;
        return Scaffold(
          backgroundColor: kPixelWoodDarkest,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    '✦ INGREDIENT · ${current.layer.groupLabel} ✦',
                    textAlign: TextAlign.center,
                    style: pixelStyle(size: 14, color: kPixelCoinGoldBright, letterSpacing: 1),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        PixelPanel(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: PixelBottle(
                                  color: current.color,
                                  width: 48,
                                  height: 68,
                                  striped: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(current.name, style: pixelStyle(size: 22, weight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  PersonalityTag(label: current.layer.label, color: kPixelWoodNote),
                                  RarityTag(rarity: current.rarity),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(current.flavorText, style: vtStyle(size: 18, color: kPixelMuted)),
                              const SizedBox(height: 12),
                              Text('PERSONALITY', style: pixelStyle(size: 13, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              for (final bar in current.profile) ...[
                                ProfileBarRow(bar: bar),
                                const SizedBox(height: 4),
                              ],
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final (label, color) in current.personalityTags)
                                    PersonalityTag(label: label, color: color),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('PAIRS WELL WITH', style: pixelStyle(size: 13, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final (name, color) in current.pairsWith)
                                    PairChip(name: name, color: color),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          decoration: BoxDecoration(
                            color: kPixelWoodDark,
                            border: Border.all(color: kPixelWoodDarkest, width: 4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('IN STOCK', style: pixelStyle(size: 13, color: kPixelCream, letterSpacing: 1)),
                              const SizedBox(width: 10),
                              Text(
                                'x${current.qty}',
                                style: vtStyle(size: 22, color: kPixelCoinGoldBright),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: PixelButton(
                    label: 'BACK',
                    backgroundColor: kPixelWood,
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
