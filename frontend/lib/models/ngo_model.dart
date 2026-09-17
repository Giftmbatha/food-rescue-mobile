class NgoModel {
  final String? id;
  final String? userId;
  final String orgName;
  final String regNumber;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? contactPerson;
  final String? serviceArea;
  final double? ratingAvg;
  final int? totalClaims;
  final int? totalPickupsCompleted;
  final double? totalKgReceived;

  const NgoModel({
    this.id,
    this.userId,
    required this.orgName,
    required this.regNumber,
    required this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.serviceArea,
    this.ratingAvg,
    this.totalClaims,
    this.totalPickupsCompleted,
    this.totalKgReceived,
  });

  factory NgoModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NgoModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      orgName: json['orgName']?.toString() ?? '',
      regNumber: json['regNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString(),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      contactPerson:
      json['contactPerson']?.toString(),
      serviceArea:
      json['serviceArea']?.toString(),
      ratingAvg: _double(json['ratingAvg']),
      totalClaims: _int(json['totalClaims']),
      totalPickupsCompleted:
      _int(json['totalPickupsCompleted']),
      totalKgReceived:
      _double(json['totalKgReceived']),
    );
  }

  static double? _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    );
  }

  static int? _int(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}