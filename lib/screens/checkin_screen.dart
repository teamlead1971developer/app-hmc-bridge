import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import '../core/osm_map_config.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import '../services/debug_session_service.dart';
import '../services/location_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_controls.dart';
import '../widgets/remote_attendance_panel.dart';
import '../widgets/slide_to_check_in.dart';

enum _LocationStatus { checking, near, far, error }

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _locationService = LocationService.instance;
  final _attendance = AttendanceService.instance;
  final _debug = DebugSessionService.instance;
  final _checkoutReason = TextEditingController();

  _LocationStatus _locationStatus = _LocationStatus.checking;
  double? _distanceMeters;
  LatLng? _userPosition;
  String _locationError = '';
  bool _slideCompleted = false;
  bool _remoteCompleted = false;
  String? _actionError;
  bool _wasCheckedIn = false;
  bool _wasCanCheckOut = false;
  bool _earlyCheckout = false;

  @override
  void initState() {
    super.initState();
    _wasCheckedIn = _attendance.isCheckedIn;
    _wasCanCheckOut = _attendance.canCheckOutNow;
    _debug.addListener(_onDebugChanged);
    _attendance.addListener(_onAttendanceChanged);
    _refreshLocation();
  }

  @override
  void dispose() {
    _debug.removeListener(_onDebugChanged);
    _attendance.removeListener(_onAttendanceChanged);
    _checkoutReason.dispose();
    super.dispose();
  }

  void _onDebugChanged() {
    _refreshLocation();
    if (mounted) setState(() {});
  }

  void _onAttendanceChanged() {
    final today = _attendance.forDate(_now);
    if (!today.hasRecords) {
      _resetActionState();
      _wasCheckedIn = false;
      _wasCanCheckOut = false;
      _earlyCheckout = false;
    } else {
      if (_wasCheckedIn != _checkedIn) {
        _slideCompleted = false;
        _remoteCompleted = false;
        _earlyCheckout = false;
        _wasCheckedIn = _checkedIn;
      }
      if (_wasCanCheckOut != _canCheckOut) {
        _slideCompleted = false;
        _remoteCompleted = false;
        _earlyCheckout = false;
        _wasCanCheckOut = _canCheckOut;
      }
    }
    if (mounted) setState(() {});
  }

  DateTime get _now => _debug.effectiveNow;

  bool get _checkedIn => _attendance.isCheckedIn;

  bool get _canCheckOut => _attendance.canCheckOutNow;

  bool get _onShift => _attendance.isOnShift;

  bool get _dayClosed => _attendance.isDayClosed;

  /// Show checkout controls when shift ended, or user chose early checkout.
  bool get _showCheckoutUi => _canCheckOut || (_onShift && _earlyCheckout);

  bool get _requiresCheckoutReason =>
      AttendanceService.requiresCheckoutReason(_now);

  bool get _withinRadius => _locationStatus == _LocationStatus.near;

  bool get _actionDone => _slideCompleted || _remoteCompleted;

  Future<void> _refreshLocation() async {
    setState(() => _locationStatus = _LocationStatus.checking);
    try {
      final location = await _locationService.getSimulatedLocation();
      if (!mounted) return;
      setState(() {
        _distanceMeters = location.distanceMeters;
        _userPosition = location.userPosition;
        _locationStatus =
            location.distanceMeters <= LocationService.nearOfficeRadiusMeters
                ? _LocationStatus.near
                : _LocationStatus.far;
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _locationStatus = _LocationStatus.error;
        _locationError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationStatus = _LocationStatus.error;
        _locationError = 'Could not determine your location.';
      });
    }
  }

  void _resetActionState() {
    _slideCompleted = false;
    _remoteCompleted = false;
    _actionError = null;
    _checkoutReason.clear();
    _earlyCheckout = false;
  }

  void _showBriefOfficeSuccess({required bool afterCheckIn}) {
    setState(() {
      _slideCompleted = true;
      _actionError = null;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final stillSamePhase = afterCheckIn
          ? _attendance.isCheckedIn
          : !_attendance.isCheckedIn;
      if (stillSamePhase) {
        setState(() => _slideCompleted = false);
      }
    });
  }

  Future<void> _officeCheckIn() async {
    if (_checkedIn || _dayClosed) return;
    _attendance.record(
      type: AttendanceType.checkIn,
      method: AttendanceMethod.office,
    );
    if (!mounted) return;
    _showBriefOfficeSuccess(afterCheckIn: true);
  }

  Future<void> _officeCheckOut() async {
    if (!_showCheckoutUi) return;
    String? reason;
    if (_requiresCheckoutReason) {
      reason = _checkoutReason.text.trim();
      if (reason.isEmpty) {
        setState(() => _actionError = 'Please provide a reason for early check-out.');
        throw Exception('reason required');
      }
    }
    _attendance.record(
      type: AttendanceType.checkOut,
      method: AttendanceMethod.office,
      reason: reason,
    );
    if (!mounted) return;
    _showBriefOfficeSuccess(afterCheckIn: false);
  }

  Future<void> _remoteCheckIn({required String photoPath, String? reason}) async {
    if (_checkedIn || _dayClosed) return;
    _attendance.record(
      type: AttendanceType.checkIn,
      method: AttendanceMethod.remote,
      photoPath: photoPath,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _remoteCompleted = true);
  }

  Future<void> _remoteCheckOut({required String photoPath, String? reason}) async {
    if (!_showCheckoutUi) return;
    _attendance.record(
      type: AttendanceType.checkOut,
      method: AttendanceMethod.remote,
      photoPath: photoPath,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _remoteCompleted = true);
  }

  String? _successLabel() {
    if (!_actionDone) return null;
    final today = _attendance.forDate(_now);
    final activities = today.activities;
    if (activities.isEmpty) return null;
    final last = activities.last;
    final t = last.time;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return last.type == AttendanceType.checkOut
        ? 'Checked out $time'
        : 'Checked in $time';
  }

  String _lastCheckInYesterday() {
    final yesterday = _now.subtract(const Duration(days: 1));
    for (final r in _attendance.records) {
      final t = r.time;
      if (r.type == AttendanceType.checkIn &&
          t.year == yesterday.year &&
          t.month == yesterday.month &&
          t.day == yesterday.day) {
        return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      }
    }
    return '08:47';
  }

  String get _screenTitle {
    if (_dayClosed) return 'Done for today';
    if (!_checkedIn) return 'Check in';
    if (_showCheckoutUi) return 'Check out';
    return 'Checked in';
  }

  String get _radiusHeadline {
    if (_onShift && !_showCheckoutUi) {
      return _withinRadius
          ? 'On shift · office check-in recorded'
          : 'On shift · remote check-in recorded';
    }
    if (_withinRadius) {
      return "You're within the office radius";
    }
    return _showCheckoutUi
        ? 'Remote check-out · outside office radius'
        : 'Remote check-in · outside office radius';
  }

  String get _radiusSubline {
    return switch (_locationStatus) {
      _LocationStatus.checking => 'Verifying GPS location…',
      _LocationStatus.error => _locationError,
      _ => () {
          final distance = _distanceMeters?.round() ?? 0;
          final mode = _withinRadius ? 'Office' : 'Remote';
          return 'BRIDGE HQ · $distance m · $mode · ${_debug.simulatedTimeLabel}';
        }(),
    };
  }

  Widget _buildDayClosedCard() {
    final today = _attendance.forDate(_now);
    final out = today.checkOut?.time;
    final outLabel = out == null
        ? '—'
        : '${out.hour.toString().padLeft(2, '0')}:${out.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      blur: 20,
      child: Row(
        children: [
          RedTintIconTile(icon: LucideIcons.circleCheck),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checked out at $outLabel',
                  style: bodyStyle(size: 15, weight: 600),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're done for today. See you tomorrow.",
                  style: bodyStyle(size: 12, color: kTextMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnShiftCard() {
    final today = _attendance.forDate(_now);
    final checkIn = today.checkIn;
    final time = checkIn?.time;
    final timeLabel = time == null
        ? '—'
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final method = checkIn?.method == AttendanceMethod.remote ? 'Remote' : 'Office';
    final end = AttendanceService.shiftEndFor(_now);
    final endLabel =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      blur: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RedTintIconTile(icon: LucideIcons.circleCheck),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Checked in at $timeLabel',
                  style: bodyStyle(size: 15, weight: 600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$method · Check-out opens at $endLabel',
            style: bodyStyle(size: 12, color: kTextMuted),
          ),
          const SizedBox(height: 12),
          BridgeGlassButton(
            label: 'Check out early',
            icon: LucideIcons.logOut,
            onPressed: () => setState(() => _earlyCheckout = true),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeAction() {
    if (_dayClosed) return _buildDayClosedCard();
    if (_onShift && !_showCheckoutUi) return _buildOnShiftCard();

    final checkingOut = _checkedIn && _showCheckoutUi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (checkingOut && _requiresCheckoutReason) ...[
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: 14,
            blur: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason', style: bodyStyle(size: 11, color: kTextFaint)),
                TextField(
                  controller: _checkoutReason,
                  enabled: !_slideCompleted,
                  style: bodyStyle(size: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Why are you leaving before shift end?',
                    hintStyle: bodyStyle(size: 14, color: kTextFaint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_actionError != null) ...[
          Text(_actionError!, style: bodyStyle(size: 12, color: kRedLight)),
          const SizedBox(height: 10),
        ],
        SlideToCheckIn(
          enabled: _withinRadius && !_slideCompleted,
          completed: _slideCompleted,
          label: checkingOut ? 'Slide to check out' : 'Slide to check in',
          successLabel: _successLabel(),
          onComplete: checkingOut ? _officeCheckOut : _officeCheckIn,
        ),
      ],
    );
  }

  Widget _buildRemoteAction() {
    if (_dayClosed) return _buildDayClosedCard();
    if (_onShift && !_showCheckoutUi) return _buildOnShiftCard();

    if (_remoteCompleted) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 16,
        blur: 20,
        child: Row(
          children: [
            RedTintIconTile(icon: LucideIcons.circleCheck),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _successLabel() ?? 'Saved',
                style: bodyStyle(size: 15, weight: 600),
              ),
            ),
          ],
        ),
      );
    }

    return RemoteAttendancePanel(
      actionLabel: _showCheckoutUi
          ? 'Proof photo for remote check-out'
          : 'Proof photo for remote check-in',
      submitLabel: _showCheckoutUi ? 'Submit check-out' : 'Submit check-in',
      reasonRequired: _showCheckoutUi && _requiresCheckoutReason,
      enabled: _locationStatus != _LocationStatus.checking,
      onSubmit: _showCheckoutUi ? _remoteCheckOut : _remoteCheckIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 52;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _MapHeader(
            distanceMeters: _distanceMeters,
            userPosition: _userPosition,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: MediaQuery.sizeOf(context).height * 0.28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kBaseColor,
                      kBaseColor.withValues(alpha: 0.75),
                      kBaseColor.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.52,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kBaseColor.withValues(alpha: 0),
                      kBaseColor.withValues(alpha: 0.75),
                      kBaseColor,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset,
            right: 6,
            child: OsmMapConfig.attributionBadge(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: LucideIcons.chevronLeft,
                        onPressed: () => context.pop(),
                        size: 36,
                        circular: true,
                      ),
                      const SizedBox(width: 12),
                      Text(_screenTitle, style: displayStyle(size: 17, weight: 600)),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GlassCard(
                radius: 26,
                blur: 30,
                borderColor: kGlassBorderHero,
                shadows: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(0, -20),
                    blurRadius: 60,
                  ),
                ],
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RedTintIconTile(
                          icon: _withinRadius
                              ? LucideIcons.circleCheck
                              : LucideIcons.mapPinOff,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _radiusHeadline,
                                style: bodyStyle(size: 15, weight: 600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _radiusSubline,
                                style: bodyStyle(size: 12, color: kTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ListenableBuilder(
                      listenable: Listenable.merge([_attendance, _debug]),
                      builder: (context, _) {
                        return _withinRadius
                            ? _buildOfficeAction()
                            : _buildRemoteAction();
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.clock, size: 13, color: kTextFaint),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Shift ${AttendanceService.defaultShiftStart} – ${AttendanceService.defaultShiftEnd} · Last check-in yesterday ${_lastCheckInYesterday()}',
                            style: bodyStyle(size: 12, color: kTextFaint),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    this.distanceMeters,
    this.userPosition,
  });

  final double? distanceMeters;
  final LatLng? userPosition;

  static const _mapZoom = 17.0;

  static const _userBlue = Color(0xFF4A9EFF);

  @override
  Widget build(BuildContext context) {
    final office = LocationService.office;
    final isFar = (distanceMeters ?? 0) > LocationService.nearOfficeRadiusMeters;

    final mapOptions = MapOptions(
      initialCenter: office,
      initialZoom: _mapZoom,
      initialCameraFit: isFar && userPosition != null
          ? CameraFit.coordinates(
              coordinates: [office, userPosition!],
              padding: const EdgeInsets.all(56),
            )
          : null,
      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
    );

    final markers = <Marker>[
      if (userPosition != null)
        Marker(
          point: userPosition!,
          width: 14,
          height: 14,
          alignment: Alignment.center,
          child: _MapDot(color: _userBlue),
        ),
      Marker(
        point: office,
        width: 14,
        height: 14,
        alignment: Alignment.center,
        child: _MapDot(color: kBrandColor),
      ),
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          options: mapOptions,
          children: [
            ...OsmMapConfig.tileLayersOnly(),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: office,
                  radius: LocationService.nearOfficeRadiusMeters,
                  useRadiusInMeter: true,
                  color: kBrandColor.withValues(alpha: 0.08),
                  borderColor: kRedLight.withValues(alpha: 0.55),
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ],
    );
  }
}


class _MapDot extends StatelessWidget {
  const _MapDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
