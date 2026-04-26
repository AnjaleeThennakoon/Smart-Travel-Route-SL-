import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api';
  static bool useMockApi = true;

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
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String country,
    required String countryCode,
    required String mobileNumber,
    required String password,
  }) async {
    if (useMockApi) {
      await Future.delayed(const Duration(seconds: 2));

      if (email == 'test@example.com' || email == 'existing@gmail.com') {
        return {
          'success': false,
          'message': 'Email already exists. Please use another email.',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters.',
        };
      }
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
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
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'country': country,
          'country_code': countryCode,
          'mobile_number': mobileNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentUser = data;
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              error['message'] ?? 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    if (useMockApi) {
      await Future.delayed(const Duration(seconds: 1));

      if (email == 'test@example.com') {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      if (password.length < 6) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final userData = {
        'id': '12345',
        'full_name': email.split('@')[0],
        'email': email,
        'country': 'Sri Lanka',
        'country_code': '+94',
        'mobile_number': '0712345678',
      };

      _currentUser = userData;

      return {
        'success': true,
        'data': userData,
        'message': 'Login successful!',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data;
        return {'success': true, 'data': data, 'message': 'Login successful!'};
      } else {
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static void logout() {
    _currentUser = null;
  }

  static Future<bool> checkEmailExists(String email) async {
    if (useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return email == 'test@example.com' || email == 'existing@gmail.com';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String getCountryCode(String countryName) {
    final Map<String, String> countryCodes = {
      'Sri Lanka': '+94','USA': '+1','UK': '+44','Canada': '+1','Australia': '+61','India': '+91','Vietnam': '+84','Thailand': '+66',
      'Malaysia': '+60','Singapore': '+65','Japan': '+81','South Korea': '+82','China': '+86','Germany': '+49','France': '+33',
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

  // ==================== DESTINATION APIs ====================

  static Future<List<Map<String, dynamic>>> getDestinations() async {
    if (useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockDestinations;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/destinations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    if (useMockApi) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockDestinations.where((place) {
        return place['name'].toLowerCase().contains(query.toLowerCase()) ||
            place['location'].toLowerCase().contains(query.toLowerCase()) ||
            place['country'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getDestinationsByCategory(
    String category,
  ) async {
    if (useMockApi) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (category == 'All') return _mockDestinations;
      return _mockDestinations
          .where((place) => place['category'] == category)
          .toList();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/destinations?category=$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static List<String> getCategories() {
    return ['All', 'Beach', 'Mountain', 'City'];
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
  static final List<Map<String, dynamic>> _savedDestinations = [];

  // Get saved destinations
  static List<Map<String, dynamic>> getSavedDestinations() {
    return _savedDestinations;
  }
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
  static bool isDestinationSaved(String id) {
    return _savedDestinations.any((d) => d['id'] == id);
  }
  static void clearAllSavedDestinations() {
    _savedDestinations.clear();
  }
  static double calculateTotalFare(double distance, double pricePerKm, double driverDaily) {
    // (දුර * කිලෝමීටරයක මිල) + රියදුරුගේ දෛනික ආහාර/නවාතැන් ගාස්තු
    return (distance * pricePerKm) + driverDaily;
  }
  static Future<Map<String, dynamic>> getWeather(String city) async {
    const apiKey = "57fc4852444627a5dee14fcd761839dc"; 
    final url = "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load weather");
      }
    } catch (e) {
      return {"main": {"temp": 0}, "weather": [{"main": "Offline"}]};
    }
  }
}
