import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ngo_model.dart';
import '../models/ngo_stats_model.dart';
import '../repositories/ngo_repository.dart';
import '../services/api_service.dart';

final ngoRepositoryProvider = Provider<NgoRepository>((ref) {
  return NgoRepository(
    ApiService(),
  );
});

class NgoState {
  final NgoModel? profile;
  final NgoStatsModel? stats;
  final bool isLoading;
  final String? error;

  const NgoState({
    this.profile,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  NgoState copyWith({
    NgoModel? profile,
    NgoStatsModel? stats,
    bool? isLoading,
    String? error,
  }) {
    return NgoState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NgoNotifier extends Notifier<NgoState> {
  late final NgoRepository _repository;

  @override
  NgoState build() {
    _repository = ref.read(
      ngoRepositoryProvider,
    );

    return const NgoState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final profile =
      await _repository.getMyProfile();

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final stats =
      await _repository.getMyStats();

      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadProfileAndStats() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final results = await Future.wait([
        _repository.getMyProfile(),
        _repository.getMyStats(),
      ]);

      state = NgoState(
        profile: results[0] as NgoModel?,
        stats: results[1] as NgoStatsModel?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    required String id,
    required String orgName,
    required String regNumber,
    required String address,
    String? phone,
    String? contactPerson,
    String? serviceArea,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final updated =
      await _repository.updateProfile(
        id: id,
        orgName: orgName,
        regNumber: regNumber,
        address: address,
        phone: phone,
        contactPerson: contactPerson,
        serviceArea: serviceArea,
        latitude: latitude,
        longitude: longitude,
      );

      state = state.copyWith(
        profile: updated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      rethrow;
    }
  }
}

final ngoProvider =
NotifierProvider<NgoNotifier, NgoState>(
  NgoNotifier.new,
);