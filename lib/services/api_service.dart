import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../models/trip_model.dart';
import '../models/visiting_place_model.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api';
  static const String _overpassApiUrl =
      'https://overpass-api.de/api/interpreter';
  static final _supabase = Supabase.instance.client; // ✅ ADD THIS

  static Map<String, dynamic>? _currentUser;
  static Map<String, dynamic>? get currentUser => _currentUser;

  static String getUserName() {
    if (_currentUser != null) {
      return _currentUser!['full_name'] ??
          _currentUser!['fullName'] ??
          'Traveler';
    }
    return 'Traveler';
  }

  static void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  static void clearCurrentUser() {
    _currentUser = null;
  }

  // ✅ REPLACED - Now uses Supabase instead of mock/http
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String country,
    required String countryCode,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      // Step 1: Create auth account
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Sign up failed. Please try again.',
        };
      }

      // Step 2: Save profile to users table
      await _supabase.from('users').insert({
        'user_id': user.id,
        'full_name': fullName,
        'email': email,
        'country': country,
        'country_code': countryCode,
        'phone_number': mobileNumber,
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      final userData = {
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'country': country,
        'country_code': countryCode,
        'mobile_number': mobileNumber,
        'created_at': DateTime.now().toIso8601String(),
      };

      _currentUser = userData;

      return {
        'success': true,
        'data': userData,
        'message': 'Registration successful! Welcome to Ayubo Travel.',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': 'Database error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // ✅ REPLACED - Now uses Supabase instead of mock/http
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Try to sign in with Supabase
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Fetch profile from users table
      final profile = await _supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .single();

      _currentUser = profile;

      return {'success': true, 'data': profile, 'message': 'Login successful!'};
    } on AuthException catch (e) {
      // ✅ This catches wrong email/password from Supabase
      return {'success': false, 'message': e.message};
    } on PostgrestException catch (e) {
      return {'success': false, 'message': 'Database error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // ✅ REPLACED - Now uses Supabase signOut
  static Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  // ✅ REPLACED - Check via Supabase auth
  static Future<bool> checkEmailExists(String email) async {
    try {
      final data = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // ── Everything below this line is UNCHANGED ────────────────

  static String getCountryCode(String countryName) {
    final Map<String, String> countryCodes = {
      'Sri Lanka': '+94',
      'USA': '+1',
      'UK': '+44',
      'Canada': '+1',
      'Australia': '+61',
      'India': '+91',
      'Vietnam': '+84',
      'Thailand': '+66',
      'Malaysia': '+60',
      'Singapore': '+65',
      'Japan': '+81',
      'South Korea': '+82',
      'China': '+86',
      'Germany': '+49',
      'France': '+33',
    };
    return countryCodes[countryName] ?? '+00';
  }

  static List<String> getCountries() {
    return [
      'Sri Lanka',
      'USA',
      'UK',
      'Canada',
      'Australia',
      'India',
      'Vietnam',
      'Thailand',
      'Malaysia',
      'Singapore',
      'Japan',
      'South Korea',
      'China',
      'Germany',
      'France',
      'Italy',
      'Spain',
    ];
  }

  static List<String> getCategories() {
    return ['All', 'Beach', 'Mountain', 'City'];
  }

  static Future<List<Map<String, dynamic>>> getDestinations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDestinations;
  }

  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDestinations.where((place) {
      return place['name'].toLowerCase().contains(query.toLowerCase()) ||
          place['location'].toLowerCase().contains(query.toLowerCase()) ||
          place['country'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getDestinationsByCategory(
    String category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'All') return _mockDestinations;
    return _mockDestinations
        .where((place) => place['category'] == category)
        .toList();
  }

  static double calculateTotalFare(
    double distance,
    double pricePerKm,
    double driverDaily,
  ) {
    return (distance * pricePerKm) + driverDaily;
  }

  static Future<Map<String, dynamic>> getWeather(String city) async {
    const apiKey = "57fc4852444627a5dee14fcd761839dc";
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load weather");
      }
    } catch (e) {
      return {
        "main": {"temp": 0},
        "weather": [
          {"main": "Offline"},
        ],
      };
    }
  }

  static List<String> _overpassCategoryClauses(String category) {
    return switch (category) {
      'Hotels' => ['node["tourism"="hotel"]', 'node["tourism"="guest_house"]'],
      'Restaurants' => [
        'node["amenity"="restaurant"]',
        'node["amenity"="cafe"]',
      ],
      'Gas Stations' => ['node["amenity"="fuel"]'],
      'Visiting Places' => [
        'node["tourism"="attraction"]',
        'node["tourism"="museum"]',
        'node["leisure"="park"]',
      ],
      'Other' => [
        'node["amenity"="bank"]',
        'node["shop"]',
        'node["amenity"="hospital"]',
      ],
      'All' => [
        'node["tourism"="hotel"]',
        'node["tourism"="guest_house"]',
        'node["amenity"="restaurant"]',
        'node["amenity"="cafe"]',
        'node["amenity"="fuel"]',
        'node["tourism"="attraction"]',
        'node["tourism"="museum"]',
        'node["leisure"="park"]',
        'node["amenity"="bank"]',
        'node["shop"]',
      ],
      _ => ['node["name"]'],
    };
  }

  static Future<List<Map<String, dynamic>>> searchNearbyPlacesByCategory({
    required String category,
    required double latitude,
    required double longitude,
    int radiusMeters = 4000,
  }) async {
    final clauses = _overpassCategoryClauses(
      category,
    ).map((c) => '$c(around:$radiusMeters,$latitude,$longitude);').join();
    final query = '[out:json][timeout:25];($clauses);out body;';

    final response = await http.post(
      Uri.parse(_overpassApiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'data=${Uri.encodeQueryComponent(query)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Overpass search failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (body['elements'] as List<dynamic>? ?? const []);
    return elements
        .map((item) {
          final map = item as Map<String, dynamic>;
          final tags = (map['tags'] as Map<String, dynamic>? ?? const {});
          final lat = (map['lat'] as num?)?.toDouble() ?? 0;
          final lon = (map['lon'] as num?)?.toDouble() ?? 0;
          final name = (tags['name'] ?? tags['brand'] ?? category).toString();
          final street = tags['addr:street']?.toString() ?? '';
          final city = tags['addr:city']?.toString() ?? '';
          final address = [street, city].where((e) => e.isNotEmpty).join(', ');
          return {
            'name': name,
            'address': address,
            'latitude': lat,
            'longitude': lon,
          };
        })
        .where(
          (p) =>
              (p['latitude'] as double) != 0 && (p['longitude'] as double) != 0,
        )
        .toList();
  }

  // Saved destinations (keep in memory for now)
  static final List<Map<String, dynamic>> _savedDestinations = [];
  static List<Map<String, dynamic>> getSavedDestinations() =>
      _savedDestinations;
  static bool isDestinationSaved(String id) =>
      _savedDestinations.any((d) => d['id'] == id);
  static void clearAllSavedDestinations() => _savedDestinations.clear();
  static void toggleSaveDestination(Map<String, dynamic> destination) {
    final index = _savedDestinations.indexWhere(
      (d) => d['id'] == destination['id'],
    );
    if (index == -1) {
      _savedDestinations.add(destination);
    } else {
      _savedDestinations.removeAt(index);
    }
  }

  static String _resolveCurrentUserId() {
    final userMap = _currentUser;
    final fromMap = userMap?['user_id'] ?? userMap?['id'];
    final fromAuth = _supabase.auth.currentUser?.id;
    final resolved = (fromMap ?? fromAuth ?? '').toString();
    if (resolved.isEmpty) {
      throw Exception('No logged-in user found.');
    }
    return resolved;
  }

  static Future<List<Trip>> getUserTrips(String userId) async {
    final rows = await _supabase
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((row) => Trip.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Trip>> getCurrentUserTrips() async {
    return getUserTrips(_resolveCurrentUserId());
  }

  static Future<List<TripPlace>> insertTripPlacesBatch({
    required String tripId,
    required List<TripPlace> places,
  }) async {
    if (places.isEmpty) return const [];
    final payload = places.asMap().entries.map((entry) {
      final place = entry.value;
      return {
        'trip_id': tripId,
        'place_name': place.placeName,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'visit_order': place.visitOrder == 0 ? entry.key + 1 : place.visitOrder,
        'distance_from_previous': place.distanceFromPrevious,
        'duration_from_previous': place.durationFromPrevious,
      };
    }).toList();

    final rows = await _supabase.from('trip_places').insert(payload).select();
    return (rows as List<dynamic>)
        .map((row) => TripPlace.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<TripWithPlaces> saveTripForCurrentUser({
    required String tripName,
    required String startLocation,
    required double totalDistance,
    required int totalDuration,
    String? description,
    required List<TripPlace> places,
  }) async {
    final userId = _resolveCurrentUserId();
    final tripRow = await _supabase
        .from('trips')
        .insert({
          'user_id': userId,
          'trip_name': tripName,
          'description': description,
          'start_location': startLocation,
          'total_distance': totalDistance,
          'total_duration': totalDuration,
        })
        .select()
        .single();

    final trip = Trip.fromMap(tripRow);
    final savedPlaces = await insertTripPlacesBatch(
      tripId: trip.tripId,
      places: places,
    );
    return TripWithPlaces(trip: trip, places: savedPlaces);
  }

  static Future<Hotel> saveHotelForCurrentUser({
    required String hotelName,
    String? description,
    String? contactNumber,
    double? pricePerNight,
    List<String>? photos,
    required double latitude,
    required double longitude,
    String category = 'Hotels',
  }) async {
    final userId = _resolveCurrentUserId();
    final hotelRow = await _supabase
        .from('hotels')
        .insert({
          'user_id': userId,
          'hotel_name': hotelName,
          'description': description,
          'contact_number': contactNumber,
          'price_per_night': pricePerNight,
          'photos': photos,
          'latitude': latitude,
          'longitude': longitude,
          'category': category,
        })
        .select()
        .single();

    return Hotel.fromMap(hotelRow);
  }

  static Future<String> uploadHotelPhoto(
    String hotelId,
    String filePath,
  ) async {
    try {
      final file = await _readFile(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final path = 'hotels/$hotelId/$fileName';

      await _supabase.storage
          .from('place_photos')
          .uploadBinary(path, Uint8List.fromList(file));

      final publicUrl = _supabase.storage
          .from('place_photos')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  static Future<void> updateHotelPhotos(
    String hotelId,
    List<String> photoUrls,
  ) async {
    await _supabase
        .from('hotels')
        .update({'photos': photoUrls})
        .eq('hotel_id', hotelId);
  }

  static Future<List<Hotel>> getCurrentUserHotels() async {
    final rows = await _supabase
        .from('hotels')
        .select()
        .eq('user_id', _resolveCurrentUserId())
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => Hotel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Hotel>> getAllHotels() async {
    final rows = await _supabase
        .from('hotels')
        .select(
          'hotel_id,user_id,hotel_name,description,contact_number,photos,price_per_night,latitude,longitude,category,created_at',
        )
        .order('created_at', ascending: false);

    final hotels = (rows as List<dynamic>)
        .map((row) => Hotel.fromMap(row as Map<String, dynamic>))
        .toList();

    debugPrint('getAllHotels() returned ${hotels.length} hotels');
    return hotels;
  }

  static Future<String> uploadVisitingPlacePhoto(
    String visitingPlaceId,
    String filePath,
  ) async {
    try {
      final file = await _readFile(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final path = 'visiting_places/$visitingPlaceId/$fileName';

      await _supabase.storage
          .from('place_photos')
          .uploadBinary(path, Uint8List.fromList(file));

      final publicUrl = _supabase.storage
          .from('place_photos')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  static Future<List<int>> _readFile(String filePath) async {
    try {
      return await File(filePath).readAsBytes();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  static Future<VisitingPlace> saveVisitingPlaceForCurrentUser({
    required String name,
    String? description,
    List<String>? photos,
    required double latitude,
    required double longitude,
    String category = 'Visiting Places',
  }) async {
    final userId = _resolveCurrentUserId();
    final visitingPlaceRow = await _supabase
        .from('visiting_places')
        .insert({
          'user_id': userId,
          'name': name,
          'description': description,
          'photos': photos,
          'latitude': latitude,
          'longitude': longitude,
          'category': category,
        })
        .select()
        .single();

    return VisitingPlace.fromMap(visitingPlaceRow);
  }

  static Future<List<VisitingPlace>> getCurrentUserVisitingPlaces() async {
    final rows = await _supabase
        .from('visiting_places')
        .select()
        .eq('user_id', _resolveCurrentUserId())
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => VisitingPlace.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<List<VisitingPlace>> getAllVisitingPlaces() async {
    final rows = await _supabase
        .from('visiting_places')
        .select(
          'visiting_place_id,user_id,name,description,photos,latitude,longitude,category,created_at',
        )
        .order('created_at', ascending: false);

    final visitingPlaces = (rows as List<dynamic>)
        .map((row) => VisitingPlace.fromMap(row as Map<String, dynamic>))
        .toList();

    debugPrint('getAllVisitingPlaces() returned ${visitingPlaces.length} visiting places');
    return visitingPlaces;
  }

  static Future<void> updateVisitingPlacePhotos(
    String visitingPlaceId,
    List<String> photoUrls,
  ) async {
    await _supabase
        .from('visiting_places')
        .update({'photos': photoUrls})
        .eq('visiting_place_id', visitingPlaceId);
  }

  static Future<TripWithPlaces> getTripDetailsWithPlaces(String tripId) async {
    final tripRow = await _supabase
        .from('trips')
        .select()
        .eq('trip_id', tripId)
        .single();
    final placeRows = await _supabase
        .from('trip_places')
        .select()
        .eq('trip_id', tripId)
        .order('visit_order', ascending: true);

    return TripWithPlaces(
      trip: Trip.fromMap(tripRow),
      places: (placeRows as List<dynamic>)
          .map((row) => TripPlace.fromMap(row as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<void> deleteTrip(String tripId) async {
    await _supabase.from('trips').delete().eq('trip_id', tripId);
  }

  static Future<void> deleteHotel(String hotelId) async {
    await _supabase.from('hotels').delete().eq('hotel_id', hotelId);
  }

  static Future<void> deleteVisitingPlace(String visitingPlaceId) async {
    await _supabase.from('visiting_places').delete().eq('visiting_place_id', visitingPlaceId);
  }

  // Hotel Ratings Methods
  static Future<double> getHotelAverageRating(String hotelId) async {
    final rows = await _supabase
        .from('hotel_ratings')
        .select('rating')
        .eq('hotel_id', hotelId);

    if (rows.isEmpty) return 0.0;

    final ratings = (rows as List<dynamic>).map((row) => row['rating'] as int).toList();
    final sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  static Future<int?> getUserHotelRating(String hotelId) async {
    final userId = _resolveCurrentUserId();
    final rows = await _supabase
        .from('hotel_ratings')
        .select('rating')
        .eq('hotel_id', hotelId)
        .eq('user_id', userId);

    if (rows.isEmpty) return null;
    return (rows.first)['rating'] as int;
  }

  static Future<void> submitHotelRating(String hotelId, int rating) async {
    final userId = _resolveCurrentUserId();
    
    await _supabase
        .from('hotel_ratings')
        .upsert({
          'hotel_id': hotelId,
          'user_id': userId,
          'rating': rating,
        });
  }

  static Future<int> getHotelRatingCount(String hotelId) async {
    final rows = await _supabase
        .from('hotel_ratings')
        .select('rating_id')
        .eq('hotel_id', hotelId);

    return rows.length;
  }

  static final List<Map<String, dynamic>> _mockDestinations = [
    {
      'id': '1',
      'name': 'Bali',
      'location': 'Ubud, Bali',
      'country': 'Indonesia',
      'price': 89,
      'rating': 4.8,
      'category': 'Beach',
      'imageUrl':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=500',
      'description': 'Beautiful beaches and rice terraces',
    },
    {
      'id': '2',
      'name': 'Swiss Alps',
      'location': 'Jungfraujoch',
      'country': 'Switzerland',
      'price': 199,
      'rating': 4.9,
      'category': 'Mountain',
      'imageUrl':
          'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=500',
    },
    {
      'id': '3',
      'name': 'Tokyo',
      'location': 'Shinjuku',
      'country': 'Japan',
      'price': 149,
      'rating': 4.7,
      'category': 'City',
      'imageUrl':
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=500',
    },
    {
      'id': '4',
      'name': 'Maldives',
      'location': 'Male',
      'country': 'Maldives',
      'price': 299,
      'rating': 4.9,
      'category': 'Beach',
      'imageUrl':
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=500',
    },
    {
      'id': '5',
      'name': 'Paris',
      'location': 'Eiffel Tower',
      'country': 'France',
      'price': 159,
      'rating': 4.8,
      'category': 'City',
      'imageUrl':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=500',
    },
    {
      'id': '6',
      'name': 'Himalayas',
      'location': 'Everest Base Camp',
      'country': 'Nepal',
      'price': 129,
      'rating': 4.7,
      'category': 'Mountain',
      'imageUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500',
    },
    {
      'id': '7',
      'name': 'Phuket',
      'location': 'Patong Beach',
      'country': 'Thailand',
      'price': 79,
      'rating': 4.6,
      'category': 'Beach',
      'imageUrl':
          'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=500',
    },
    {
      'id': '8',
      'name': 'New York',
      'location': 'Manhattan',
      'country': 'USA',
      'price': 189,
      'rating': 4.8,
      'category': 'City',
      'imageUrl':
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=500',
    },
    {
      'id': '9',
      'name': 'Banff',
      'location': 'Lake Louise',
      'country': 'Canada',
      'price': 169,
      'rating': 4.9,
      'category': 'Mountain',
      'imageUrl':
          'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=500',
    },
    {
      'id': '10',
      'name': 'Santorini',
      'location': 'Oia',
      'country': 'Greece',
      'price': 179,
      'rating': 4.9,
      'category': 'Beach',
      'imageUrl':
          'https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?w=500',
    },
    {
      'id': '11',
      'name': 'Singapore',
      'location': 'Marina Bay',
      'country': 'Singapore',
      'price': 139,
      'rating': 4.7,
      'category': 'City',
      'imageUrl':
          'https://images.unsplash.com/photo-1525625293386-3f2f0b89e4c4?w=500',
    },
    {
      'id': '12',
      'name': 'Kandy',
      'location': 'Temple of Tooth',
      'country': 'Sri Lanka',
      'price': 69,
      'rating': 4.6,
      'category': 'City',
      'imageUrl':
          'https://images.unsplash.com/photo-1585939535763-5f6b18f1c0b3?w=500',
    },
  ];
}
