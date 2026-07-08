import 'package:flutter/material.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';
import 'blending_table_screen.dart';
import 'coin_pouch_screen.dart';
import 'game_scoreboard_screen.dart';
import 'game_upgrades_screen.dart';
import 'ingredient_shelf_screen.dart';
import 'scent_journal_screen.dart';

class GameShellScreen extends StatelessWidget {
  const GameShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final section = GameState.instance.shellSection;
        return Scaffold(
          backgroundColor: kPixelCream,
          body: Column(
            children: [
              Expanded(child: _sectionBody(section)),
              GameNavBar(
                active: section,
                onSectionSelected: GameState.instance.setShellSection,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionBody(GameSection section) {
    return switch (section) {
      GameSection.table => const BlendingTableSection(),
      GameSection.shelf => const IngredientShelfSection(),
      GameSection.journal => const ScentJournalSection(),
      GameSection.ranks => const GameScoreboardSection(),
      GameSection.redeem => const CoinPouchSection(),
      GameSection.upgrades => const GameUpgradesSection(),
    };
  }
}
