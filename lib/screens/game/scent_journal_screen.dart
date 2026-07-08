import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class ScentJournalSection extends StatelessWidget {
  const ScentJournalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        final discovered = state.discoveredScents;
        final undiscovered = GameState.totalJournalScents - discovered.length;

        return Column(
          children: [
            GameHeader(
              title: 'SCENT JOURNAL',
              subtitle: '${discovered.length} of ${GameState.totalJournalScents} scents discovered',
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: discovered.length + undiscovered,
                itemBuilder: (context, index) {
                  if (index < discovered.length) {
                    return _DiscoveredCard(scent: discovered[index]);
                  }
                  return _UndiscoveredCard();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Discover new blends to fill your journal',
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

class _DiscoveredCard extends StatelessWidget {
  const _DiscoveredCard({required this.scent});

  final DiscoveredScent scent;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PixelBottle(
            color: scent.color1,
            width: 32,
            height: 46,
            striped: true,
            stripeC2: scent.color2,
          ),
          const SizedBox(height: 8),
          Text(
            scent.name,
            textAlign: TextAlign.center,
            style: pixelStyle(size: 13),
          ),
          const SizedBox(height: 4),
          OutcomeRarityTag(rarity: scent.outcomeRarity, compact: true),
          const SizedBox(height: 4),
          Text(
            scent.notes,
            textAlign: TextAlign.center,
            style: vtStyle(size: 14, color: kPixelMutedLight),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: kPixelGreen,
              border: Border.all(color: kPixelWoodDark, width: 2),
            ),
            child: Text(
              'BEST ${scent.bestMatch}%',
              style: vtStyle(size: 14, color: kPixelCream),
            ),
          ),
        ],
      ),
    );
  }
}

class _UndiscoveredCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPixelRecessed,
        border: Border.all(color: kPixelDisabled, width: 3),
      ),
      child: Center(
        child: Text('?', style: vtStyle(size: 32, color: kPixelDisabled)),
      ),
    );
  }
}
