import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final ApiService _api;

  @override
  Future<AuthState> build() async {
    _api = ApiService();

    final token = await _api.accessToken;
    if (token == null) {
      return const AuthState();
    }

    try {
      final user = await _api.get('/auth/me');
      return AuthState(isAuthenticated: true, user: user);
    } catch (_) {
      await _api.clearTokens();
      return const AuthState();
    }
  }

  // Helper methods defined BEFORE they're used
  String? _extractToken(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractUser(Map<String, dynamic> data) {
    final user = data['user'] ?? data['userDto'] ?? data['data'];
    if (user is Map<String, dynamic>) {
      return user;
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await _api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      print('=== RAW LOGIN RESPONSE ===');
      print(response);

      // UNWRAP: Backend wraps response in 'data' field
      final Map<String, dynamic> wrapper = response is Map<String, dynamic>
          ? response
          : {};

      final Map<String, dynamic> data = wrapper['data'] is Map<String, dynamic>
          ? wrapper['data']
          : {};

      final accessToken = _extractToken(data, ['accessToken', 'access_token', 'token']);
      final refreshToken = _extractToken(data, ['refreshToken', 'refresh_token']);
      final user = _extractUser(data);

      print('accessToken: ${accessToken != null ? 'FOUND' : 'NULL'}');
      print('refreshToken: ${refreshToken != null ? 'FOUND' : 'NULL'}');

      if (accessToken == null) {
        state = AsyncValue.data(AuthState(
          error: 'Server error: accessToken missing',
        ));
        return false;
      }

      if (refreshToken == null) {
        state = AsyncValue.data(AuthState(
          error: 'Server error: refreshToken missing',
        ));
        return false;
      }

      await _api.saveTokens(accessToken, refreshToken);

      state = AsyncValue.data(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      return true;

    } on ApiException catch (e) {
      state = AsyncValue.data(AuthState(error: e.message));
      return false;
    }
  }
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _api.post('/auth/register', body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null) 'phone': phone,
      });

      print('=== RAW REGISTER RESPONSE ===');
      print(response);

      // UNWRAP: Backend wraps response in 'data' field
      final Map<String, dynamic> wrapper = response is Map<String, dynamic>
          ? response
          : {};

      final Map<String, dynamic> data = wrapper['data'] is Map<String, dynamic>
          ? wrapper['data']
          : {};

      final accessToken = _extractToken(data, ['accessToken', 'access_token', 'token']);
      final refreshToken = _extractToken(data, ['refreshToken', 'refresh_token']);
      final user = _extractUser(data);

      print('accessToken: ${accessToken != null ? 'FOUND' : 'NULL'}');
      print('refreshToken: ${refreshToken != null ? 'FOUND' : 'NULL'}');

      if (accessToken == null || refreshToken == null) {
        state = AsyncValue.data(AuthState(
          error: 'Server error: tokens missing. Keys: ${data.keys.toList()}',
        ));
        return false;
      }

      await _api.saveTokens(accessToken, refreshToken);

      state = AsyncValue.data(AuthState(
        isAuthenticated: true,
        user: user,
      ));
      return true;

    } on ApiException catch (e) {
      state = AsyncValue.data(AuthState(error: e.message));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}

    await _api.clearTokens();
    state = const AsyncValue.data(AuthState());
  }

  void clearError() {
    final current = state.value ?? const AuthState();
    state = AsyncValue.data(current.copyWith(error: null));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.value?.isAuthenticated ?? false;
});

final userRoleProvider = Provider<String?>((ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.value?.user?['role'] as String?;
});