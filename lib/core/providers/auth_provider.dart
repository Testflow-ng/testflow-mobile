import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_exception.dart';
import '../models/user.dart';
import 'api_providers.dart';
import 'app_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, guest }

class AuthState {
  final AuthStatus status;
  final User? user;
  final bool needsUsername;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.needsUsername = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
  bool get isVerified => user?.isEmailVerified ?? false;

  AuthState copyWith({AuthStatus? status, User? user, bool? needsUsername}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      needsUsername: needsUsername ?? this.needsUsername,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const _keyIsGuest = 'is_guest';
  static const _keyCachedUser = 'cached_user';

  @override
  AuthState build() => const AuthState();

  void _cacheUser(Map<String, dynamic> json) {
    ref.read(sharedPreferencesProvider).setString(_keyCachedUser, jsonEncode(json));
  }

  User? _readCachedUser() {
    final raw = ref.read(sharedPreferencesProvider).getString(_keyCachedUser);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Resolves the session instantly from local state; the network is only
  /// awaited when cookies exist but no profile has been cached yet.
  Future<void> bootstrap() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_keyIsGuest) ?? false) {
      state = const AuthState(status: AuthStatus.guest);
      return;
    }

    final hasSession = await ref.read(apiClientProvider).hasSession();
    if (!hasSession) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    final cached = _readCachedUser();
    if (cached != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: cached,
        needsUsername: cached.username == null || cached.username!.isEmpty,
      );
      // Revalidate against the server without blocking startup.
      Future(refreshMe).ignore();
      return;
    }

    try {
      final me = await ref.read(authRepositoryProvider).me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: me.user,
        needsUsername: me.needsUsername,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void _setAuthenticated(User user, {bool? needsUsername}) {
    _cacheUser(user.toJson());
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      needsUsername:
          needsUsername ?? (user.username == null || user.username!.isEmpty),
    );
  }

  Future<void> login({required String email, required String password}) async {
    final user = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await ref.read(sharedPreferencesProvider).setBool(_keyIsGuest, false);
    _setAuthenticated(user);
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    String? matricNumber,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.register(
      fullName: fullName,
      username: username,
      email: email,
      matricNumber: matricNumber,
      password: password,
    );
    // Registration does not set auth cookies; sign in right after.
    await login(email: email, password: password);
  }

  Future<void> refreshMe() async {
    if (!state.isAuthenticated) return;
    try {
      final me = await ref.read(authRepositoryProvider).me();
      _setAuthenticated(me.user, needsUsername: me.needsUsername);
    } on ApiException catch (e) {
      if (e.isUnauthenticated) {
        ref.read(sharedPreferencesProvider).remove(_keyCachedUser);
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      // Network hiccup: keep the cached session.
    }
  }

  Future<void> setUsername(String username) async {
    final user = await ref.read(authRepositoryProvider).setUsername(username);
    _setAuthenticated(user, needsUsername: false);
  }

  Future<void> updateProfile({
    String? fullName,
    bool? showOnLeaderboard,
  }) async {
    final user = await ref.read(authRepositoryProvider).updateProfile(
          fullName: fullName,
          showOnLeaderboard: showOnLeaderboard,
        );
    _setAuthenticated(user, needsUsername: state.needsUsername);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ref.read(authRepositoryProvider).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
    await ref.read(sharedPreferencesProvider).remove(_keyCachedUser);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void continueAsGuest() {
    ref.read(sharedPreferencesProvider).setBool(_keyIsGuest, true);
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<void> signOut() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyIsGuest, false);
    await prefs.remove(_keyCachedUser);
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Even if the server call fails, cookies are cleared locally.
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
