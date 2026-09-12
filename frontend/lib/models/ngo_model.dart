class NgoModel {
  final String? id;
  final String? userId;
  final String orgName;
  final String registrationNumber;
  final String address;
  final String contactPerson;
  final String serviceArea;
  final double? latitude;
  final double? longitude;
  final double? ratingAvg;

  const NgoModel({
    this.id,
    this.userId,
    required this.orgName,
    required this.registrationNumber,
    required this.address,
    required this.contactPerson,
    required this.serviceArea,
    this.latitude,
    this.longitude,
    this.ratingAvg,
  });

  factory NgoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NgoModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      orgName: json['orgName']?.toString() ?? '',
      registrationNumber:
          json['regNumber']?.toString() ??
              json['registrationNumber']?.toString() ??
              '',
      address: json['address']?.toString() ?? '',
      contactPerson:
          json['contactPerson']?.toString() ?? '',
      serviceArea:
          json['serviceArea']?.toString() ?? '',
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
