import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../models/user.dart';
import '../services/app_refresh_service.dart';
import '../services/auth_session_service.dart';
import '../services/user_service.dart';
import '../widgets/app_toast.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService.instance;
  final _nickname = TextEditingController();
  final _phone = TextEditingController();

  User? _user;
  bool _loading = true;
  bool _saving = false;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _load();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = '${info.version} (${info.buildNumber})');
  }

  @override
  void dispose() {
    _nickname.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await _userService.fetchCurrentUser();
    if (!mounted) return;
    _nickname.text = user.nickname;
    _phone.text = user.phone;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    final user = await AppRefreshService.refreshProfile();
    if (!mounted) return;
    _nickname.text = user.nickname;
    _phone.text = user.phone;
    setState(() => _user = user);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = await _userService.updateProfile(
      nickname: _nickname.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _user = updated;
      _saving = false;
    });
    AppToast.success(context, 'Profile updated.');
  }

  Future<void> _signOut() async {
    await AuthSessionService.instance.signOut();
    if (!mounted) return;
    context.goNamed('auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'My profile'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: _onRefresh,
                child: _loading
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView(
                            physics: kGlassRefreshPhysics,
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Text(
                                    'Loading profile…',
                                    style: monoStyle(size: 14, color: kTextMuted),
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
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProfileHeader(user: _user!),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Work details'),
                          _ReadOnlyField(label: 'Full name', value: _user!.name),
                          const SizedBox(height: 8),
                          _ReadOnlyField(label: 'Work email', value: _user!.email),
                          const SizedBox(height: 8),
                          _ReadOnlyField(
                            label: 'Employee ID',
                            value: _user!.employeeId,
                            mono: true,
                          ),
                          const SizedBox(height: 8),
                          _ReadOnlyField(label: 'Department', value: _user!.department),
                          const SizedBox(height: 8),
                          _ReadOnlyField(
                            label: 'Section',
                            value: '${_user!.section} · ${_user!.role}',
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Contact details'),
                          _EditableField(
                            label: 'Preferred name',
                            controller: _nickname,
                            icon: LucideIcons.user,
                          ),
                          const SizedBox(height: 8),
                          _EditableField(
                            label: 'Mobile phone',
                            controller: _phone,
                            icon: LucideIcons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 18),
                          BridgePrimaryButton(
                            label: _saving ? 'Saving…' : 'Save changes',
                            icon: LucideIcons.check,
                            onPressed: _saving ? null : _save,
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('Settings'),
                          _ProfileMenuRow(
                            icon: LucideIcons.bell,
                            label: 'Notifications',
                            caption: 'Manage inbox alerts',
                            onTap: () => context.pushNamed('settings'),
                          ),
                          const SizedBox(height: 8),
                          _ProfileMenuRow(
                            icon: LucideIcons.shield,
                            label: 'Security',
                            caption: 'Biometric unlock and PIN',
                            onTap: () => context.pushNamed('security'),
                          ),
                          const SizedBox(height: 18),
                          const GlassSectionHeader('About'),
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            radius: 16,
                            blur: 22,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'App version',
                                        style: bodyStyle(size: 14, weight: 500),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _appVersion ?? 'Loading…',
                                        style: monoStyle(size: 12, color: kTextMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  kLogoAsset,
                                  height: 22,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 18),
                            const GlassSectionHeader('Developer'),
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              radius: 16,
                              blur: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Simulate GPS distance and clock time for attendance testing.',
                                    style: bodyStyle(size: 12, color: kTextMuted),
                                  ),
                                  const SizedBox(height: 12),
                                  BridgeGlassButton(
                                    label: 'Debug session',
                                    icon: LucideIcons.bug,
                                    onPressed: () => context.pushNamed('debug'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          BridgeGlassButton(
                            label: 'Sign out',
                            icon: LucideIcons.logOut,
                            onPressed: _signOut,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.lock, size: 12, color: kTextFaint),
                              const SizedBox(width: 6),
                              Text(
                                'Work details are managed by HR.',
                                style: bodyStyle(size: 11, color: kTextFaint),
                              ),
                            ],
                          ),
                        ],
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AvatarBadge(initials: user.initials, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: displayStyle(size: 18, weight: 600)),
                const SizedBox(height: 4),
                Text(
                  '${user.department} · ${user.employeeId}',
                  style: monoStyle(size: 12, color: kTextMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      blur: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
          const SizedBox(height: 4),
          Text(
            value,
            style: mono
                ? monoStyle(size: 13)
                : bodyStyle(size: 14),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatefulWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  State<_ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<_ProfileMenuRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          radius: 16,
          blur: 24,
          child: Row(
            children: [
              RedTintIconTile(icon: widget.icon, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: bodyStyle(size: 14, weight: 500)),
                    const SizedBox(height: 2),
                    Text(
                      widget.caption,
                      style: bodyStyle(size: 12, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      blur: 20,
      child: Row(
        children: [
          Icon(icon, size: 17, color: kTextFaint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyStyle(size: 11, color: kTextFaint)),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: bodyStyle(size: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
