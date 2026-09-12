class UserModel {
  final String? id;
  final String? email;
  final String? fullName;
  final String? role;
  final String? phone;

  const UserModel({
    this.id,
    this.email,
    this.fullName,
    this.role,
    this.phone,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      fullName: json['fullName']?.toString(),
      role: json['role']?.toString().toUpperCase(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
    };
  }
}
