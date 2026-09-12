class ListingModel {
  final String id;
  final String donorOrgName;
  final String donorOrgType;
  final String title;
  final String? description;
  final String category;
  final double quantityKg;
  final DateTime expiryDate;
  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String pickupWindow;
  final String status;
  final List<String> imageUrls;
  final String? pickupNotes;
  final bool allowPartialClaims;
  final DateTime? createdAt;
  final int claimCount;

  const ListingModel({
    required this.id,
    required this.donorOrgName,
    required this.donorOrgType,
    required this.title,
    this.description,
    required this.category,
    required this.quantityKg,
    required this.expiryDate,
    required this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.pickupWindow,
    required this.status,
    required this.imageUrls,
    this.pickupNotes,
    required this.allowPartialClaims,
    this.createdAt,
    required this.claimCount,
  });

  factory ListingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ListingModel(
      id: json['id']?.toString() ?? '',

      donorOrgName:
      json['donorOrgName']?.toString() ?? '',

      donorOrgType:
      json['donorOrgType']?.toString() ?? '',

      title:
      json['title']?.toString() ?? '',

      description:
      json['description']?.toString(),

      category:
      json['category']?.toString() ?? '',

      quantityKg:
      _toDouble(json['quantityKg']),

      expiryDate:
      DateTime.parse(
        json['expiryDate'].toString(),
      ),

      pickupAddress:
      json['pickupAddress']?.toString() ?? '',

      pickupLatitude:
      _toNullableDouble(
        json['pickupLatitude'],
      ),

      pickupLongitude:
      _toNullableDouble(
        json['pickupLongitude'],
      ),

      pickupWindow:
      json['pickupWindow']?.toString() ?? '',

      status:
      json['status']?.toString() ?? 'AVAILABLE',

      imageUrls:
      _extractImageUrls(
        json['imageUrls'],
      ),

      pickupNotes:
      json['pickupNotes']?.toString(),

      allowPartialClaims:
      json['allowPartialClaims'] == true,

      createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.tryParse(
        json['createdAt'].toString(),
      ),

      claimCount:
      _toInt(json['claimCount']),
    );
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  static double? _toNullableDouble(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static List<String> _extractImageUrls(
      dynamic value,
      ) {
    if (value is! List) {
      return [];
    }

    final urls = <String>[];

    for (final item in value) {
      if (item is String) {
        urls.add(item);
        continue;
      }

      if (item is Map<String, dynamic>) {
        final url =
        item['url']?.toString();

        if (url != null &&
            url.isNotEmpty) {
          urls.add(url);
        }
      }
    }

    return urls;
  }
}