import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class CoinPouchSection extends StatelessWidget {
  const CoinPouchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        return Column(
          children: [
            const GameHeader(title: 'COIN POUCH'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  PixelButton(
                    label: 'HISTORY →',
                    height: 44,
                    fontSize: 16,
                    backgroundColor: kPixelWoodDark,
                    onPressed: () => context.pushNamed('gameRedeemHistory'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'COUPONS · BRIDGE COINS ONLY',
                    style: pixelStyle(size: 14, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  for (final item in state.redeemItems) ...[
                    _CouponRow(item: item),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Spend Bridge Coins on staff coupons',
                textAlign: TextAlign.center,
                style: vtStyle(size: 15, color: kPixelMutedLight),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.item});

  final RedeemItem item;

  @override
  Widget build(BuildContext context) {
    final owned = item.owned;
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color,
              border: Border.all(color: kPixelWoodDark, width: 4),
            ),
            child: Text(
              item.glyph,
              style: pixelStyle(size: 17, color: kPixelCream),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: pixelStyle(size: 14)),
                Text(item.description, style: vtStyle(size: 15, color: kPixelMutedLight)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const CoinIcon(currency: GameCurrency.bridgeCoins, size: 12),
                  const SizedBox(width: 4),
                  Text('${item.cost}', style: vtStyle(size: 17)),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: owned ? null : () => GameState.instance.redeem(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: owned ? kPixelMutedLight : kPixelBrandRed,
                    border: Border.all(color: kPixelWoodDark, width: 3),
                  ),
                  child: Text(
                    owned ? 'CLAIMED' : 'GET',
                    style: pixelStyle(size: 12, color: kPixelCream),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
