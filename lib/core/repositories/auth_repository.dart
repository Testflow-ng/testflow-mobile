import '../api/api_client.dart';
import '../models/user.dart';

class MeResponse {
  final User user;
  final bool needsUsername;

  const MeResponse({required this.user, required this.needsUsername});
}

class AuthRepository {
  final ApiClient _client;

  const AuthRepository(this._client);

  Future<User> register({
    required String fullName,
    required String username,
    required String email,
    String? matricNumber,
    required String password,
  }) async {
    final data = await _client.post('/api/auth/register', body: {
      'fullName': fullName,
      'username': username,
      'email': email,
      if (matricNumber != null && matricNumber.isNotEmpty)
        'matricNumber': matricNumber,
      'password': password,
      'confirmPassword': password,
    });
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User> login({required String email, required String password}) async {
    final data = await _client.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _client.post('/api/auth/logout');
    } finally {
      await _client.clearCookies();
    }
  }

  Future<MeResponse> me() async {
    final data = await _client.get('/api/auth/me');
    return MeResponse(
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      needsUsername: (data['meta']?['needsUsername'] as bool?) ?? false,
    );
  }

  Future<User> setUsername(String username) async {
    final data =
        await _client.patch('/api/auth/username', body: {'username': username});
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) =>
      _client.post('/api/auth/forgot-password', body: {'email': email});

  Future<void> resendVerification(String email) =>
      _client.post('/api/auth/resend-verification', body: {'email': email});

  Future<User> updateProfile({
    String? fullName,
    bool? showOnLeaderboard,
  }) async {
    final data = await _client.patch('/api/auth/profile', body: {
      if (fullName != null) 'fullName': fullName,
      if (showOnLeaderboard != null) 'showOnLeaderboard': showOnLeaderboard,
    });
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post('/api/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    // Server bumps tokenVersion, so existing cookies are now invalid.
    await _client.clearCookies();
  }
}
