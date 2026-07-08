import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/company.dart';
import 'session_storage.dart';
import 'user_service.dart';

/// Persists corporate sign-in and PIN unlock state across app restarts.
class AuthSessionService extends ChangeNotifier {
  AuthSessionService._();

  static final instance = AuthSessionService._();

  static const _sessionKey = 'bridge_session_active';
  static const _companyIdKey = 'bridge_company_id';
  static const _pinSaltKey = 'bridge_pin_salt';
  static const _pinHashKey = 'bridge_pin_hash';
  static const pinLength = 6;

  SessionStorage? _storage;

  bool _initialized = false;
  bool _signedIn = false;
  bool _hasPin = false;
  bool _unlocked = false;
  Company? _company;

  bool get isInitialized => _initialized;
  bool get isSignedIn => _signedIn;
  bool get hasPin => _hasPin;
  bool get isUnlocked => _unlocked;
  Company? get company => _company;
  bool get needsPinSetup => _signedIn && !_hasPin;
  bool get needsPinUnlock => _signedIn && _hasPin && !_unlocked;

  Future<SessionStorage> get _store async {
    _storage ??= await SessionStorageProvider.resolve();
    return _storage!;
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      final storage = await _store;
      final session = await storage.read(_sessionKey);
      final hash = await storage.read(_pinHashKey);
      final companyId = int.tryParse(await storage.read(_companyIdKey) ?? '');
      _signedIn = session == 'true';
      _hasPin = hash != null && hash.isNotEmpty;
      _company = companyId != null ? Company.fromId(companyId) : null;
    } catch (e, stack) {
      debugPrint('AuthSessionService.init failed: $e\n$stack');
      _signedIn = false;
      _hasPin = false;
      _company = null;
    }
    _unlocked = false;
    _initialized = true;
    notifyListeners();
  }

  /// Called after successful corporate email/password sign-in.
  Future<void> completeCorporateSignIn({required Company company}) async {
    final storage = await _store;
    await storage.write(_sessionKey, 'true');
    await storage.write(_companyIdKey, company.id.toString());
    _signedIn = true;
    _company = company;
    _unlocked = false;
    notifyListeners();
  }

  Future<void> setupPin(String pin) async {
    _assertValidPin(pin);
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    final storage = await _store;
    await storage.write(_pinSaltKey, salt);
    await storage.write(_pinHashKey, hash);
    _hasPin = true;
    _unlocked = true;
    notifyListeners();
  }

  Future<bool> checkPin(String pin) async {
    _assertValidPin(pin);
    final storage = await _store;
    final salt = await storage.read(_pinSaltKey);
    final storedHash = await storage.read(_pinHashKey);
    if (salt == null || storedHash == null) return false;
    return _hashPin(pin, salt) == storedHash;
  }

  Future<bool> verifyPin(String pin) async {
    _assertValidPin(pin);
    final storage = await _store;
    final salt = await storage.read(_pinSaltKey);
    final storedHash = await storage.read(_pinHashKey);
    if (salt == null || storedHash == null) return false;
    final ok = _hashPin(pin, salt) == storedHash;
    if (ok) {
      _unlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    _assertValidPin(currentPin);
    _assertValidPin(newPin);
    final storage = await _store;
    final salt = await storage.read(_pinSaltKey);
    final storedHash = await storage.read(_pinHashKey);
    if (salt == null || storedHash == null) return false;
    if (_hashPin(currentPin, salt) != storedHash) return false;

    final newSalt = _generateSalt();
    final newHash = _hashPin(newPin, newSalt);
    await storage.write(_pinSaltKey, newSalt);
    await storage.write(_pinHashKey, newHash);
    _hasPin = true;
    _unlocked = true;
    notifyListeners();
    return true;
  }

  /// Unlocks the session after device biometrics succeed.
  void unlockSession() {
    if (!_signedIn || !_hasPin) return;
    _unlocked = true;
    notifyListeners();
  }

  void lock() {
    if (!_signedIn || !_hasPin) return;
    _unlocked = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    final storage = await _store;
    await storage.delete(_sessionKey);
    await storage.delete(_companyIdKey);
    await storage.delete(_pinSaltKey);
    await storage.delete(_pinHashKey);
    _signedIn = false;
    _hasPin = false;
    _unlocked = false;
    _company = null;
    UserService.instance.signOut();
    notifyListeners();
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  void _assertValidPin(String pin) {
    if (pin.length != pinLength || !RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN must be $pinLength digits.');
    }
  }
}
