import '../models/donor_model.dart';
import '../models/donor_stats_model.dart';
import '../models/ngo_model.dart';
import '../services/api_service.dart';

class ProfileRepository {
  final ApiService _api;

  ProfileRepository(this._api);

  Future<DonorModel?> getMyDonorProfile() async {
    try {
      final response =
      await _api.get('/donors/me');

      return DonorModel.fromJson(
        _unwrapMap(response),
      );
    } catch (_) {
      return null;
    }
  }

  Future<DonorStatsModel> getMyDonorStats() async {
    final response =
    await _api.get('/donors/me/stats');

    return DonorStatsModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<DonorModel> updateDonorProfile({
    required String id,
    required String orgName,
    required String orgType,
    required String address,
    required String contactPerson,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _api.put(
      '/donors/$id',
      body: {
        'orgName': orgName,
        'orgType': orgType,
        'address': address,
        'contactPerson': contactPerson,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return DonorModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<NgoModel?> getMyNgoProfile() async {
    try {
      final response =
      await _api.get('/ngos/me');

      return NgoModel.fromJson(
        _unwrapMap(response),
      );
    } catch (_) {
      return null;
    }
  }

  Future<DonorModel> createDonorProfile({
    required String orgName,
    required String orgType,
    required String address,
    required String contactPerson,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _api.post(
      '/donors',
      body: {
        'orgName': orgName,
        'orgType': orgType,
        'address': address,
        'contactPerson': contactPerson,
        'phone': phone,
        if (latitude != null)
          'latitude': latitude,
        if (longitude != null)
          'longitude': longitude,
      },
    );

    return DonorModel.fromJson(
      _unwrapMap(response),
    );
  }

  Future<NgoModel> createNgoProfile({
    required String orgName,
    required String registrationNumber,
    required String address,
    required String contactPerson,
    required String serviceArea,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _api.post(
      '/ngos',
      body: {
        'orgName': orgName,
        'regNumber': registrationNumber,
        'address': address,
        'contactPerson': contactPerson,
        'serviceArea': serviceArea,
        if (latitude != null)
          'latitude': latitude,
        if (longitude != null)
          'longitude': longitude,
      },
    );

    return NgoModel.fromJson(
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