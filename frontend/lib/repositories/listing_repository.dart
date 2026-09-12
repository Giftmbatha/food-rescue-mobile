import 'package:image_picker/image_picker.dart';

import '../models/listing_model.dart';
import '../services/api_service.dart';

class ListingRepository {
  final ApiService _api;

  ListingRepository(this._api);

  Future<List<ListingModel>> getListings({
    Map<String, String>? filters,
  }) async {
    final response = await _api.get(
      '/listings',
      queryParameters: filters,
    );

    return _extractList(response)
        .map(ListingModel.fromJson)
        .toList();
  }

  Future<List<ListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    double distanceMeters = 5000,
  }) async {
    final response = await _api.get(
      '/listings/nearby',
      queryParameters: {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'distance': distanceMeters.toString(),
        'page': '0',
        'size': '20',
      },
    );

    return _extractList(response)
        .map(ListingModel.fromJson)
        .toList();
  }

  Future<ListingModel> getListing(String id) async {
    final response = await _api.get('/listings/$id');

    return ListingModel.fromJson(
      _extractMap(response),
    );
  }

  Future<ListingModel> createListing({
    required String title,
    String? description,
    required String category,
    required double quantityKg,
    required DateTime expiryDate,
    required String pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    required String pickupWindow,
    String? pickupNotes,
    bool allowPartialClaims = false,
    List<String> imageObjectKeys = const [],
    List<String> imageCaptions = const [],
  }) async {
    final response = await _api.post(
      '/listings',
      body: {
        'title': title,
        'description': description,
        'category': category,
        'quantityKg': quantityKg,
        'expiryDate': expiryDate.toIso8601String(),
        'pickupAddress': pickupAddress,
        'pickupLatitude': pickupLatitude,
        'pickupLongitude': pickupLongitude,
        'pickupWindow': pickupWindow,
        'pickupNotes': pickupNotes,
        'allowPartialClaims': allowPartialClaims,
        'imageObjectKeys': imageObjectKeys,
        'imageCaptions': imageCaptions,
      },
    );

    return ListingModel.fromJson(
      _extractMap(response),
    );
  }

  Future<void> updateListing(
      String id, {
        required Map<String, dynamic> body,
      }) async {
    await _api.put(
      '/listings/$id',
      body: body,
    );
  }

  Future<void> deleteListing(String id) async {
    await _api.delete('/listings/$id');
  }

  Future<String?> uploadImage(
      XFile image, {
        String folder = 'listings',
      }) async {
    final response = await _api.uploadFile(
      '/images/upload',
      image.path,
      mimeType: image.mimeType,
      extraFields: {
        'folder': folder,
      },
    );

    final map = _extractMap(response);

    return map['objectKey']?.toString() ??
        map['url']?.toString();
  }

  List<Map<String, dynamic>> _extractList(
      dynamic response,
      ) {
    dynamic data = response;

    if (data is Map<String, dynamic> &&
        data['data'] != null) {
      data = data['data'];
    }

    if (data is Map<String, dynamic> &&
        data['content'] is List) {
      data = data['content'];
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