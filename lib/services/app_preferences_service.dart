import 'package:flutter/foundation.dart';

import 'session_storage.dart';

/// User-facing app preferences persisted across sessions.
class AppPreferencesService extends ChangeNotifier {
  AppPreferencesService._();

  static final instance = AppPreferencesService._();

  static const _onboardingKey = 'bridge_onboarding_complete';
  static const _biometricKey = 'bridge_biometric_unlock';
  static const _notifyApprovalsKey = 'bridge_notify_approvals';
  static const _notifyAnnouncementsKey = 'bridge_notify_announcements';
  static const _notifyPayslipKey = 'bridge_notify_payslip';

  SessionStorage? _storage;
  bool _initialized = false;

  bool onboardingCompleted = false;
  bool biometricUnlockEnabled = true;
  bool notifyApprovals = true;
  bool notifyAnnouncements = true;
  bool notifyPayslip = true;

  bool get isInitialized => _initialized;

  Future<SessionStorage> get _store async {
    _storage ??= await SessionStorageProvider.resolve();
    return _storage!;
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      final storage = await _store;
      onboardingCompleted = await storage.read(_onboardingKey) == 'true';
      biometricUnlockEnabled = await storage.read(_biometricKey) != 'false';
      notifyApprovals = await storage.read(_notifyApprovalsKey) != 'false';
      notifyAnnouncements = await storage.read(_notifyAnnouncementsKey) != 'false';
      notifyPayslip = await storage.read(_notifyPayslipKey) != 'false';
    } catch (e, stack) {
      debugPrint('AppPreferencesService.init failed: $e\n$stack');
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool value) async {
    onboardingCompleted = value;
    final storage = await _store;
    await storage.write(_onboardingKey, value ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> setBiometricUnlockEnabled(bool value) async {
    biometricUnlockEnabled = value;
    final storage = await _store;
    await storage.write(_biometricKey, value ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> setNotifyApprovals(bool value) async {
    notifyApprovals = value;
    final storage = await _store;
    await storage.write(_notifyApprovalsKey, value ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> setNotifyAnnouncements(bool value) async {
    notifyAnnouncements = value;
    final storage = await _store;
    await storage.write(_notifyAnnouncementsKey, value ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> setNotifyPayslip(bool value) async {
    notifyPayslip = value;
    final storage = await _store;
    await storage.write(_notifyPayslipKey, value ? 'true' : 'false');
    notifyListeners();
  }
}
