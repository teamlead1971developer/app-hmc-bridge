import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/game/pixel_theme.dart';
import 'game_shell_screen.dart';

/// Shows a pixel loading screen on first game entry, then [GameShellScreen].
class GameEntryScreen extends StatefulWidget {
  const GameEntryScreen({super.key});

  static bool bootComplete = false;

  @override
  State<GameEntryScreen> createState() => _GameEntryScreenState();
}

class _GameEntryScreenState extends State<GameEntryScreen>
    with SingleTickerProviderStateMixin {
  static const _phrases = [
    'Preparing your blending table',
    'Sorting top notes on the tray',
    'Warming heart accords',
    'Grounding the base layer',
    'Polishing the flask',
    'Almost ready',
  ];

  static const _bootDuration = Duration(milliseconds: 2800);

  late final AnimationController _progressController;
  Timer? _phraseTimer;
  int _phraseIndex = 0;
  bool _ready = GameEntryScreen.bootComplete;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: _bootDuration);
    if (_ready) {
      _progressController.value = 1;
      return;
    }
    _startBoot();
  }

  Future<void> _startBoot() async {
    _progressController.forward();
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (!mounted) return;
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
    });
    await Future<void>.delayed(_bootDuration);
    _phraseTimer?.cancel();
    GameEntryScreen.bootComplete = true;
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const GameShellScreen();
    return _GameLoadingView(
      phrase: _phrases[_phraseIndex],
      progress: _progressController,
    );
  }
}

class _GameLoadingView extends StatelessWidget {
  const _GameLoadingView({
    required this.phrase,
    required this.progress,
  });

  final String phrase;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPixelCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _GameLoadingIcon(),
              const SizedBox(height: 28),
              Text(
                'THE BLENDING ROOM',
                textAlign: TextAlign.center,
                style: pixelStyle(
                  size: 26,
                  weight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'cozy apothecary · pixel blend',
                style: vtStyle(size: 17, color: kPixelMutedLight),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) {
                  return Column(
                    children: [
                      Text(
                        '${phrase}…',
                        textAlign: TextAlign.center,
                        style: vtStyle(size: 20, color: kPixelMuted),
                      ),
                      const SizedBox(height: 16),
                      _LoadingProgressBar(value: progress.value),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameLoadingIcon extends StatelessWidget {
  const _GameLoadingIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: kPixelWood,
        border: Border.all(color: kPixelWoodDark, width: kPixelBorderWidth),
        boxShadow: const [kPixelCardShadow],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 26,
            decoration: BoxDecoration(
              color: kPixelFlaskGlass,
              border: Border.all(color: kPixelWoodDark, width: 3),
            ),
          ),
          SizedBox(
            width: 56,
            height: 58,
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
                    heightFactor: 0.62,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: stripedDecoration(kPixelAmber, const Color(0xFFC9822C)),
                    ),
                  ),
                ),
                Positioned(left: 14, bottom: 16, child: _bubble(6)),
                Positioned(right: 16, bottom: 28, child: _bubble(5)),
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

class _LoadingProgressBar extends StatelessWidget {
  const _LoadingProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: kPixelRecessed,
        border: Border.all(color: kPixelWoodDark, width: kPixelBorderWidth),
      ),
      clipBehavior: Clip.hardEdge,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: stripedGradient(kPixelBridgeRed, kPixelBridgeRedDark),
            ),
          ),
        ),
      ),
    );
  }
}
