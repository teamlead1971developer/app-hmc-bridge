import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class ShopItemDetailScreen extends StatefulWidget {
  const ShopItemDetailScreen({super.key, required this.ingredientName});

  final String ingredientName;

  @override
  State<ShopItemDetailScreen> createState() => _ShopItemDetailScreenState();
}

class _ShopItemDetailScreenState extends State<ShopItemDetailScreen> {
  int _qty = 1;
  static const _qtyOptions = [1, 2, 5, 10];

  @override
  Widget build(BuildContext context) {
    final ing = GameState.instance.ingredientByName(widget.ingredientName);
    if (ing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pop();
      });
      return const Scaffold(backgroundColor: kPixelWoodDarkest);
    }

    final unitCost = ing.unlockCost;
    final total = unitCost * _qty;

    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final canBuy = GameState.instance.coins >= total;
        return Scaffold(
          backgroundColor: kPixelWoodDarkest,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    '✦ INGREDIENT SHOP · ${ing.layer.groupLabel} ✦',
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
                                  color: ing.color,
                                  width: 48,
                                  height: 68,
                                  striped: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(ing.name, style: pixelStyle(size: 22, weight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  PersonalityTag(label: ing.layer.label, color: kPixelWoodNote),
                                  PersonalityTag(label: ing.rarityLabel, color: kPixelSpice),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(ing.flavorText, style: vtStyle(size: 18, color: kPixelMuted)),
                              const SizedBox(height: 12),
                              Text('PERSONALITY', style: pixelStyle(size: 13, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              for (final bar in ing.profile) ...[
                                ProfileBarRow(bar: bar),
                                const SizedBox(height: 4),
                              ],
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final (label, color) in ing.personalityTags)
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
                                  for (final (name, color) in ing.pairsWith)
                                    PairChip(name: name, color: color),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kPixelWoodDark,
                            border: Border.all(color: kPixelWoodDarkest, width: 4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QUANTITY', style: pixelStyle(size: 13, color: kPixelCream, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (final q in _qtyOptions) ...[
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _qty = q),
                                        child: Container(
                                          height: 44,
                                          margin: EdgeInsets.only(right: q == _qtyOptions.last ? 0 : 6),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: _qty == q
                                                ? stripedGradient(kPixelBridgeRed, kPixelBridgeRedDark)
                                                : null,
                                            color: _qty == q ? null : kPixelWood,
                                            border: Border.all(
                                              color: _qty == q ? kPixelCoinGold : kPixelWoodDarkest,
                                              width: _qty == q ? 3 : 2,
                                            ),
                                          ),
                                          child: Text(
                                            'x$q',
                                            style: pixelStyle(
                                              size: 16,
                                              color: kPixelCream,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${formatGameNumber(unitCost)} C each',
                                style: vtStyle(size: 17, color: kPixelOnWoodMuted),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL', style: pixelStyle(size: 14, color: kPixelCream)),
                                  Row(
                                    children: [
                                      const CoinIcon(currency: GameCurrency.coins),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatGameNumber(total),
                                        style: vtStyle(size: 22, color: kPixelCoinGoldBright),
                                      ),
                                    ],
                                  ),
                                ],
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
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: PixelButton(
                          label: 'BACK',
                          expanded: false,
                          backgroundColor: kPixelWood,
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PixelButton(
                          label: 'BUY x$_qty · ${formatGameNumber(total)} C',
                          redStriped: true,
                          onPressed: canBuy
                              ? () {
                                  GameState.instance.buyIngredient(ing.name, _qty);
                                  context.pop();
                                }
                              : null,
                        ),
                      ),
                    ],
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
