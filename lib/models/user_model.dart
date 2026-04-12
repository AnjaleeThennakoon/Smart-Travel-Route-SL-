class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String country;
  final String countryCode;
  final String mobileNumber;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.country,
    required this.countryCode,
    required this.mobileNumber,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'country': country,
      'country_code': countryCode,
      'mobile_number': mobileNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
