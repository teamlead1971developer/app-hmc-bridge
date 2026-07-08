import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';

/// Top navigation bar shared across authenticated screens.
///
/// Use [AppNavbar.home] on the dashboard and [AppNavbar.page] on sub-screens
/// opened from the home menu (check-in, schedule, etc.).
class AppNavbar extends StatelessWidget {
  const AppNavbar.home({super.key, this.actions})
      : title = null,
        showBack = false;

  const AppNavbar.page({
    super.key,
    required String title,
    this.actions,
  })  : title = title,
        showBack = true;

  final String? title;
  final bool showBack;
  final List<Widget>? actions;

  static const _outerPadding = EdgeInsets.fromLTRB(16, 12, 16, 0);
  static const _innerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: _outerPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: _innerPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    if (showBack) ...[
                      ShadIconButton.ghost(
                        width: 28,
                        height: 28,
                        padding: EdgeInsets.zero,
                        icon: const Icon(LucideIcons.arrowLeft, size: 16),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed('home');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(title!, style: theme.textTheme.large),
                      )
                    else
                      Image.asset(kLogoAsset, height: 20, fit: BoxFit.contain),
                    if (title != null) const Spacer(),
                    ...?actions,
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
