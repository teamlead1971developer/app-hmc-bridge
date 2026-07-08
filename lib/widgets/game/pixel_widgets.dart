import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/game/game_entities.dart';
import '../../services/game/game_state.dart';
import 'pixel_theme.dart';

enum GameCurrency { coins, bridgeCoins }

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.color = kPixelCard,
    this.borderColor = kPixelWoodDark,
    this.borderWidth = kPixelBorderWidth,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadow ? const [kPixelCardShadow] : null,
      ),
      child: child,
    );
  }
}

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.redStriped = false,
    this.backgroundColor,
    this.textColor = kPixelCream,
    this.expanded = true,
    this.fontSize = 17,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool redStriped;
  final Color? backgroundColor;
  final Color textColor;
  final bool expanded;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: enabled && redStriped
                ? stripedGradient(kPixelBridgeRed, kPixelBridgeRedDark)
                : null,
            color: !enabled
                ? (backgroundColor ?? kPixelDisabled).withValues(alpha: 0.5)
                : (enabled && !redStriped ? (backgroundColor ?? kPixelSpice) : null),
            border: Border.all(
              color: kPixelWoodDark,
              width: kPixelBorderWidth,
            ),
            boxShadow: enabled ? const [kPixelCardShadow] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: pixelStyle(
                size: fontSize,
                weight: FontWeight.w700,
                color: enabled ? textColor : kPixelOnWoodMuted,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({
    super.key,
    required this.currency,
    this.size = 16,
  });

  final GameCurrency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isCoin = currency == GameCurrency.coins;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCoin ? kPixelCoinGold : kPixelBridgeRed,
        border: Border.all(
          color: isCoin ? kPixelCoinGoldBorder : kPixelBridgeRedBorder,
          width: size <= 14 ? 2 : 3,
        ),
      ),
      child: Text(
        isCoin ? 'C' : 'B',
        style: pixelStyle(
          size: size * 0.55,
          weight: FontWeight.w700,
          color: isCoin ? const Color(0xFF5C3A0D) : kPixelCream,
        ),
      ),
    );
  }
}

class CoinChip extends StatelessWidget {
  const CoinChip({
    super.key,
    required this.currency,
  });

  final GameCurrency currency;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        final state = GameState.instance;
        final isCoin = currency == GameCurrency.coins;
        final value = isCoin ? state.coins : state.bridgeCoins;
        final textColor = isCoin ? kPixelCoinGoldBright : kPixelBrandRedLight;
        final targetSection =
            isCoin ? GameSection.upgrades : GameSection.redeem;
        final tooltip = isCoin ? 'Open upgrades' : 'Open coupons';

        return Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () => state.setShellSection(targetSection),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: kPixelWoodDark,
                border: Border.all(color: kPixelWoodDarkest, width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CoinIcon(currency: currency),
                  const SizedBox(width: 6),
                  Text(
                    formatGameNumber(value),
                    style: vtStyle(size: 19, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PixelBottle extends StatelessWidget {
  const PixelBottle({
    super.key,
    required this.color,
    this.width = 26,
    this.height = 37,
    this.striped = false,
    this.stripeC2,
  });

  final Color color;
  final double width;
  final double height;
  final bool striped;
  final Color? stripeC2;

  @override
  Widget build(BuildContext context) {
    final capW = width * 0.38;
    final capH = height * 0.19;
    final neckW = width * 0.28;
    final neckH = height * 0.12;
    final bodyH = height - capH - neckH;
    final bodyDecoration = striped
        ? stripedDecoration(color, stripeC2 ?? color.withValues(alpha: 0.85))
        : BoxDecoration(color: color);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: capW,
          height: capH,
          decoration: BoxDecoration(
            color: const Color(0xFFB9AE97),
            border: Border.all(color: kPixelWoodDark, width: 2),
          ),
        ),
        Container(
          width: neckW,
          height: neckH,
          decoration: BoxDecoration(
            color: const Color(0xFFB9AE97),
            border: Border.all(color: kPixelWoodDark, width: 2),
          ),
        ),
        Container(
          width: width,
          height: bodyH,
          decoration: bodyDecoration.copyWith(
            border: Border.all(color: kPixelWoodDark, width: 3),
          ),
        ),
      ],
    );
  }
}

class StripedBar extends StatelessWidget {
  const StripedBar({
    super.key,
    required this.percent,
    required this.c1,
    required this.c2,
    this.height = 16,
  });

