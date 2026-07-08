import 'package:flutter/foundation.dart';

import '../models/user.dart';

class UserService extends ChangeNotifier {
  UserService._();

  static final instance = UserService._();

  User? _current;

  /// The user fetched earlier this session, if any.
  User? get currentUser => _current;

  /// Fetches the signed-in user's profile (cached for the session).
  ///
  /// Pass [forceRefresh] to bypass the cache (e.g. pull-to-refresh). Locally
  /// edited fields are re-seeded from the source, matching a server re-fetch.
  // TODO: replace the mock delay and data with a real API call.
  Future<User> fetchCurrentUser({bool forceRefresh = false}) async {
    if (_current != null && !forceRefresh) return _current!;
    await Future.delayed(const Duration(milliseconds: 1500));
    _current = const User(
      name: 'Chirachart Hongsamart',
      nickname: 'Arthur',
      role: 'Operations',
      email: 'chirachart.h@company.com',
      employeeId: '68010011',
      section: 'Sales',
      department: 'Retail Operations',
      phone: '+66 81 234 5678',
      emergencyContact: 'Natcha Wongsa · +66 82 345 6789',
      isLineManager: true,
    );
    return _current!;
  }

  /// Updates editable profile fields for the current user.
  // TODO: replace with PATCH /profile API call.
  Future<User> updateProfile({
    String? nickname,
    String? phone,
    String? emergencyContact,
  }) async {
    final user = _current ?? await fetchCurrentUser();
    await Future.delayed(const Duration(milliseconds: 400));
    _current = user.copyWith(
      nickname: nickname,
      phone: phone,
      emergencyContact: emergencyContact,
    );
    notifyListeners();
    return _current!;
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }
}
