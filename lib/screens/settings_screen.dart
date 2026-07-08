import 'package:flutter/material.dart';

import '../core/branding.dart';
import '../services/app_preferences_service.dart';
import '../services/app_refresh_service.dart';
import '../widgets/app_navbar.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferencesService.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const AppNavbar.page(title: 'Notifications'),
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
                            const GlassSectionHeader('Inbox'),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              radius: 16,
                              blur: 22,
                              child: Column(
                                children: [
                                  _SettingsToggle(
                                    label: 'Announcements',
                                    subtitle: 'Company news and updates',
                                    value: prefs.notifyAnnouncements,
                                    onChanged: prefs.setNotifyAnnouncements,
                                  ),
                                  _settingsDivider(),
                                  _SettingsToggle(
                                    label: 'Payslips',
                                    subtitle: 'When a new payslip is available',
                                    value: prefs.notifyPayslip,
                                    onChanged: prefs.setNotifyPayslip,
                                  ),
                                  _settingsDivider(),
                                  _SettingsToggle(
                                    label: 'Approvals',
                                    subtitle: 'Leave and expense status changes',
                                    value: prefs.notifyApprovals,
                                    onChanged: prefs.setNotifyApprovals,
                                  ),
                                ],
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

Widget _settingsDivider() {
  return Divider(
    height: 1,
    thickness: 1,
    color: Colors.white.withValues(alpha: 0.06),
  );
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
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
