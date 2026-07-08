import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../core/branding.dart';
import '../models/user.dart';
import '../services/app_refresh_service.dart';
import '../services/user_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class EmployeeCardScreen extends StatefulWidget {
  const EmployeeCardScreen({super.key});

  @override
  State<EmployeeCardScreen> createState() => _EmployeeCardScreenState();
}

class _EmployeeCardScreenState extends State<EmployeeCardScreen> {
  User? _user;
  double? _previousBrightness;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _boostBrightness();
  }

  Future<void> _loadUser() async {
    final user = await UserService.instance.fetchCurrentUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _onRefresh() async {
    await AppRefreshService.refresh(AppRefreshScope.employeeCard);
    await _loadUser();
  }

  Future<void> _boostBrightness() async {
    try {
      final brightness = ScreenBrightness();
      _previousBrightness = await brightness.application;
      await brightness.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  Future<void> _restoreBrightness() async {
    if (_previousBrightness == null) return;
    try {
      await ScreenBrightness()
          .setApplicationScreenBrightness(_previousBrightness!);
    } catch (_) {}
  }

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: user == null
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              )
            : GlassRefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const GlassPageHeader(title: 'Employee Card'),
                        const SizedBox(height: 18),
                        _EmployeeCard(user: user),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.user});

  final User user;

  static const _footerLines = [
    'Helmet Celt Co., Ltd. and affiliates',
    'Contact us: hr@karmakamet.co.th',
    'Tel: +66 2391 7391-2 Daxf : +66 2391 7389',
    'www.karmakamet.co.th',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      blur: 28,
      borderColor: kGlassBorderHero,
      shadows: const [kRedGlowShadow, ...kHeroCardShadows],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      clipChild: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.transparent,
                      kRedLight.withValues(alpha: 0.05),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _EmployeePhoto(user: user),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: displayStyle(size: 18, weight: 600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 12),
              Text(
                '${user.section} ${user.department}',
                style: bodyStyle(size: 14, color: kTextMuted, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: user.employeeId,
                width: 200,
                height: 48,
                drawText: false,
                color: kText,
              ),
              const SizedBox(height: 12),
              Text(
                user.employeeId,
                style: monoStyle(size: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 20),
              for (final line in _footerLines)
                Text(
                  line,
                  style: bodyStyle(size: 12, color: kTextMuted, height: 1.6),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmployeePhoto extends StatelessWidget {
  const _EmployeePhoto({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        height: 300,
        color: kGlassInnerFill,
        child: user.photoUrl == null
            ? Center(
                child: Text(
                  user.initials,
                  style: displayStyle(size: 48, weight: 600, color: kRedLight),
                ),
              )
            : Image.network(
                user.photoUrl!,
                fit: BoxFit.cover,
                width: 240,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      user.initials,
                      style: displayStyle(
                        size: 48,
                        weight: 600,
                        color: kRedLight,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
