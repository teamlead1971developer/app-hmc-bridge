import 'package:flutter/foundation.dart';

/// Debug-only overrides for location and clock time (not persisted).
class DebugSessionService extends ChangeNotifier {
  DebugSessionService._();

  static final instance = DebugSessionService._();

  DebugLocationMode _locationMode = DebugLocationMode.defaultMock;
  DebugTimePreset _timePreset = DebugTimePreset.device;
  DateTime? _simulatedNow;

  DebugLocationMode get locationMode => _locationMode;
  DebugTimePreset get timePreset => _timePreset;
  DateTime? get simulatedNow => _simulatedNow;

  /// Effective clock for attendance rules and record timestamps.
  DateTime get effectiveNow => _simulatedNow ?? DateTime.now();

  bool get hasSimulatedTime => _simulatedNow != null;

  void setLocationMode(DebugLocationMode mode) {
    if (_locationMode == mode) return;
    _locationMode = mode;
    notifyListeners();
  }

  void setSimulatedTime(DateTime? time) {
    _simulatedNow = time;
    _timePreset = time == null ? DebugTimePreset.device : _timePreset;
    notifyListeners();
  }

  void presetMorning() => _applyPreset(DebugTimePreset.morning, 9, 5);

  void presetAfternoon() => _applyPreset(DebugTimePreset.afternoon, 14, 30);

  void presetAfterShift() => _applyPreset(DebugTimePreset.afterShift, 18, 15);

  void clearSimulatedTime() {
    _simulatedNow = null;
    _timePreset = DebugTimePreset.device;
    notifyListeners();
  }

  void _applyPreset(DebugTimePreset preset, int hour, int minute) {
    _timePreset = preset;
    _simulatedNow = _dateAt(hour, minute);
    notifyListeners();
  }

  void resetAll() {
    _locationMode = DebugLocationMode.defaultMock;
    _timePreset = DebugTimePreset.device;
    _simulatedNow = null;
    notifyListeners();
  }

  DateTime _dateAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String get locationModeLabel => switch (_locationMode) {
        DebugLocationMode.near => 'Near office (25 m)',
        DebugLocationMode.far => 'Far from office (3.4 km)',
        DebugLocationMode.defaultMock => 'Default mock (toggles)',
      };

  String get simulatedTimeLabel {
    if (_simulatedNow == null) return 'Device time';
    final t = _simulatedNow!;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m · simulated';
  }
}

enum DebugLocationMode {
  defaultMock,
  near,
  far,
}

enum DebugTimePreset {
  device,
  morning,
  afternoon,
  afterShift,
}
