class ClaimModel {
  final String? id;
  final String? listingId;
  final String? listingTitle;
  final String? ngoId;
  final String? ngoOrgName;
  final String status;
  final DateTime? proposedPickupTime;
  final String? message;
  final String? donorResponse;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const ClaimModel({
    this.id,
    this.listingId,
    this.listingTitle,
    this.ngoId,
    this.ngoOrgName,
    required this.status,
    this.proposedPickupTime,
    this.message,
    this.donorResponse,
    this.completedAt,
    this.createdAt,
  });

  factory ClaimModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ClaimModel(
      id: json['id']?.toString(),
      listingId:
      json['listingId']?.toString(),
      listingTitle:
      json['listingTitle']?.toString(),
      ngoId: json['ngoId']?.toString(),
      ngoOrgName:
      json['ngoOrgName']?.toString(),
      status:
      json['status']?.toString() ?? 'PENDING',
      proposedPickupTime:
      _dateTime(json['proposedPickupTime']),
      message: json['message']?.toString(),
      donorResponse:
      json['donorResponse']?.toString(),
      completedAt:
      _dateTime(json['completedAt']),
      createdAt:
      _dateTime(json['createdAt']),
    );
  }

  static DateTime? _dateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}