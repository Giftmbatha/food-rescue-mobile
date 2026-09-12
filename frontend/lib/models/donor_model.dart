class DonorModel {
  final String? id;
  final String? userId;
  final String orgName;
  final String orgType;
  final String address;
  final String contactPerson;
  final double? latitude;
  final double? longitude;
  final double? ratingAvg;

  const DonorModel({
    this.id,
    this.userId,
    required this.orgName,
    required this.orgType,
    required this.address,
    required this.contactPerson,
    this.latitude,
    this.longitude,
    this.ratingAvg,
  });

  factory DonorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DonorModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      orgName: json['orgName']?.toString() ?? '',
      orgType: json['orgType']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactPerson:
          json['contactPerson']?.toString() ?? '',
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      ratingAvg: _double(json['ratingAvg']),
    );
  }

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
