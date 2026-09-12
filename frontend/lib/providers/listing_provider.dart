import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing_model.dart';
import '../repositories/listing_repository.dart';
import '../services/api_service.dart';

final listingRepositoryProvider =
Provider<ListingRepository>((ref) {
  return ListingRepository(
    ApiService(),
  );
});

final listingsProvider =
FutureProvider<List<ListingModel>>((ref) {
  return ref
      .read(listingRepositoryProvider)
      .getListings();
});

final nearbyListingsProvider =
FutureProvider.family<
    List<ListingModel>,
    ({double latitude, double longitude})>(
      (ref, location) {
    return ref
        .read(listingRepositoryProvider)
        .getNearbyListings(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  },
);

final createListingProvider =
FutureProvider.autoDispose.family<
    ListingModel,
    CreateListingParams>(
      (ref, params) async {
    return ref
        .read(listingRepositoryProvider)
        .createListing(
      title: params.title,
      description: params.description,
      category: params.category,
      quantityKg: params.quantityKg,
      expiryDate: params.expiryDate,
      pickupAddress: params.pickupAddress,
      pickupLatitude: params.pickupLatitude,
      pickupLongitude: params.pickupLongitude,
      pickupWindow: params.pickupWindow,
      pickupNotes: params.pickupNotes,
      allowPartialClaims:
      params.allowPartialClaims,
      imageObjectKeys:
      params.imageObjectKeys,
      imageCaptions:
      params.imageCaptions,
    );
  },
);

class CreateListingParams {
  final String title;
  final String? description;
  final String category;
  final double quantityKg;
  final DateTime expiryDate;
  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String pickupWindow;
  final String? pickupNotes;
  final bool allowPartialClaims;
  final List<String> imageObjectKeys;
  final List<String> imageCaptions;

  const CreateListingParams({
    required this.title,
    this.description,
    required this.category,
    required this.quantityKg,
    required this.expiryDate,
    required this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.pickupWindow,
    this.pickupNotes,
    this.allowPartialClaims = false,
    this.imageObjectKeys = const [],
    this.imageCaptions = const [],
  });
}