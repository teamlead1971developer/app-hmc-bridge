import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import '../../widgets/game/pixel_theme.dart';
import '../../widgets/game/pixel_widgets.dart';

class BlendingTableSection extends StatelessWidget {
  const BlendingTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        return Column(
          children: [
            const GameHeader(
              title: 'THE BLENDING ROOM',
              subtitle: 'Order 12 of 14 · Day 6',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _OrderCard(order: state.currentOrder),
                    const SizedBox(height: 8),
                    _FlaskSection(state: state),
                    _TraySection(state: state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});

  final CustomerOrder order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: PixelPanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kPixelClay,
                border: Border.all(color: kPixelWoodDark, width: 4),
              ),
              child: Text(
                order.customerInitial,
                style: pixelStyle(size: 20, weight: FontWeight.w700, color: kPixelCream),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${order.customerName} asks:',
                            style: pixelStyle(size: 15),
                          ),
                        ),
                        Text(
                          _expanded ? '▲' : '▼',
                          style: vtStyle(size: 18, color: kPixelMutedLight),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              order.request,
                              style: vtStyle(size: 19, color: kPixelMuted),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (label, color) in order.tags)
                        PersonalityTag(label: label, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlaskSection extends StatelessWidget {
  const _FlaskSection({required this.state});

  final GameState state;

  void _openColorPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: state,
          builder: (context, _) => _FlaskColorPickerSheet(state: state),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fill = state.filledSlotCount / 3;
    final color1 = state.flaskColor1;
    final color2 = state.flaskColor2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () => _openColorPicker(context),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kPixelFlaskGlass,
                        border: Border.all(color: kPixelWoodDark, width: 4),
                      ),
                    ),
                    SizedBox(
                      width: 132,
                      height: 126,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: kPixelFlaskGlass,
                              border: Border.all(color: kPixelWoodDark, width: 4),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: 0.58 * fill.clamp(0.2, 1),
                              widthFactor: 1,
                              child: Container(
                                decoration: stripedDecoration(color1, color2),
                              ),
                            ),
                          ),
                          if (fill > 0) ...[
                            Positioned(left: 22, bottom: 30, child: _bubble(8)),
                            Positioned(left: 66, bottom: 48, child: _bubble(6)),
                            Positioned(right: 28, bottom: 20, child: _bubble(8)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.filledSlotCount} / 3 NOTES',
                style: vtStyle(size: 17, color: kPixelMutedLight),
              ),
              Text(
                'tap flask to recolor',
                style: vtStyle(size: 15, color: kPixelMutedLight),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                for (final layer in NoteLayer.values) ...[
                  _NoteSlot(state: state, layer: layer),
                  if (layer != NoteLayer.base) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      color: kPixelCoinGoldBright,
    );
  }
}

