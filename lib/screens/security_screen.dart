import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_preferences_service.dart';
import '../services/app_refresh_service.dart';
import '../widgets/app_navbar.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferencesService.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar.page(title: 'Security'),
            Expanded(
              child: ListenableBuilder(
                listenable: prefs,
                builder: (context, _) {
                  return GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.general,
                    ),
                    child: SingleChildScrollView(
                      physics: kGlassRefreshPhysics,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const GlassSectionHeader('Unlock'),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              radius: 16,
                              blur: 22,
                              child: _SecurityToggle(
                                label: 'Biometric unlock',
                                subtitle: 'Use Face ID or fingerprint on unlock',
                                value: prefs.biometricUnlockEnabled,
                                onChanged: prefs.setBiometricUnlockEnabled,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const GlassSectionHeader('PIN'),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              radius: 16,
                              blur: 22,
                              child: _SecurityLinkRow(
                                label: 'Change PIN',
                                subtitle: 'Update your app unlock PIN',
                                onTap: () => context.pushNamed('changePin'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityToggle extends StatelessWidget {
  const _SecurityToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyStyle(size: 14, weight: 500)),
                const SizedBox(height: 2),
                Text(subtitle, style: bodyStyle(size: 12, color: kTextMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: kBrandColor,
          ),
        ],
      ),
    );
  }
}

class _SecurityLinkRow extends StatelessWidget {
  const _SecurityLinkRow({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: bodyStyle(size: 14, weight: 500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: bodyStyle(size: 12, color: kTextMuted)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
          ],
        ),
      ),
    );
  }
}
