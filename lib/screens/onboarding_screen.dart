import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_preferences_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _slides = [
    (
      icon: LucideIcons.fingerprint,
      title: 'Check in on site or remotely',
      body: 'Use the home card to check in at the office or submit remote attendance with photo proof.',
    ),
    (
      icon: LucideIcons.calendarMinus,
      title: 'Leave and expenses in one place',
      body: 'Submit leave requests and travel claims, then track status from your inbox.',
    ),
    (
      icon: LucideIcons.bell,
      title: 'Stay informed',
      body: 'Announcements, payslips, and approvals appear in your notification inbox.',
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPreferencesService.instance.setOnboardingCompleted(true);
    if (!mounted) return;
    context.goNamed('home');
  }

  void _next() {
    if (_index >= _slides.length - 1) {
      _finish();
      return;
    }
    _page.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: bodyStyle(size: 13, color: kTextMuted),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassCard(
                          radius: 22,
                          blur: 26,
                          shadows: kHeroCardShadows,
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              RedTintIconTile(icon: slide.icon, size: 48),
                              const SizedBox(height: 20),
                              Text(
                                slide.title,
                                style: displayStyle(size: 22, weight: 600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide.body,
                                style: bodyStyle(
                                  size: 14,
                                  color: kTextMuted,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Container(
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? kRedLight
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              BridgePrimaryButton(
                label: _index >= _slides.length - 1 ? 'Get started' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