  final double percent;
  final Color c1;
  final Color c2;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: kPixelRecessed,
        border: Border.all(color: kPixelWoodDark, width: 3),
      ),
      padding: const EdgeInsets.all(2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percent.clamp(0, 1),
          child: Container(
            decoration: stripedDecoration(c1, c2, axis: Axis.horizontal),
          ),
        ),
      ),
    );
  }
}

class IngredientTile extends StatefulWidget {
  const IngredientTile({
    super.key,
    required this.name,
    required this.color,
    required this.qtyLabel,
    this.rarity,
    this.layer,
    this.onTap,
    this.width = 78,
    this.height = 96,
    this.muted = false,
    this.pulseOnTap = false,
  });

  final String name;
  final Color color;
  final String qtyLabel;
  final IngredientRarity? rarity;
  final NoteLayer? layer;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool muted;
  final bool pulseOnTap;

  @override
  State<IngredientTile> createState() => _IngredientTileState();
}

class _IngredientTileState extends State<IngredientTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 65),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;
    if (widget.pulseOnTap) {
      await _pulseController.forward(from: 0);
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final layerColor = layer?.accentColor ?? kPixelWoodDark;

    final content = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.muted ? kPixelLockedTile : kPixelCream,
        border: Border.all(color: kPixelWoodDark, width: kPixelBorderWidth),
        boxShadow: const [kPixelCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (layer != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: layerColor,
                border: Border.all(color: kPixelWoodDark, width: 2),
              ),
              child: Text(
                layer.shortLabel,
                textAlign: TextAlign.center,
                style: vtStyle(size: 11, color: kPixelInk),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelBottle(
                  color: widget.muted ? kPixelLockedBottle : widget.color,
                  width: 22,
                  height: 30,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pixelStyle(
                      size: 11,
                      color: widget.muted ? kPixelMutedLight : kPixelInk,
                    ),
                  ),
                ),
                if (widget.rarity != null) ...[
                  const SizedBox(height: 2),
                  RarityTag(rarity: widget.rarity!, compact: true),
                ],
                Text(
                  widget.qtyLabel,
                  style: vtStyle(size: 12, color: kPixelMutedLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final tile = SizedBox(
      width: widget.width,
      height: widget.rarity != null ? widget.height + 14 : widget.height,
      child: widget.pulseOnTap
          ? ClipRect(
              child: ScaleTransition(scale: _scale, child: content),
            )
          : content,
    );

    final child = tile;

    return GestureDetector(onTap: _handleTap, child: child);
  }
}

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.label,
    required this.glyphColor,
    this.onTap,
    this.active = false,
  });

  final String label;
  final Color glyphColor;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? kPixelCard : kPixelWood,
            border: Border.all(
              color: active ? kPixelCoinGold : kPixelWoodDarkest,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: glyphColor,
                  border: Border.all(color: kPixelWoodDarkest, width: 2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: vtStyle(
                  size: 11,
                  color: active ? kPixelInk : kPixelOnWoodMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.showCoins = true,
    this.showBridge = true,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showCoins;
  final bool showBridge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14 + topInset, 16, 14),
      decoration: const BoxDecoration(
        color: kPixelWood,
        border: Border(bottom: BorderSide(color: kPixelWoodDark, width: 4)),
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPixelWoodDark,
                  border: Border.all(color: kPixelWoodDarkest, width: 3),
                ),
                child: Text('←', style: vtStyle(size: 22, color: kPixelOnWoodMuted)),
              ),
            ),
          if (showBack) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pixelStyle(
                    size: 18,
                    weight: FontWeight.w700,
                    color: kPixelCream,
                    letterSpacing: 1,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: vtStyle(size: 16, color: kPixelOnWoodMuted)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showCoins || showBridge) ...[
            if (showCoins) const CoinChip(currency: GameCurrency.coins),
            if (showCoins && showBridge) const SizedBox(width: 6),
            if (showBridge) const CoinChip(currency: GameCurrency.bridgeCoins),
          ],
        ],
      ),
    );
  }
}

