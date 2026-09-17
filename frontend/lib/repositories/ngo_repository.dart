import '../models/ngo_model.dart';
import '../models/ngo_stats_model.dart';
import '../services/api_service.dart';

class NgoRepository {
  final ApiService _api;

  NgoRepository(this._api);

  Future<NgoModel?> getMyProfile() async {
    try {
      final response = await _api.get(
        '/ngos/me',
      );

      return NgoModel.fromJson(
        _unwrapMap(response),
      );
    } catch (_) {
      return null;
    }
  }

  Future<NgoModel> updateProfile({
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
    final response = await _api.put(
      '/ngos/$id',
      body: {
        'orgName': orgName,
        'regNumber': regNumber,
        'address': address,
        'phone': phone,
        'contactPerson': contactPerson,
        'serviceArea': serviceArea,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return NgoModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<NgoStatsModel> getMyStats() async {
    final response = await _api.get(
      '/ngos/me/stats',
    );

    return NgoStatsModel.fromJson(
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
}