class VisitingPlace {
  final String visitingPlaceId;
  final String userId;
  final String name;
  final String? description;
  final List<String>? photos;
  final double latitude;
  final double longitude;
  final String category;
  final DateTime createdAt;

  VisitingPlace({
    required this.visitingPlaceId,
    required this.userId,
    required this.name,
    this.description,
    this.photos,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
  });

  factory VisitingPlace.fromMap(Map<String, dynamic> map) {
    return VisitingPlace(
      visitingPlaceId: (map['visiting_place_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      photos: map['photos'] != null
          ? List<String>.from(map['photos'] as List<dynamic>)
          : null,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      category: (map['category'] ?? 'Visiting Places').toString(),
      createdAt:
          DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visiting_place_id': visitingPlaceId,
      'user_id': userId,
      'name': name,
      'description': description,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
