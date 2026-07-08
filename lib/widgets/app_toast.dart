import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';

/// App-wide transient feedback via [ShadToast].
abstract final class AppToast {
  static const _duration = Duration(seconds: 4);
  static const _background = Color(0xFF1A1A1E);

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    bool destructive = false,
    Duration? duration,
  }) {
    final toaster = ShadToaster.maybeOf(context);
    if (toaster == null) return;

    final description = Text(message, style: bodyStyle(size: 13));
    final titleWidget = title == null ? null : Text(title, style: bodyStyle(size: 14, weight: 600));

    final toast = destructive
        ? ShadToast.destructive(
            alignment: Alignment.bottomCenter,
            showCloseIconOnlyWhenHovered: false,
            duration: duration ?? _duration,
            title: titleWidget,
            description: description,
          )
        : ShadToast(
            alignment: Alignment.bottomCenter,
            showCloseIconOnlyWhenHovered: false,
            duration: duration ?? _duration,
            backgroundColor: _background,
            title: titleWidget,
            description: description,
          );

    toaster.show(toast);
  }

  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, destructive: true);
  }
}