/// Pixel-styled confirm dialog. Returns `true` if confirmed, `false` if cancelled.
Future<bool?> showPixelGameAlert(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'STAY',
  String confirmLabel = 'LEAVE',
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0xCC2A1B10),
    builder: (dialogContext) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Material(
            color: Colors.transparent,
            child: PixelPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: pixelStyle(size: 18, weight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: vtStyle(size: 18, color: kPixelMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PixelButton(
                          label: cancelLabel,
                          height: 44,
                          fontSize: 14,
                          backgroundColor: kPixelWood,
                          textColor: kPixelInk,
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PixelButton(
                          label: confirmLabel,
                          height: 44,
                          fontSize: 14,
                          redStriped: true,
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class GameNavBar extends StatelessWidget {
  const GameNavBar({
    super.key,
    required this.active,
    required this.onSectionSelected,
  });

  final GameSection active;
  final ValueChanged<GameSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const navHeight = 64.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 8, 10, 8 + bottomInset),
      decoration: const BoxDecoration(
        color: kPixelWoodDark,
        border: Border(top: BorderSide(color: kPixelWoodDarkest, width: 4)),
      ),
      child: SizedBox(
        height: navHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavButton(
              label: 'TABLE',
              glyphColor: kPixelClay,
              active: active == GameSection.table,
              onTap: () => onSectionSelected(GameSection.table),
            ),
            const SizedBox(width: 6),
            NavButton(
              label: 'SHELF',
              glyphColor: kPixelWoodNote,
              active: active == GameSection.shelf,
              onTap: () => onSectionSelected(GameSection.shelf),
            ),
            const SizedBox(width: 6),
            NavButton(
              label: 'RANKS',
              glyphColor: kPixelCoinGold,
              active: active == GameSection.ranks,
              onTap: () => onSectionSelected(GameSection.ranks),
            ),
            const SizedBox(width: 6),
            NavButton(
              label: 'BRIDGE',
              glyphColor: kPixelBridgeRed,
              onTap: () async {
                final leave = await showPixelGameAlert(
                  context,
                  title: 'LEAVE THE BLENDING ROOM?',
                  message: 'Return to the BRIDGE staff app.\nYour game progress is saved.',
                  cancelLabel: 'STAY',
                  confirmLabel: 'BRIDGE →',
                );
                if (leave == true && context.mounted) {
                  context.goNamed('home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileBarRow extends StatelessWidget {
  const ProfileBarRow({
    super.key,
    required this.bar,
  });

  final ScentProfileBar bar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(bar.label, style: vtStyle(size: 17, color: kPixelMuted)),
        ),
        Expanded(
          child: StripedBar(
            percent: bar.percent / 100,
            c1: bar.color1,
            c2: bar.color2,
          ),
        ),
      ],
    );
  }
}

class RarityTag extends StatelessWidget {
  const RarityTag({
    super.key,
    required this.rarity,
    this.compact = false,
  });

  final IngredientRarity rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 8,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: rarity.tagColor,
        border: Border.all(color: kPixelWoodDark, width: compact ? 2 : 3),
      ),
      child: Text(
        rarity.label,
        style: vtStyle(
          size: compact ? 11 : 15,
          color: rarity.tagTextColor,
        ),
      ),
    );
  }
}

class OutcomeRarityTag extends StatelessWidget {
  const OutcomeRarityTag({
    super.key,
    required this.rarity,
    this.compact = false,
  });

  final OutcomeRarity rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 8,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: rarity.tagColor,
        border: Border.all(color: kPixelWoodDark, width: compact ? 2 : 3),
      ),
      child: Text(
        rarity.label,
        style: vtStyle(
          size: compact ? 11 : 15,
          color: rarity.tagTextColor,
        ),
      ),
    );
  }
}

class PersonalityTag extends StatelessWidget {
  const PersonalityTag({
    super.key,
    required this.label,
    required this.color,
    this.onDark = false,
  });

  final String label;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: onDark ? kPixelWoodDarkest : kPixelWoodDark,
          width: 3,
        ),
      ),
      child: Text(
        label,
        style: vtStyle(size: 15, color: kPixelCream),
      ),
    );
  }
}

class PairChip extends StatelessWidget {
  const PairChip({
    super.key,
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kPixelCard,
        border: Border.all(color: kPixelWoodDark, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: kPixelWoodDark, width: 2),
            ),
          ),
          const SizedBox(width: 6),
          Text(name, style: pixelStyle(size: 13)),
        ],
      ),
    );
  }
}
