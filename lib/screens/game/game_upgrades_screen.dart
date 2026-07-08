import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class GameUpgradesSection extends StatelessWidget {
  const GameUpgradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        final standard = state.upgrades.where((u) => u.tier == UpgradeTier.standard);
        final premium = state.upgrades.where((u) => u.tier == UpgradeTier.premium);

        return Column(
          children: [
            const GameHeader(title: 'UPGRADES'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _SectionHeader(
                    color: kPixelCoinGold,
                    title: 'STANDARD',
                    subtitle: '· pay with Coins',
                  ),
                  const SizedBox(height: 8),
                  for (final up in standard) _UpgradeRow(upgrade: up),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    color: kPixelBrandRed,
                    title: 'PREMIUM',
                    subtitle: '· pay with Bridge Coins',
                    subtitleColor: kPixelBrandRed,
                  ),
                  const SizedBox(height: 8),
                  for (final up in premium) _UpgradeRow(upgrade: up, premium: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.color,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
  });

  final Color color;
  final String title;
  final String subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: kPixelWoodDark, width: 3),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: pixelStyle(size: 15, letterSpacing: 1)),
        Text(subtitle, style: vtStyle(size: 15, color: subtitleColor ?? kPixelMutedLight)),
      ],
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({required this.upgrade, this.premium = false});

  final GameUpgrade upgrade;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final currency = premium ? GameCurrency.bridgeCoins : GameCurrency.coins;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: premium ? kPixelWoodDark : kPixelCard,
        border: Border.all(
          color: premium ? kPixelWoodDarkest : kPixelWoodDark,
          width: 4,
        ),
        boxShadow: const [kPixelCardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: upgrade.color,
              border: Border.all(
                color: premium ? kPixelWoodDarkest : kPixelWoodDark,
                width: 4,
              ),
            ),
            child: Text(
              upgrade.glyph,
              style: pixelStyle(size: 17, color: kPixelCream),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upgrade.name,
                  style: pixelStyle(
                    size: 14,
                    color: premium ? kPixelCream : kPixelInk,
                  ),
                ),
                Text(
                  upgrade.description,
                  style: vtStyle(
                    size: 15,
                    color: premium ? kPixelOnWoodMuted2 : kPixelMutedLight,
                  ),
                ),
                Text(
                  upgrade.levelLabel,
                  style: vtStyle(
                    size: 14,
                    color: premium ? kPixelBrandRedLight : kPixelSpice,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  CoinIcon(currency: currency, size: 12),
                  Text(
                    '${upgrade.cost}',
                    style: vtStyle(
                      size: 17,
                      color: premium ? kPixelCream : kPixelInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: upgrade.isMaxed ? null : () => GameState.instance.upgrade(upgrade),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: premium && !upgrade.isMaxed
                        ? stripedGradient(kPixelBridgeRed, kPixelBridgeRedDark)
                        : null,
                    color: premium
                        ? (upgrade.isMaxed ? kPixelMutedLight : null)
                        : (upgrade.isMaxed ? kPixelMutedLight : kPixelSpice),
                    border: Border.all(
                      color: premium ? kPixelWoodDarkest : kPixelWoodDark,
                      width: 3,
                    ),
                  ),
                  child: Text(
                    upgrade.isMaxed ? 'MAX' : 'UPGRADE',
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
