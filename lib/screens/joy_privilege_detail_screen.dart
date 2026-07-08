import 'package:flutter/material.dart';

import '../core/branding.dart';
import '../models/joy_privilege.dart';
import '../services/app_refresh_service.dart';
import '../services/joy_service.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';
import '../widgets/joy_code_display.dart';

class JoyPrivilegeDetailScreen extends StatelessWidget {
  const JoyPrivilegeDetailScreen({super.key, required this.privilegeId});

  final String privilegeId;

  @override
  Widget build(BuildContext context) {
    final item = JoyService.instance.privilegeById(privilegeId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Privilege'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.joy,
                ),
                child: item == null
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView(
                            physics: kGlassRefreshPhysics,
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Text(
                                    'Privilege not found.',
                                    style: bodyStyle(size: 14, color: kTextMuted),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : SingleChildScrollView(
                        physics: kGlassRefreshPhysics,
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                        child: JoyCodeDisplay(
                          code: item.code,
                          title: item.name,
                          expired: item.status != JoyPrivilegeStatus.available,
                          conditions: item.conditions,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
