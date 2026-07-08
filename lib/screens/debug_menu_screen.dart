import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../services/app_refresh_service.dart';
import '../services/attendance_service.dart';
import '../services/debug_session_service.dart';
import '../services/location_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_refresh.dart';

/// Debug-only panel to simulate GPS distance and clock time for attendance flows.
class DebugMenuScreen extends StatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  State<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends State<DebugMenuScreen> {
  final _debug = DebugSessionService.instance;
  final _attendance = AttendanceService.instance;

  double? _distanceMeters;
  bool _loadingDistance = false;

  @override
  void initState() {
    super.initState();
    _debug.addListener(_onDebugChanged);
    _attendance.addListener(_onDebugChanged);
    _refreshDistance();
  }

  @override
  void dispose() {
    _debug.removeListener(_onDebugChanged);
    _attendance.removeListener(_onDebugChanged);
    super.dispose();
  }

  void _onDebugChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshDistance() async {
    setState(() => _loadingDistance = true);
    final distance = await LocationService.instance.distanceToOfficeMeters();
    if (!mounted) return;
    setState(() {
      _distanceMeters = distance;
      _loadingDistance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const GlassPageHeader(title: 'Debug'),
              Expanded(
                child: GlassRefreshIndicator(
                  onRefresh: () => AppRefreshService.refresh(
                    AppRefreshScope.general,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView(
                        physics: kGlassRefreshPhysics,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight,
                            child: Center(
                              child: Text(
                                'Debug menu is only available in debug builds.',
                                style: bodyStyle(size: 14, color: kTextMuted),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = _debug.effectiveNow;
    final today = _attendance.forDate(now);
    final status = switch ((_attendance.isDayClosed, _attendance.isCheckedIn, _attendance.canCheckOutNow)) {
      (true, _, _) => 'Day complete (checked out)',
      (false, false, _) => 'Not checked in',
      (false, true, false) => 'On shift (before ${AttendanceService.defaultShiftEnd})',
      (false, true, true) => 'Ready to check out',
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GlassPageHeader(title: 'Debug session'),
            Expanded(
              child: GlassRefreshIndicator(
                onRefresh: () => AppRefreshService.refresh(
                  AppRefreshScope.general,
                ),
                child: SingleChildScrollView(
                  physics: kGlassRefreshPhysics,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      radius: 18,
                      blur: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current state', style: bodyStyle(size: 14, weight: 600)),
                          const SizedBox(height: 10),
                          _StatusRow(label: 'Clock', value: _debug.simulatedTimeLabel),
                          _StatusRow(
                            label: 'Distance',
                            value: _loadingDistance
                                ? 'Measuring…'
                                : '${_distanceMeters?.round() ?? '—'} m',
                          ),
                          _StatusRow(label: 'Today', value: status),
                          if (today.checkIn != null)
                            _StatusRow(
                              label: 'Check-in',
                              value: _formatTime(today.checkIn!.time),
                            ),
                          if (today.checkOut != null)
                            _StatusRow(
                              label: 'Check-out',
                              value: _formatTime(today.checkOut!.time),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const GlassSectionHeader('Simulated location'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChipButton(
                          label: 'Default toggle',
                          selected: _debug.locationMode == DebugLocationMode.defaultMock,
                          onTap: () {
                            _debug.setLocationMode(DebugLocationMode.defaultMock);
                            _refreshDistance();
                          },
                        ),
                        FilterChipButton(
                          label: 'Near office',
                          selected: _debug.locationMode == DebugLocationMode.near,
                          onTap: () {
                            _debug.setLocationMode(DebugLocationMode.near);
                            _refreshDistance();
                          },
                        ),
                        FilterChipButton(
                          label: 'Far (remote)',
                          selected: _debug.locationMode == DebugLocationMode.far,
                          onTap: () {
                            _debug.setLocationMode(DebugLocationMode.far);
                            _refreshDistance();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _debug.locationModeLabel,
                      style: bodyStyle(size: 12, color: kTextFaint),
                    ),
                    const SizedBox(height: 18),
                    const GlassSectionHeader('Simulated time'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChipButton(
                          label: 'Device time',
                          selected: _debug.timePreset == DebugTimePreset.device,
                          onTap: _debug.clearSimulatedTime,
                        ),
                        FilterChipButton(
                          label: '09:05 morning',
                          selected: _debug.timePreset == DebugTimePreset.morning,
                          onTap: _debug.presetMorning,
                        ),
                        FilterChipButton(
                          label: '14:30 afternoon',
                          selected: _debug.timePreset == DebugTimePreset.afternoon,
                          onTap: _debug.presetAfternoon,
                        ),
                        FilterChipButton(
                          label: '18:15 after shift',
                          selected: _debug.timePreset == DebugTimePreset.afterShift,
                          onTap: _debug.presetAfterShift,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const GlassSectionHeader('Attendance'),
                    BridgeGlassButton(
                      label: 'Open check-in screen',
                      icon: LucideIcons.fingerprint,
                      onPressed: () => context.pushNamed('checkin'),
                    ),
                    const SizedBox(height: 10),
                    BridgeGlassButton(
                      label: 'Refresh distance reading',
                      icon: LucideIcons.refreshCw,
                      onPressed: _refreshDistance,
                    ),
                    const SizedBox(height: 10),
                    BridgeGlassButton(
                      label: "Clear today's attendance",
                      icon: LucideIcons.trash2,
                      onPressed: _attendance.clearTodayRecords,
                    ),
                    const SizedBox(height: 14),
                    BridgePrimaryButton(
                      label: 'Reset all debug overrides',
                      icon: LucideIcons.rotateCcw,
                      onPressed: () {
                        _debug.resetAll();
                        _refreshDistance();
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Use near + morning for office check-in. Far + morning for remote check-in with photo. '
                      'Near + afternoon with an active check-in tests early office check-out (reason required). '
                      'Far + afternoon tests remote check-out.',
                      style: bodyStyle(size: 12, color: kTextFaint),
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

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: bodyStyle(size: 12, color: kTextFaint)),
          ),
          Expanded(
            child: Text(value, style: bodyStyle(size: 13, weight: 500)),
          ),
        ],
      ),
    );
  }
}
