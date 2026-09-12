class ClaimModel {
  final String? id;
  final String? listingId;
  final String? ngoId;
  final String status;
  final DateTime? pickupTime;

  const ClaimModel({
    this.id,
    this.listingId,
    this.ngoId,
    required this.status,
    this.pickupTime,
  });

  factory ClaimModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClaimModel(
      id: json['id']?.toString(),
      listingId: json['listingId']?.toString(),
      ngoId: json['ngoId']?.toString(),
      status:
          json['status']?.toString() ?? 'PENDING',
      pickupTime:
          DateTime.tryParse(
            json['pickupTime']?.toString() ?? '',
          ),
    );
  }
}
