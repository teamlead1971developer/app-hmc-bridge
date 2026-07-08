import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class GameScoreboardSection extends StatelessWidget {
  const GameScoreboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameState.instance;
    return Column(
      children: [
        const GameHeader(title: 'WEEKLY SCOREBOARD'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              for (final row in state.leaderboard) ...[
                _LeaderboardRow(row: row),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: kPixelWoodDark,
            border: Border(top: BorderSide(color: kPixelWoodDarkest, width: 4)),
          ),
          child: Column(
            children: [
              Text(
                '14 · You · Nok · 3,120',
                style: pixelStyle(size: 16, color: kPixelCream),
              ),
              Text(
                'Reach top 10 this week to earn Bridge Coins',
                style: vtStyle(size: 15, color: kPixelOnWoodMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.row});

  final ScoreboardRow row;

  @override
  Widget build(BuildContext context) {
    final top3 = row.isTopThree;
    Color rankBg;
    switch (row.rank) {
      case 1:
        rankBg = kPixelCoinGold;
      case 2:
        rankBg = const Color(0xFFC9C2B4);
      case 3:
        rankBg = const Color(0xFFC9822C);
      default:
        rankBg = kPixelRecessed;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: top3 ? kPixelCard : kPixelCream,
        border: Border.all(
          color: top3 ? kPixelWoodDark : kPixelDisabled,
          width: top3 ? 4 : 3,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankBg,
              border: Border.all(color: kPixelWoodDark, width: 3),
            ),
            child: Text('${row.rank}', style: vtStyle(size: 18, color: kPixelInk)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.name, style: pixelStyle(size: 14)),
                Text(row.scent, style: vtStyle(size: 15, color: kPixelMutedLight)),
              ],
            ),
          ),
          Text(row.score, style: vtStyle(size: 18)),
          const SizedBox(width: 8),
          Row(
            children: [
              const CoinIcon(currency: GameCurrency.bridgeCoins, size: 12),
              Text(row.reward, style: vtStyle(size: 16, color: kPixelBrandRedLight)),
            ],
          ),
        ],
      ),
    );
  }
}
