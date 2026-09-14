import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/donor_model.dart';
import '../models/donor_stats_model.dart';
import '../repositories/profile_repository.dart';
import '../services/api_service.dart';

final profileRepositoryProvider =
Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ApiService(),
  );
});

final donorProfileProvider =
FutureProvider<DonorModel?>((ref) async {
  return ref
      .read(profileRepositoryProvider)
      .getMyDonorProfile();
});

final donorStatsProvider =
FutureProvider<DonorStatsModel>((ref) async {
  return ref
      .read(profileRepositoryProvider)
      .getMyDonorStats();
});