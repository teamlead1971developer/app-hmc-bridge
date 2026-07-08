import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists auth session keys. Uses secure storage when the native plugin is
/// available; falls back to in-memory storage during hot restart / unsupported
/// platforms so the app does not crash.
abstract class SessionStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecureSessionStorage implements SessionStorage {
  _SecureSessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class _MemorySessionStorage implements SessionStorage {
  static final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}

class SessionStorageProvider {
  SessionStorageProvider._();

  static SessionStorage? _instance;

  static Future<SessionStorage> resolve() async {
    if (_instance != null) return _instance!;

    try {
      const secure = FlutterSecureStorage();
      // Probe the platform channel — returns null for missing keys.
      await secure.read(key: '_bridge_storage_probe');
      _instance = _SecureSessionStorage(secure);
      return _instance!;
    } on MissingPluginException catch (e) {
      _logFallback(e);
    } catch (e) {
      _logFallback(e);
    }

    _instance = _MemorySessionStorage();
    return _instance!;
  }

  static void _logFallback(Object error) {
    assert(() {
      debugPrint(
        'SessionStorage: secure storage unavailable ($error). '
        'Using in-memory fallback — stop the app and run `flutter run` '
        'again (not hot restart) for persistent PIN/session storage.',
      );
      return true;
    }());
  }
}