class _FlaskColorPickerSheet extends StatelessWidget {
  const _FlaskColorPickerSheet({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final scents = state.discoveredScents;
    final selected = state.selectedFlaskScentName;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.62,
      ),
      decoration: const BoxDecoration(
        color: kPixelWood,
        border: Border(top: BorderSide(color: kPixelWoodDark, width: 4)),
      ),
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('PICK FLASK COLOR', style: pixelStyle(size: 17)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Text('✕', style: vtStyle(size: 22, color: kPixelOnWoodMuted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose from your unlocked journal scents',
            style: vtStyle(size: 16, color: kPixelOnWoodMuted),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _FlaskColorOption(
                  selected: selected == null,
                  onTap: () {
                    state.setFlaskColorFromScent(null);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 52,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: kPixelFlaskGlass,
                                border: Border.all(color: kPixelWoodDark, width: 3),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: 0.55,
                                widthFactor: 1,
                                child: Container(
                                  decoration: stripedDecoration(
                                    GameState.defaultFlaskColor1,
                                    GameState.defaultFlaskColor2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('DEFAULT AMBER', style: pixelStyle(size: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                for (final scent in scents) ...[
                  _FlaskColorOption(
                    selected: selected == scent.name,
                    onTap: () {
                      state.setFlaskColorFromScent(scent.name);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        PixelBottle(
                          color: scent.color1,
                          width: 28,
                          height: 40,
                          striped: true,
                          stripeC2: scent.color2,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(scent.name, style: pixelStyle(size: 15)),
                              Text(
                                scent.notes,
                                style: vtStyle(size: 15, color: kPixelMutedLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        OutcomeRarityTag(rarity: scent.outcomeRarity, compact: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlaskColorOption extends StatelessWidget {
  const _FlaskColorOption({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPixelCard : kPixelRecessed,
          border: Border.all(
            color: selected ? kPixelCoinGold : kPixelWoodDark,
            width: selected ? 4 : 3,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _NoteSlot extends StatelessWidget {
  const _NoteSlot({required this.state, required this.layer});

  final GameState state;
  final NoteLayer layer;

  @override
  Widget build(BuildContext context) {
    final name = state.slots[layer];
    final ing = name == null ? null : state.ingredientByName(name);
    final empty = ing == null;
    final locked = state.slotsLocked;

    return GestureDetector(
      onTap: locked
          ? null
          : empty && state.pendingAssignName != null
              ? () => state.assignToSlot(layer, state.pendingAssignName!)
              : () {
                  if (!empty) state.clearSlot(layer);
                },
      child: Opacity(
        opacity: locked && !empty ? 0.85 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: empty ? kPixelRecessed : kPixelCard,
            border: Border.all(
              color: locked && !empty
                  ? kPixelCoinGold
                  : (empty ? kPixelDisabled : kPixelWoodDark),
              width: 4,
            ),
          ),
          child: empty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(layer.label, style: vtStyle(size: 15, color: kPixelDisabled)),
                  Text('tap from tray ↓', style: vtStyle(size: 18, color: kPixelDisabled)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(layer.label, style: vtStyle(size: 15, color: kPixelMutedLight)),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ing.color,
                          border: Border.all(color: kPixelWoodDark, width: 3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(ing.name, style: pixelStyle(size: 15)),
                    ],
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _TraySection extends StatelessWidget {
  const _TraySection({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPixelWood,
        border: Border(top: BorderSide(color: kPixelWoodDark, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BlendActionButton(state: state),
          const SizedBox(height: 10),
          Text(
            'TRAY · tap to assign',
            style: vtStyle(size: 17, color: kPixelOnWoodMuted),
          ),
          const SizedBox(height: 10),
          for (final layer in NoteLayer.values) ...[
            _TrayLayerRow(state: state, layer: layer),
            if (layer != NoteLayer.base) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _BlendActionButton extends StatelessWidget {
  const _BlendActionButton({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    if (state.isBlendReady) {
      return PixelButton(
        label: 'VIEW RESULT',
        redStriped: true,
        onPressed: () {
          final result = state.claimBlendResult();
          if (result != null && context.mounted) {
            context.pushNamed('gameResult');
          }
        },
      );
    }

    if (state.isBlending && !state.isBlendReady) {
      return _BlendProgressBar(blend: state.activeBlend!);
    }

    return PixelButton(
      label: 'BLEND IT',
      redStriped: true,
      onPressed: state.canBlend ? () => state.startBlend() : null,
    );
  }
}

class _BlendProgressBar extends StatelessWidget {
  const _BlendProgressBar({required this.blend});

  final ActiveBlend blend;

  @override
  Widget build(BuildContext context) {
    final progress = blend.progress;
    final remaining = formatBlendWait(blend.remaining);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: kPixelDisabled.withValues(alpha: 0.35),
        border: Border.all(color: kPixelWoodDark, width: kPixelBorderWidth),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: stripedGradient(kPixelBridgeRed, kPixelBridgeRedDark),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'BLENDING · $remaining',
              style: pixelStyle(
                size: 17,
                weight: FontWeight.w700,
                color: kPixelCream,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrayLayerRow extends StatelessWidget {
  const _TrayLayerRow({required this.state, required this.layer});

  final GameState state;
  final NoteLayer layer;

  @override
  Widget build(BuildContext context) {
    final items = state
        .ingredientsForLayer(layer)
        .where((ing) => ing.owned && ing.qty > 0)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Text(
              layer.shortLabel,
              style: vtStyle(size: 15, color: layer.accentColor),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final ing in items) ...[
                  IngredientTile(
                    name: ing.name,
                    color: ing.color,
                    qtyLabel: 'x${ing.qty}',
                    rarity: ing.rarity,
                    pulseOnTap: true,
                    onTap: state.slotsLocked ? null : () => state.assignIngredient(ing.name),
                  ),
                  const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
