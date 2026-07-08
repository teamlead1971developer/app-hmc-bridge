import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/joy_privilege.dart';
import '../services/app_refresh_service.dart';
import '../services/joy_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class JoyPrivilegesScreen extends StatefulWidget {
  const JoyPrivilegesScreen({super.key});

  @override
  State<JoyPrivilegesScreen> createState() => _JoyPrivilegesScreenState();
}

class _JoyPrivilegesScreenState extends State<JoyPrivilegesScreen> {
  final _joy = JoyService.instance;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _joy.ensureLoaded();
  }

  List<JoyPrivilege> get _items => _tab == 0
      ? _joy.availablePrivileges
      : _joy.inactivePrivileges;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Privileges'),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChipButton(
                      label: 'Available',
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChipButton(
                      label: 'Expired / Used',
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _joy,
                builder: (context, _) {
                  final items = _items;
                  return GlassRefreshIndicator(
                    onRefresh: () => AppRefreshService.refresh(
                      AppRefreshScope.joy,
                    ),
                    child: items.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight,
                                    child: Center(
                                      child: Text(
                                        _tab == 0
                                            ? 'No privileges available right now.'
                                            : 'No expired or used privileges.',
                                        style: bodyStyle(
                                          size: 14,
                                          color: kTextMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _PrivilegeRow(
                                item: item,
                                onTap: () => context.pushNamed(
                                  'joyPrivilegeDetail',
                                  pathParameters: {'id': item.id},
                                ),
                              );
                            },
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

class _PrivilegeRow extends StatelessWidget {
  const _PrivilegeRow({required this.item, required this.onTap});

  final JoyPrivilege item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = item.status == JoyPrivilegeStatus.available;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 16,
        blur: 24,
        child: Row(
          children: [
            RedTintIconTile(icon: LucideIcons.percent, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: bodyStyle(size: 14, weight: 500)),
                  const SizedBox(height: 3),
                  Text(
                    'Valid until ${formatJoyDate(item.validUntil)}',
                    style: bodyStyle(size: 12, color: kTextMuted),
                  ),
                  if (item.summary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.summary!,
                      style: bodyStyle(size: 11, color: kTextFaint),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            CategoryChip(
              label: item.status.label,
              accent: accent,
              uppercase: false,
            ),
          ],
        ),
      ),
    );
  }
}
