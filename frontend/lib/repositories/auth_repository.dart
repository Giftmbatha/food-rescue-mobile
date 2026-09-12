import '../services/api_service.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await _api.post(
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null &&
            phone.trim().isNotEmpty)
          'phone': phone.trim(),
      },
    );

    return _asMap(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return _asMap(response);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _api.get('/auth/me');
    return _extractUser(response);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _api.clearTokens();
    }
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    return {};
  }

  Map<String, dynamic> _extractUser(
    dynamic response,
  ) {
    final map = _asMap(response);
    final data = map['data'];

    if (data is Map<String, dynamic>) {
      final user =
          data['user'] ?? data['userDto'];

      if (user is Map<String, dynamic>) {
        return user;
      }

      return data;
    }

    return map;
  }
}
