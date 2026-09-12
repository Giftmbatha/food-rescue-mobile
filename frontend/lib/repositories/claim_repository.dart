import '../models/claim_model.dart';
import '../services/api_service.dart';

class ClaimRepository {
  final ApiService _api;

  ClaimRepository(this._api);

  Future<List<ClaimModel>> getClaims() async {
    final response = await _api.get('/claims');

    return _extractList(response)
        .map(ClaimModel.fromJson)
        .toList();
  }

  Future<ClaimModel> getClaim(
    String id,
  ) async {
    final response =
        await _api.get('/claims/$id');

    return ClaimModel.fromJson(
      _extractMap(response),
    );
  }

  Future<ClaimModel> claimListing(
    String listingId,
  ) async {
    final response = await _api.post(
      '/listings/$listingId/claim',
    );

    return ClaimModel.fromJson(
      _extractMap(response),
    );
  }

  Future<void> updateStatus(
    String claimId,
    String status,
  ) async {
    await _api.put(
      '/claims/$claimId/status',
      body: {
        'status': status,
      },
    );
  }

  Future<void> cancelClaim(
    String claimId,
  ) async {
    await _api.post(
      '/claims/$claimId/cancel',
    );
  }

  List<Map<String, dynamic>> _extractList(
    dynamic response,
  ) {
    dynamic data = response;

    if (data is Map<String, dynamic>) {
      data = data['data'] ?? data;
    }

    if (data is Map<String, dynamic>) {
      data = data['content'] ?? data;
    }

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return [];
  }

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      return response;
    }

    return {};
  }
}
