class NgoStatsModel {
  final String? ngoId;
  final String orgName;
  final int totalClaims;
  final int pendingClaims;
  final int approvedClaims;
  final int completedPickups;
  final double totalKgReceived;
  final double averageRating;
  final int ratingCount;

  const NgoStatsModel({
    this.ngoId,
    required this.orgName,
    required this.totalClaims,
    required this.pendingClaims,
    required this.approvedClaims,
    required this.completedPickups,
    required this.totalKgReceived,
    required this.averageRating,
    required this.ratingCount,
  });

  factory NgoStatsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NgoStatsModel(
      ngoId: json['ngoId']?.toString(),
      orgName: json['orgName']?.toString() ?? '',
      totalClaims: _int(json['totalClaims']),
      pendingClaims:
      _int(json['pendingClaims']),
      approvedClaims:
      _int(json['approvedClaims']),
      completedPickups:
      _int(json['completedPickups']),
      totalKgReceived:
      _double(json['totalKgReceived']),
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