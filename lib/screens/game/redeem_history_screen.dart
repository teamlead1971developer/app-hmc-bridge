import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class RedeemHistoryScreen extends StatelessWidget {
  const RedeemHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final entries = GameState.instance.redeemHistory;
        return Scaffold(
          backgroundColor: kPixelCream,
          body: Column(
            children: [
              const GameHeader(
                title: 'COUPON HISTORY',
                subtitle: 'Bridge Coin coupons claimed',
                showBack: true,
                showCoins: false,
                showBridge: true,
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No coupons yet.\nClaim vouchers with Bridge Coins.',
                            textAlign: TextAlign.center,
                            style: vtStyle(size: 18, color: kPixelMutedLight),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _HistoryRow(entry: entries[index]);
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Newest first · staff coupons from Bridge Coins',
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final RedeemHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.color,
              border: Border.all(color: kPixelWoodDark, width: 4),
            ),
            child: Text(
              entry.glyph,
              style: pixelStyle(size: 17, color: kPixelCream),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatRedeemDate(entry.redeemedAt),
                  style: vtStyle(size: 14, color: kPixelMutedLight),
                ),
                const SizedBox(height: 2),
                Text(entry.itemName, style: pixelStyle(size: 14)),
                Text(
                  entry.description,
                  style: vtStyle(size: 15, color: kPixelMutedLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kPixelWoodDark,
                  border: Border.all(color: kPixelWoodDarkest, width: 2),
                ),
                child: Text(
                  'CLAIMED',
                  style: vtStyle(size: 12, color: kPixelOnWoodMuted),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('-', style: vtStyle(size: 17, color: kPixelBrandRedLight)),
                  const CoinIcon(currency: GameCurrency.bridgeCoins, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    formatGameNumber(entry.cost),
                    style: vtStyle(size: 17, color: kPixelBrandRedLight),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatRedeemDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;

  final time =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  if (diff == 0) return 'Today · $time';
  if (diff == 1) return 'Yesterday · $time';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day} · $time';
}
