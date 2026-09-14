class DonorStatsModel {
  final String? donorId;
  final String orgName;
  final int totalListings;
  final int activeListings;
  final int completedClaims;
  final double totalKgDonated;
  final double averageRating;
  final int ratingCount;

  const DonorStatsModel({
    this.donorId,
    required this.orgName,
    required this.totalListings,
    required this.activeListings,
    required this.completedClaims,
    required this.totalKgDonated,
    required this.averageRating,
    required this.ratingCount,
  });

  factory DonorStatsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DonorStatsModel(
      donorId: json['donorId']?.toString(),
      orgName: json['orgName']?.toString() ?? '',
      totalListings:
      _int(json['totalListings']),
      activeListings:
      _int(json['activeListings']),
      completedClaims:
      _int(json['completedClaims']),
      totalKgDonated:
      _double(json['totalKgDonated']),
      averageRating:
      _double(json['averageRating']),
      ratingCount:
      _int(json['ratingCount']),
    );
  }

  static int _int(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static double _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }
}