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

final claimsProvider =
    FutureProvider<List<ClaimModel>>((ref) {
  return ref
      .read(claimRepositoryProvider)
      .getClaims();
});
