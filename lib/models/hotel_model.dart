class Hotel {
  final String hotelId;
  final String userId;
  final String hotelName;
  final String? description;
  final String? contactNumber;
  final double? pricePerNight;
  final List<String>? photos;
  final double latitude;
  final double longitude;
  final String category;
  final DateTime createdAt;

  Hotel({
    required this.hotelId,
    required this.userId,
    required this.hotelName,
    this.description,
    this.contactNumber,
    this.pricePerNight,
    this.photos,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
  });

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      hotelId: (map['hotel_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      hotelName: (map['hotel_name'] ?? '').toString(),
      description: map['description']?.toString(),
      contactNumber: map['contact_number']?.toString(),
      pricePerNight: (map['price_per_night'] as num?)?.toDouble(),
      photos: map['photos'] != null
          ? List<String>.from(map['photos'] as List<dynamic>)
          : null,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      category: (map['category'] ?? 'Hotels').toString(),
      createdAt:
          DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotel_id': hotelId,
      'user_id': userId,
      'hotel_name': hotelName,
      'description': description,
      'contact_number': contactNumber,
      'price_per_night': pricePerNight,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
