import '../models/claim_model.dart';
import '../services/api_service.dart';

class ClaimRepository {
  final ApiService _api;

  ClaimRepository(this._api);

  Future<ClaimModel> createClaim({
    required String listingId,
    required DateTime proposedPickupTime,
    String? message,
  }) async {
    final response = await _api.post(
      '/claims',
      body: {
        'listingId': listingId,
        'proposedPickupTime':
        proposedPickupTime.toIso8601String(),
        if (message != null &&
            message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<ClaimModel> getClaim(
      String claimId,
      ) async {
    final response = await _api.get(
      '/claims/$claimId',
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<List<ClaimModel>> getMyClaims({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get(
      '/claims?page=$page&size=$size',
    );

    if (response is! Map<String, dynamic>) {
      return [];
    }

    final content = response['content'];

    if (content is! List) {
      return [];
    }

    return content
        .whereType<Map<String, dynamic>>()
        .map(ClaimModel.fromJson)
        .toList();
  }

  Future<ClaimModel> cancelClaim(
      String claimId,
      ) async {
    final response = await _api.post(
      '/claims/$claimId/cancel',
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<ClaimModel> completeClaim(
      String claimId,
      ) async {
    final response = await _api.put(
      '/claims/$claimId/complete',
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }

  Map<String, dynamic> _unwrapMap(
      dynamic response,
      ) {
    if (response is! Map<String, dynamic>) {
      return {};
    }

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  Future<ClaimModel> approveClaim({
    required String claimId,
    String? donorResponse,
  }) async {
    final response = await _api.put(
      '/claims/$claimId/approve',
      body: {
        if (donorResponse != null &&
            donorResponse.trim().isNotEmpty)
          'donorResponse': donorResponse.trim(),
      },
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<ClaimModel> rejectClaim({
    required String claimId,
    String? donorResponse,
  }) async {
    final response = await _api.put(
      '/claims/$claimId/reject',
      body: {
        if (donorResponse != null &&
            donorResponse.trim().isNotEmpty)
          'donorResponse': donorResponse.trim(),
      },
    );

    return ClaimModel.fromJson(
      _unwrapMap(response),
    );
  }
}