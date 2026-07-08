import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class BlendResultScreen extends StatelessWidget {
  const BlendResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result = GameState.instance.lastBlendResult;
    if (result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goNamed('game');
      });
      return const Scaffold(backgroundColor: kPixelWoodDarkest);
    }

    return Scaffold(
      backgroundColor: kPixelWoodDarkest,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _resultTitle(result),
              style: pixelStyle(size: 16, color: kPixelCoinGoldBright, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: PixelPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PixelBottle(
                        color: result.bottleColor1,
                        width: 40,
                        height: 56,
                        striped: true,
                        stripeC2: result.bottleColor2,
                      ),
                      const SizedBox(height: 12),
                      Text(result.scentName, style: pixelStyle(size: 22, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      OutcomeRarityTag(rarity: result.outcomeRarity),
                      const SizedBox(height: 4),
                      Text(result.notesLine, style: vtStyle(size: 18, color: kPixelMuted)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 4; i++)
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i < result.stars ? kPixelCoinGold : kPixelRecessed,
                                border: Border.all(color: kPixelWoodDark, width: 3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('ORDER MATCH', style: pixelStyle(size: 13, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 6),
                      StripedBar(
                        percent: result.matchPercent / 100,
                        c1: kPixelGreen,
                        c2: const Color(0xFF5D7A3F),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${result.matchPercent}%', style: vtStyle(size: 20)),
                      ),
                      const SizedBox(height: 12),
                      Text('PLAY SCORE', style: pixelStyle(size: 13, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                        formatGameNumber(result.playScore),
                        style: vtStyle(size: 28, color: kPixelInk),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: kPixelWoodDark,
                border: Border.all(color: kPixelWoodDarkest, width: 4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CoinIcon(currency: GameCurrency.coins, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+${formatGameNumber(result.coinReward)} COINS',
                        style: pixelStyle(size: 18, color: kPixelCoinGoldBright),
                      ),
                    ],
                  ),
                  if (result.bridgeCoinReward > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CoinIcon(currency: GameCurrency.bridgeCoins, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '+${formatGameNumber(result.bridgeCoinReward)} BRIDGE COINS',
                          style: pixelStyle(size: 18, color: kPixelBrandRedLight),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: PixelButton(
                label: 'NEXT ORDER',
                redStriped: true,
                onPressed: () {
                  GameState.instance.setShellSection(GameSection.table);
                  context.goNamed('game');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _resultTitle(BlendResult result) {
  return switch (result.outcomeRarity) {
    OutcomeRarity.mystic => '✦ MYSTIC SCENT DISCOVERED ✦',
    OutcomeRarity.legendary => '✦ LEGENDARY SCENT DISCOVERED ✦',
    _ => result.isNew ? '✦ NEW SCENT DISCOVERED ✦' : '✦ SCENT BLENDED ✦',
  };
}
