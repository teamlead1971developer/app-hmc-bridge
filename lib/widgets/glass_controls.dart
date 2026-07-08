import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/company.dart';
import 'glass_card.dart';

/// Sub-screen nav: 36px glass circle back + title 17/600.
class GlassPageHeader extends StatelessWidget {
  const GlassPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
      child: Row(
        children: [
          GlassIconButton(
            icon: LucideIcons.chevronLeft,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('home');
              }
            },
            size: 36,
            circular: true,
          ),
          const SizedBox(width: 12),
          Text(title, style: displayStyle(size: 17, weight: 600)),
        ],
      ),
    );
  }
}

/// Section title row with consistent spacing below (menu screen content blocks).
class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.bottomSpacing = 12,
  });

  final String title;
  final Widget? trailing;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: bodyStyle(size: 14, weight: 600)),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

/// Glass circle/square icon button (36–52px).
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36,
    this.circular = true,
    this.iconSize = 16,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool circular;
  final double iconSize;
  final Color? iconColor;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.circular ? widget.size / 2 : 14.0;
    final scale = _pressed ? 0.98 : 1.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            },
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kGlassInnerFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: kGlassInnerBorder),
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor ?? Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

/// Primary red-gradient CTA with press scale and shadow.
class BridgePrimaryButton extends StatefulWidget {
  const BridgePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;

  @override
  State<BridgePrimaryButton> createState() => _BridgePrimaryButtonState();
}

class _BridgePrimaryButtonState extends State<BridgePrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : 1.0;
    final child = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: kRedGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: widget.onPressed == null
              ? null
              : (_pressed
                  ? [
                      BoxShadow(
                        color: const Color(0x73AC0F0D).withValues(alpha: 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ]
                  : kPrimaryButtonShadows),
        ),
        child: SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 19, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: bodyStyle(size: 15, weight: 600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      child: widget.expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

/// Secondary glass outline button.
class BridgeGlassButton extends StatefulWidget {
  const BridgeGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 50,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;

  @override
  State<BridgeGlassButton> createState() => _BridgeGlassButtonState();
}

class _BridgeGlassButtonState extends State<BridgeGlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : 1.0;
    final child = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kGlassInnerFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kGlassInnerBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 17, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 9),
            ],
            Text(widget.label, style: bodyStyle(size: 14, weight: 500)),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            },
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      child: widget.expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

/// Segmented pill: Sign in / Request account.
class AuthSegmentedPill extends StatelessWidget {
  const AuthSegmentedPill({
    super.key,
    required this.signInSelected,
    required this.onSignIn,
    required this.onRegister,
  });

  final bool signInSelected;
  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      radius: 999,
      blur: 20,
      child: Row(
        children: [
          Expanded(
            child: _SegmentCell(
              label: 'Sign in',
              selected: signInSelected,
              onTap: onSignIn,
            ),
          ),
          Expanded(
            child: _SegmentCell(
              label: 'Request account',
              selected: !signInSelected,
              onTap: onRegister,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentCell extends StatelessWidget {
  const _SegmentCell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kActiveFill : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: selected ? Border.all(color: kActiveBorder) : null,
        ),
        child: Text(
          label,
          style: bodyStyle(
            size: 13,
            weight: selected ? 600 : 400,
            color: selected ? kText : kTextMuted,
          ),
        ),
      ),
    );
  }
}

/// Glass input row with leading icon, floating label, and optional trailing.
class GlassInputRow extends StatelessWidget {
  const GlassInputRow({
    super.key,
    required this.label,
    required this.controller,
    this.icon = LucideIcons.mail,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 16,
      blur: 20,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: bodyStyle(size: 14),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                labelText: label,
                labelStyle: bodyStyle(size: 11, color: kTextFaint),
                floatingLabelStyle: bodyStyle(size: 11, color: kTextFaint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Glass company picker for auth — opens a bottom sheet list.
class GlassCompanySelector extends StatelessWidget {
  const GlassCompanySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Company value;
  final ValueChanged<Company> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<Company>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CompanyPickerSheet(selected: value),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        radius: 16,
        blur: 20,
        child: Row(
          children: [
            Icon(LucideIcons.building2, size: 18, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company', style: bodyStyle(size: 11, color: kTextFaint)),
                  const SizedBox(height: 2),
                  Text(value.label, style: bodyStyle(size: 14)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronDown, size: 18, color: kTextFaint),
          ],
        ),
      ),
    );
  }
}

class _CompanyPickerSheet extends StatelessWidget {
  const _CompanyPickerSheet({required this.selected});

  final Company selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        0,
        22,
        22 + MediaQuery.paddingOf(context).bottom,
      ),
      child: GlassCard(
        radius: 22,
        blur: 28,
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Select company',
                style: displayStyle(size: 17, weight: 600),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final company in Company.values)
                    _CompanyOption(
                      company: company,
                      selected: company == selected,
                      onTap: () => Navigator.of(context).pop(company),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyOption extends StatefulWidget {
  const _CompanyOption({
    required this.company,
    required this.selected,
    required this.onTap,
  });

  final Company company;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CompanyOption> createState() => _CompanyOptionState();
}

class _CompanyOptionState extends State<_CompanyOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: widget.selected ? kActiveFill : kGlassInnerFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.selected ? kActiveBorder : kGlassInnerBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.company.label,
                    style: bodyStyle(
                      size: 14,
                      weight: widget.selected ? 600 : 500,
                    ),
                  ),
                ),
                if (widget.selected)
                  Icon(LucideIcons.check, size: 16, color: kRedLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Red-gradient avatar circle with initials.
class AvatarBadge extends StatefulWidget {
  const AvatarBadge({
    super.key,
    required this.initials,
    this.size = 42,
    this.radius,
    this.onTap,
  });

  final String initials;
  final double size;
  final double? radius;
  final VoidCallback? onTap;

  @override
  State<AvatarBadge> createState() => _AvatarBadgeState();
}

class _AvatarBadgeState extends State<AvatarBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.radius ?? widget.size / 2;
    final avatar = Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: kAvatarGradient,
        borderRadius: BorderRadius.circular(r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66AC0F0D),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Text(
        widget.initials,
        style: bodyStyle(
          size: widget.size * 0.31,
          weight: 600,
          color: Colors.white,
        ),
      ),
    );

    if (widget.onTap == null) return avatar;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: avatar,
      ),
    );
  }
}

/// Category chip — red-tint when accent, plain glass otherwise.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.accent = false,
    this.uppercase = true,
  });

  final String label;
  final bool accent;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final text = uppercase ? label.toUpperCase() : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent ? kRedTintFill : kGlassInnerFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent ? kRedTintBorder : kGlassBorder),
      ),
      child: Text(
        text,
        style: bodyStyle(
          size: 10,
          weight: 600,
          color: accent ? kRedLight : kTextMuted,
        ),
      ),
    );
  }
}

/// Filter chip for announcements list.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kActiveFill : kGlassFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? kActiveBorder : kGlassBorder),
        ),
        child: Text(
          label,
          style: bodyStyle(
            size: 12,
            weight: selected ? 600 : 400,
            color: selected ? kText : kTextMuted,
          ),
        ),
      ),
    );
  }
}

/// 34–38px red-tint icon tile.
class RedTintIconTile extends StatelessWidget {
  const RedTintIconTile({
    super.key,
    required this.icon,
    this.size = 38,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kRedTintFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kRedTintBorder),
      ),
      child: Icon(icon, size: 18, color: kRedLight),
    );
  }
}
