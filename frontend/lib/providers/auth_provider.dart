import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../services/api_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus {
  checking,
  unauthenticated,
  needsProfile,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool hasOrganizationProfile;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.hasOrganizationProfile = false,
    this.error,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.needsProfile;

  bool get needsOrganizationSetup =>
      status == AuthStatus.needsProfile;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? hasOrganizationProfile,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      hasOrganizationProfile:
          hasOrganizationProfile ??
              this.hasOrganizationProfile,
      error: error,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  late ApiService _api;
  late AuthRepository _authRepository;
  late ProfileRepository _profileRepository;

  @override
  Future<AuthState> build() async {
    _api = ApiService();
    _authRepository =
        AuthRepository(_api);
    _profileRepository =
        ProfileRepository(_api);

    return _restoreSession();
  }

  Future<AuthState> _restoreSession() async {
    final token = await _api.accessToken;

    if (token == null) {
      return const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }

    try {
      final userJson =
          await _authRepository.me();

      final user =
          UserModel.fromJson(userJson);

      final hasProfile =
          await _checkProfile(user.role);

      return AuthState(
        status: hasProfile
            ? AuthStatus.authenticated
            : AuthStatus.needsProfile,
        user: user,
        hasOrganizationProfile:
            hasProfile,
      );
    } catch (_) {
      await _api.clearTokens();

      return const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<bool> login(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();

    try {
      final response =
          await _authRepository.login(
        email: email,
        password: password,
      );

      final data = _unwrap(response);

      final accessToken =
          _token(data, [
        'accessToken',
        'access_token',
        'token',
      ]);

      final refreshToken =
          _token(data, [
        'refreshToken',
        'refresh_token',
      ]);

      if (accessToken == null ||
          refreshToken == null) {
        state = AsyncData(
          const AuthState(
            status:
                AuthStatus.unauthenticated,
            error:
                'Login response did not contain authentication tokens.',
          ),
        );
        return false;
      }

      await _api.saveTokens(
        accessToken,
        refreshToken,
      );

      final userJson =
          await _authRepository.me();

      final user =
          UserModel.fromJson(userJson);

      final hasProfile =
          await _checkProfile(user.role);

      state = AsyncData(
        AuthState(
          status: hasProfile
              ? AuthStatus.authenticated
              : AuthStatus.needsProfile,
          user: user,
          hasOrganizationProfile:
              hasProfile,
        ),
      );

      return true;
    } catch (e) {
      state = AsyncData(
        AuthState(
          status:
              AuthStatus.unauthenticated,
          error: e.toString(),
        ),
      );

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
    state = const AsyncLoading();

    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      // Registration endpoint creates the user.
      // Login is then used to obtain JWT tokens.
      return await login(
        email,
        password,
      );
    } catch (e) {
      state = AsyncData(
        AuthState(
          status:
              AuthStatus.unauthenticated,
          error: e.toString(),
        ),
      );

      return false;
    }
  }

  Future<bool> completeOrganizationProfile({
    required Map<String, dynamic> payload,
  }) async {
    final current = state.value;

    if (current == null ||
        current.user == null) {
      return false;
    }

    try {
      if (current.user!.role == 'DONOR') {
        await _profileRepository.createDonorProfile(
          orgName:
              payload['orgName'].toString(),
          orgType:
              payload['orgType'].toString(),
          address:
              payload['address'].toString(),
          contactPerson:
              payload['contactPerson'].toString(),
          latitude:
              payload['latitude'] as double?,
          longitude:
              payload['longitude'] as double?,
        );
      } else {
        await _profileRepository.createNgoProfile(
          orgName:
              payload['orgName'].toString(),
          registrationNumber:
              payload['registrationNumber']
                  .toString(),
          address:
              payload['address'].toString(),
          contactPerson:
              payload['contactPerson'].toString(),
          serviceArea:
              payload['serviceArea'].toString(),
          latitude:
              payload['latitude'] as double?,
          longitude:
              payload['longitude'] as double?,
        );
      }

      final refreshed =
          await _restoreSession();

      state = AsyncData(refreshed);

      return refreshed.hasOrganizationProfile;
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          error: e.toString(),
        ),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();

    state = const AsyncData(
      AuthState(
        status:
            AuthStatus.unauthenticated,
      ),
    );
  }

  Future<bool> _checkProfile(
    String? role,
  ) async {
    switch (role?.toUpperCase()) {
      case 'DONOR':
        return await _profileRepository
                .getMyDonorProfile() !=
            null;

      case 'NGO':
        return await _profileRepository
                .getMyNgoProfile() !=
            null;

      default:
        return false;
    }
  }

  Map<String, dynamic> _unwrap(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  String? _token(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is String &&
          value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}

final isAuthenticatedProvider =
    Provider<bool>((ref) {
  final auth =
      ref.watch(authProvider);

  return auth.value?.isAuthenticated ??
      false;
});

final hasOrganizationProfileProvider =
    Provider<bool>((ref) {
  final auth =
      ref.watch(authProvider);

  return auth.value
          ?.hasOrganizationProfile ??
      false;
});

final userRoleProvider =
    Provider<String?>((ref) {
  final auth =
      ref.watch(authProvider);

  return auth.value?.user?.role;
});
