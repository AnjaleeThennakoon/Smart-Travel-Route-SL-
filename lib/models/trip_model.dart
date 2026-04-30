class Trip {
  final String tripId;
  final String userId;
  final String tripName;
  final String? description;
  final String startLocation;
  final double totalDistance;
  final int totalDuration;
  final DateTime createdAt;

  const Trip({
    required this.tripId,
    required this.userId,
    required this.tripName,
    this.description,
    required this.startLocation,
    required this.totalDistance,
    required this.totalDuration,
    required this.createdAt,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      tripId: (map['trip_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      tripName: (map['trip_name'] ?? '').toString(),
      description: map['description']?.toString(),
      startLocation: (map['start_location'] ?? '').toString(),
      totalDistance: (map['total_distance'] as num?)?.toDouble() ?? 0,
      totalDuration: (map['total_duration'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trip_id': tripId,
      'user_id': userId,
      'trip_name': tripName,
      'description': description,
      'start_location': startLocation,
      'total_distance': totalDistance,
      'total_duration': totalDuration,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TripPlace {
  final String tripPlaceId;
  final String tripId;
  final String placeName;
  final double latitude;
  final double longitude;
  final int visitOrder;
  final double distanceFromPrevious;
  final int durationFromPrevious;

  const TripPlace({
    required this.tripPlaceId,
    required this.tripId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.visitOrder,
    required this.distanceFromPrevious,
    required this.durationFromPrevious,
  });

  factory TripPlace.fromMap(Map<String, dynamic> map) {
    return TripPlace(
      tripPlaceId: (map['trip_place_id'] ?? '').toString(),
      tripId: (map['trip_id'] ?? '').toString(),
      placeName: (map['place_name'] ?? '').toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      visitOrder: (map['visit_order'] as num?)?.toInt() ?? 0,
      distanceFromPrevious:
          (map['distance_from_previous'] as num?)?.toDouble() ?? 0,
      durationFromPrevious:
          (map['duration_from_previous'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'trip_id': tripId,
      'place_name': placeName,
      'latitude': latitude,
      'longitude': longitude,
      'visit_order': visitOrder,
      'distance_from_previous': distanceFromPrevious,
      'duration_from_previous': durationFromPrevious,
    };
  }
}

class TripWithPlaces {
  final Trip trip;
  final List<TripPlace> places;

  const TripWithPlaces({required this.trip, required this.places});
}