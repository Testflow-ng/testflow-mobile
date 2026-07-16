import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_providers.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
enum AuthStatus { authenticated, unauthenticated, guest }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId,
    this.displayName,
    this.email,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? displayName,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
}

class AuthNotifier extends Notifier<AuthState> {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyDisplayName = 'display_name';
  static const _keyEmail = 'user_email';
  static const _keyIsGuest = 'is_guest';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AuthState build() {
    final prefs = _prefs;
    final isGuest = prefs.getBool(_keyIsGuest) ?? false;
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (isGuest) {
      return const AuthState(status: AuthStatus.guest, displayName: 'Guest User');
    }
    if (isLoggedIn) {
      return AuthState(
        status: AuthStatus.authenticated,
        displayName: prefs.getString(_keyDisplayName) ?? 'TestFlow User',
        email: prefs.getString(_keyEmail) ?? '',
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login({required String email, required String password}) async {
    // Simulated auth — replace with real API call
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = _prefs;
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyIsGuest, false);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyDisplayName, _nameFromEmail(email));
    state = AuthState(
      status: AuthStatus.authenticated,
      email: email,
      displayName: _nameFromEmail(email),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = _prefs;
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyIsGuest, false);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyDisplayName, name);
    state = AuthState(
      status: AuthStatus.authenticated,
      email: email,
      displayName: name,
    );
  }

  Future<void> signInWithGoogle() async {
    // Simulated auth until Google Sign-In is wired to the backend
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = _prefs;
    const email = 'student@gmail.com';
    const name = 'TestFlow Student';
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyIsGuest, false);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyDisplayName, name);
    state = const AuthState(
      status: AuthStatus.authenticated,
      email: email,
      displayName: name,
    );
  }

  void continueAsGuest() {
    _prefs.setBool(_keyIsGuest, true);
    _prefs.remove(_keyIsLoggedIn);
    state = const AuthState(
      status: AuthStatus.guest,
      displayName: 'Guest User',
    );
  }

  Future<void> signOut() async {
    final prefs = _prefs;
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyEmail);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'TestFlow User';
    return local[0].toUpperCase() + local.substring(1);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
