import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/claim_model.dart';
import '../repositories/claim_repository.dart';
import '../services/api_service.dart';

final claimRepositoryProvider =
Provider<ClaimRepository>((ref) {
  return ClaimRepository(
    ApiService(),
  );
});

class ClaimState {
  final List<ClaimModel> claims;
  final ClaimModel? selectedClaim;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ClaimState({
    this.claims = const [],
    this.selectedClaim,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ClaimState copyWith({
    List<ClaimModel>? claims,
    ClaimModel? selectedClaim,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ClaimState(
      claims: claims ?? this.claims,
      selectedClaim:
      selectedClaim ?? this.selectedClaim,
      isLoading:
      isLoading ?? this.isLoading,
      isSubmitting:
      isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ClaimNotifier extends Notifier<ClaimState> {
  late final ClaimRepository _repository;

  @override
  ClaimState build() {
    _repository = ref.read(
      claimRepositoryProvider,
    );

    return const ClaimState();
  }

  Future<void> loadMyClaims() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final claims =
      await _repository.getMyClaims();

      state = state.copyWith(
        claims: claims,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadClaim(
      String claimId,
      ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final claim =
      await _repository.getClaim(
        claimId,
      );

      state = state.copyWith(
        selectedClaim: claim,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<ClaimModel?> createClaim({
    required String listingId,
    required DateTime proposedPickupTime,
    String? message,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      error: null,
    );

    try {
      final claim =
      await _repository.createClaim(
        listingId: listingId,
        proposedPickupTime:
        proposedPickupTime,
        message: message,
      );

      state = state.copyWith(
        claims: [
          claim,
          ...state.claims,
        ],
        selectedClaim: claim,
        isSubmitting: false,
      );

      return claim;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );

      return null;
    }
  }

  Future<bool> cancelClaim(
      String claimId,
      ) async {
    state = state.copyWith(
      isSubmitting: true,
      error: null,
    );

    try {
      final cancelled =
      await _repository.cancelClaim(
        claimId,
      );

      _replaceClaim(cancelled);

      state = state.copyWith(
        selectedClaim: cancelled,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );

      return false;
    }
  }

  Future<bool> completeClaim(
      String claimId,
      ) async {
    state = state.copyWith(
      isSubmitting: true,
      error: null,
    );

    try {
      final completed =
      await _repository.completeClaim(
        claimId,
      );

      _replaceClaim(completed);

      state = state.copyWith(
        selectedClaim: completed,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );

      return false;
    }
  }

  void _replaceClaim(
      ClaimModel updated,
      ) {
    final claims = state.claims.map((claim) {
      if (claim.id == updated.id) {
        return updated;
      }

      return claim;
    }).toList();

    state = state.copyWith(
      claims: claims,
    );
  }
}

final claimProvider =
NotifierProvider<ClaimNotifier, ClaimState>(
  ClaimNotifier.new,
);