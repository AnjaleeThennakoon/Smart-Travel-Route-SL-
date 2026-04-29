import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

// ==================== MODELS ====================
class Place {
  final String id;
  final String name;
  final String description;
  final double rating;
  final double lat;
  final double lng;
  final String imageUrl;
  final String category;
  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.lat,
    required this.lng,
    this.imageUrl = '',
    this.category = '',
  });
}

class Driver {
  final String name;
  final String phone;
  final double rating;
  final String vehicleType;
  final double pricePerDay;
  Driver({
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicleType,
    required this.pricePerDay,
  });
}

// ==================== TRIP API SERVICE ====================
class TripApiService {
  static List<Map<String, dynamic>> _cachedCountries = [];

  static Future<List<Map<String, dynamic>>> searchCountries(
    String query,
  ) async {
    if (_cachedCountries.isEmpty) {
      await _loadCountries();
    }
    if (query.isEmpty) return _cachedCountries;
    return _cachedCountries
        .where(
          (c) =>
              c['name'].toLowerCase().contains(query.toLowerCase()) ||
              c['code'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  static Future<void> _loadCountries() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://restcountries.com/v3.1/all?fields=name,cca2,capital,currencies,flags',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        for (var country in data) {
          String name = country['name']?['common'] ?? '';
          String code = country['cca2'] ?? '';
          String capital =
              country['capital'] != null && country['capital'].isNotEmpty
              ? country['capital'][0]
              : 'N/A';
          String currency = country['currencies'] != null
              ? country['currencies'].keys.first
              : 'N/A';
          String flag = _getFlagEmoji(code);

          _cachedCountries.add({
            'name': name,
            'code': code,
            'capital': capital,
            'currency': currency,
            'flag': flag,
          });
        }
        _cachedCountries.sort((a, b) => a['name'].compareTo(b['name']));
      }
    } catch (e) {
      _useFallbackCountries();
    }
  }

  static String _getFlagEmoji(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    const offset = 127397;
    return String.fromCharCodes(
      countryCode.runes.map((r) => r + offset).toList(),
    );
  }

  static void _useFallbackCountries() {
    _cachedCountries = [
      {
        'name': 'Sri Lanka',
        'code': 'LK',
        'capital': 'Colombo',
        'currency': 'LKR',
        'flag': '🇱🇰',
      },
      {
        'name': 'India',
        'code': 'IN',
        'capital': 'New Delhi',
        'currency': 'INR',
        'flag': '🇮🇳',
      },
      {
        'name': 'Thailand',
        'code': 'TH',
        'capital': 'Bangkok',
        'currency': 'THB',
        'flag': '🇹🇭',
      },
      {
        'name': 'Japan',
        'code': 'JP',
        'capital': 'Tokyo',
        'currency': 'JPY',
        'flag': '🇯🇵',
      },
      {
        'name': 'France',
        'code': 'FR',
        'capital': 'Paris',
        'currency': 'EUR',
        'flag': '🇫🇷',
      },
      {
        'name': 'Italy',
        'code': 'IT',
        'capital': 'Rome',
        'currency': 'EUR',
        'flag': '🇮🇹',
      },
      {
        'name': 'Germany',
        'code': 'DE',
        'capital': 'Berlin',
        'currency': 'EUR',
        'flag': '🇩🇪',
      },
      {
        'name': 'USA',
        'code': 'US',
        'capital': 'Washington D.C.',
        'currency': 'USD',
        'flag': '🇺🇸',
      },
      {
        'name': 'UK',
        'code': 'GB',
        'capital': 'London',
        'currency': 'GBP',
        'flag': '🇬🇧',
      },
      {
        'name': 'Australia',
        'code': 'AU',
        'capital': 'Canberra',
        'currency': 'AUD',
        'flag': '🇦🇺',
      },
      {
        'name': 'Canada',
        'code': 'CA',
        'capital': 'Ottawa',
        'currency': 'CAD',
        'flag': '🇨🇦',
      },
      {
        'name': 'Maldives',
        'code': 'MV',
        'capital': 'Malé',
        'currency': 'MVR',
        'flag': '🇲🇻',
      },
      {
        'name': 'Singapore',
        'code': 'SG',
        'capital': 'Singapore',
        'currency': 'SGD',
        'flag': '🇸🇬',
      },
      {
        'name': 'Malaysia',
        'code': 'MY',
        'capital': 'Kuala Lumpur',
        'currency': 'MYR',
        'flag': '🇲🇾',
      },
      {
        'name': 'Vietnam',
        'code': 'VN',
        'capital': 'Hanoi',
        'currency': 'VND',
        'flag': '🇻🇳',
      },
      {
        'name': 'Indonesia',
        'code': 'ID',
        'capital': 'Jakarta',
        'currency': 'IDR',
        'flag': '🇮🇩',
      },
    ];
  }

  static List<Place> getPlacesForCountry(String countryName) {
    final Map<String, List<Place>> placesMap = {
      'Sri Lanka': [
        Place(
          id: '1',
          name: 'Sigiriya Rock',
          description: 'Ancient rock fortress',
          rating: 4.8,
          lat: 7.9569,
          lng: 80.7598,
          imageUrl: 'https://picsum.photos/id/1015/400/300',
          category: 'Historical',
        ),
        Place(
          id: '2',
          name: 'Kandy Temple',
          description: 'Temple of Tooth',
          rating: 4.9,
          lat: 7.2936,
          lng: 80.6336,
          imageUrl: 'https://picsum.photos/id/1016/400/300',
          category: 'Cultural',
        ),
        Place(
          id: '3',
          name: 'Ella Gap',
          description: 'Mountain views',
          rating: 4.7,
          lat: 6.8668,
          lng: 81.0461,
          imageUrl: 'https://picsum.photos/id/1018/400/300',
          category: 'Nature',
        ),
        Place(
          id: '4',
          name: 'Galle Fort',
          description: 'Dutch Fort',
          rating: 4.6,
          lat: 6.0322,
          lng: 80.2151,
          imageUrl: 'https://picsum.photos/id/1019/400/300',
          category: 'Historical',
        ),
        Place(
          id: '5',
          name: 'Bentota Beach',
          description: 'Beach paradise',
          rating: 4.5,
          lat: 6.4190,
          lng: 80.0030,
          imageUrl: 'https://picsum.photos/id/1020/400/300',
          category: 'Beach',
        ),
      ],
      'India': [
        Place(
          id: '6',
          name: 'Taj Mahal',
          description: 'Iconic monument',
          rating: 4.9,
          lat: 27.1751,
          lng: 78.0421,
          imageUrl: 'https://picsum.photos/id/1015/400/300',
          category: 'Historical',
        ),
        Place(
          id: '7',
          name: 'Goa Beach',
          description: 'Beach parties',
          rating: 4.6,
          lat: 15.2993,
          lng: 74.1240,
          imageUrl: 'https://picsum.photos/id/1016/400/300',
          category: 'Beach',
        ),
      ],
      'Thailand': [
        Place(
          id: '8',
          name: 'Phuket',
          description: 'Beautiful beaches',
          rating: 4.8,
          lat: 7.8804,
          lng: 98.3923,
          imageUrl: 'https://picsum.photos/id/1015/400/300',
          category: 'Beach',
        ),
        Place(
          id: '9',
          name: 'Bangkok',
          description: 'Vibrant capital',
          rating: 4.6,
          lat: 13.7367,
          lng: 100.5231,
          imageUrl: 'https://picsum.photos/id/1016/400/300',
          category: 'City',
        ),
      ],
      'Japan': [
        Place(
          id: '10',
          name: 'Tokyo',
          description: 'Modern metropolis',
          rating: 4.9,
          lat: 35.6762,
          lng: 139.6503,
          imageUrl: 'https://picsum.photos/id/1015/400/300',
          category: 'City',
        ),
        Place(
          id: '11',
          name: 'Kyoto',
          description: 'Ancient temples',
          rating: 4.8,
          lat: 35.0116,
          lng: 135.7681,
          imageUrl: 'https://picsum.photos/id/1016/400/300',
          category: 'Cultural',
        ),
      ],
      'France': [
        Place(
          id: '12',
          name: 'Eiffel Tower',
          description: 'Iconic landmark',
          rating: 4.9,
          lat: 48.8584,
          lng: 2.2945,
          imageUrl: 'https://picsum.photos/id/1015/400/300',
          category: 'Landmark',
        ),
        Place(
          id: '13',
          name: 'Louvre Museum',
          description: 'Art museum',
          rating: 4.8,
          lat: 48.8606,
          lng: 2.3376,
          imageUrl: 'https://picsum.photos/id/1016/400/300',
          category: 'Cultural',
        ),
      ],
    };
    return placesMap[countryName] ?? [];
  }
}

List<Map<String, dynamic>> getHotels() {
  return [
    {
      'name': 'Grand Plaza Hotel',
      'rating': 4.7,
      'price': 8500,
      'phone': '+94 112345678',
      'lat': 7.8731,
      'lng': 80.7718,
    },
    {
      'name': 'Sunset Resort',
      'rating': 4.8,
      'price': 7200,
      'phone': '+94 812345678',
      'lat': 7.2936,
      'lng': 80.6336,
    },
    {
      'name': 'City Inn',
      'rating': 4.5,
      'price': 5800,
      'phone': '+94 572345678',
      'lat': 6.8668,
      'lng': 81.0461,
    },
  ];
}

List<Driver> getDrivers() {
  return [
    Driver(
      name: 'Kamal Perera',
      phone: '+94 77 123 4567',
      rating: 4.8,
      vehicleType: 'Toyota Prius',
      pricePerDay: 4500,
    ),
    Driver(
      name: 'Nimal Silva',
      phone: '+94 71 987 6543',
      rating: 4.9,
      vehicleType: 'Suzuki Wagon R',
      pricePerDay: 4000,
    ),
    Driver(
      name: 'Sunil Bandara',
      phone: '+94 76 555 1234',
      rating: 4.7,
      vehicleType: 'Hyundai Grand i10',
      pricePerDay: 4200,
    ),
  ];
}

// ==================== FRIENDS PAGE ====================
class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Buddies'),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No friends added yet.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, [
                  {'name': 'Sarah Johnson', 'id': '1'},
                  {'name': 'Mike Chen', 'id': '2'},
                  {'name': 'Emma Watson', 'id': '3'},
                ]);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9C7C),
              ),
              child: const Text('Add Demo Friends'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CHAT PAGE ====================
class ChatPage extends StatelessWidget {
  const ChatPage({super.key, this.friend});
  final Map<String, dynamic>? friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          friend != null ? 'Chat with ${friend!['name']}' : 'Trip Chat',
        ),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
      body: const Center(child: Text('Chat feature coming soon!')),
    );
  }
}

// ==================== FULL SCREEN MAP PAGE ====================
class FullScreenMapPage extends StatefulWidget {
  final List<Place> places;
  final List<Place> selectedPlaces;

  const FullScreenMapPage({
    super.key,
    required this.places,
    required this.selectedPlaces,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  List<Place> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _updateRoute();
    _searchController.addListener(_onSearchChanged);
  }

  void _updateRoute() {
    _routePoints = widget.selectedPlaces
        .map((p) => LatLng(p.lat, p.lng))
        .toList();
    if (_routePoints.length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_routePoints),
            padding: const EdgeInsets.all(50),
          ),
        );
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        setState(() => _searchResults = []);
      } else {
        setState(() {
          _searchResults = widget.places
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
        });
      }
    });
  }

  void _addPlace(Place place) {
    Navigator.pop(context, place);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Map'),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(7.8731, 80.7718),
              initialZoom: 7,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF2D9C7C),
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...widget.selectedPlaces.asMap().entries.map(
                    (entry) => Marker(
                      point: LatLng(entry.value.lat, entry.value.lng),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D9C7C),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  ..._searchResults.map(
                    (place) => Marker(
                      point: LatLng(place.lat, place.lng),
                      child: GestureDetector(
                        onTap: () => _addPlace(place),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '🔍 Search for places...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2D9C7C),
                      ),
                      title: Text(place.name),
                      subtitle: Text(place.category),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF2D9C7C),
                        ),
                        onPressed: () => _addPlace(place),
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.selectedPlaces.length} places selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add new places',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Icon(Icons.swipe, color: Color(0xFF2D9C7C)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MAIN BUCKET PAGE ====================
class BucketPage extends StatefulWidget {
  const BucketPage({super.key});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  int _currentStep = 0;
  Map<String, dynamic>? _selectedCountry;
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 33));
  int _travelers = 2;
  double _budget = 50000;

  // Country Search
  final TextEditingController _countrySearchController =
      TextEditingController();
  List<Map<String, dynamic>> _countrySuggestions = [];
  bool _isLoadingCountries = false;

  // Places Search
  final TextEditingController _placeSearchController = TextEditingController();
  List<Place> _placeSuggestions = [];
  Timer? _debounce;
  List<Place> _selectedPlaces = [];
  List<Place> _allPlaces = [];

  // Hotels & Driver
  Map<String, dynamic>? _selectedHotel;
  Driver? _selectedDriver;

  // Friends
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _countrySearchController.addListener(_onCountrySearch);
    _placeSearchController.addListener(_onPlaceSearch);
  }

  // ==================== COUNTRY SEARCH ====================
  void _onCountrySearch() async {
    final query = _countrySearchController.text;
    if (query.isEmpty) {
      setState(() => _countrySuggestions = []);
      return;
    }
    setState(() => _isLoadingCountries = true);
    final results = await TripApiService.searchCountries(query);
    setState(() {
      _countrySuggestions = results;
      _isLoadingCountries = false;
    });
  }

  // ==================== PLACE SEARCH (WITH SUGGESTIONS) ====================
  void _onPlaceSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _placeSearchController.text.toLowerCase().trim();
      if (query.isEmpty) {
        setState(() => _placeSuggestions = []);
      } else if (_allPlaces.isNotEmpty) {
        setState(() {
          _placeSuggestions = _allPlaces
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.category.toLowerCase().contains(query),
              )
              .toList();
        });
      }
    });
  }

  void _selectCountry(Map<String, dynamic> country) {
    setState(() {
      _selectedCountry = country;
      _allPlaces = TripApiService.getPlacesForCountry(country['name']);
      _selectedPlaces = [];
      _countrySearchController.text = '${country['flag']} ${country['name']}';
      _countrySuggestions = [];
      _placeSearchController.clear();
      _placeSuggestions = [];
    });
  }

  void _selectPlace(Place place) {
    setState(() {
      if (!_selectedPlaces.contains(place)) {
        _selectedPlaces.add(place);
      }
      _placeSearchController.clear();
      _placeSuggestions = [];
    });
  }

  void _removePlace(Place place) {
    setState(() {
      _selectedPlaces.remove(place);
    });
  }

  void _openFullScreenMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapPage(
          places: _allPlaces,
          selectedPlaces: _selectedPlaces,
        ),
      ),
    );
    if (result != null && result is Place) {
      _selectPlace(result);
    }
  }

  void _saveTrip() {
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one place'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Trip saved successfully!'),
        backgroundColor: Color(0xFF2D9C7C),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _countrySearchController.dispose();
    _placeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Plan Your Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D9C7C),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStepIndicator(1, 'Dest', _currentStep >= 0),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 1
                        ? const Color(0xFF2D9C7C)
                        : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(2, 'Places', _currentStep >= 1),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 2
                        ? const Color(0xFF2D9C7C)
                        : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(3, 'Stay', _currentStep >= 2),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 3
                        ? const Color(0xFF2D9C7C)
                        : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(4, 'Friends', _currentStep >= 3),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2D9C7C)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      } else {
                        _saveTrip();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D9C7C),
                    ),
                    child: Text(_currentStep == 3 ? 'Save Trip' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF2D9C7C) : Colors.white,
            border: Border.all(
              color: isActive ? const Color(0xFF2D9C7C) : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF2D9C7C) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ==================== STEP 1: DESTINATION ====================
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Country',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countrySearchController,
            decoration: InputDecoration(
              hintText: '🔍 Type country name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isLoadingCountries
                  ? const SizedBox(
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          if (_countrySuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _countrySuggestions.length,
                itemBuilder: (context, index) {
                  final country = _countrySuggestions[index];
                  return ListTile(
                    leading: Text(
                      country['flag'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      country['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${country['capital']} • ${country['currency']}',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF2D9C7C),
                    ),
                    onTap: () => _selectCountry(country),
                  );
                },
              ),
            ),
          if (_selectedCountry != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D9C7C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry!['flag'],
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCountry!['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedCountry!['capital']} • ${_selectedCountry!['currency']}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Travel Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: _startDate.add(const Duration(days: 30)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Travelers & Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(
                            () => _travelers = _travelers > 1
                                ? _travelers - 1
                                : 1,
                          ),
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Text(
                          '$_travelers',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _travelers++),
                          icon: const Icon(Icons.add, size: 18),
                        ),
                        const SizedBox(width: 4),
                        const Text('travelers'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget (LKR)',
                      prefixIcon: Icon(Icons.currency_rupee),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _budget = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==================== STEP 2: SELECT PLACES ====================
  Widget _buildStep2() {
    if (_selectedCountry == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please select a country first',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _placeSearchController,
            decoration: InputDecoration(
              hintText: '🔍 Search places in ${_selectedCountry!['name']}...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2D9C7C)),
              suffixIcon: _placeSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _placeSearchController.clear();
                        setState(() => _placeSuggestions = []);
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // Search Suggestions
        if (_placeSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _placeSuggestions.length,
              itemBuilder: (context, index) {
                final place = _placeSuggestions[index];
                final isSelected = _selectedPlaces.contains(place);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: place.imageUrl,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 45,
                        height: 45,
                        color: Colors.grey[200],
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 45,
                        height: 45,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(place.category),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF2D9C7C))
                      : IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF2D9C7C),
                          ),
                          onPressed: () => _selectPlace(place),
                        ),
                  onTap: () => _selectPlace(place),
                );
              },
            ),
          ),

        // Selected Places - Horizontal Scroll Row with Images
        if (_selectedPlaces.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ Selected Places',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _selectedPlaces[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: place.imageUrl,
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 80,
                                      color: Colors.grey[200],
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, size: 30),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removePlace(place),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // All Places Grid (if no search query)
        if (_placeSearchController.text.isEmpty)
          Expanded(
            child: _allPlaces.isEmpty
                ? const Center(
                    child: Text('No places available for this country'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _allPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _allPlaces[index];
                      final isSelected = _selectedPlaces.contains(place);
                      return GestureDetector(
                        onTap: () => _selectPlace(place),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2D9C7C).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2D9C7C)
                                  : Colors.grey[200]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: place.imageUrl,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 12,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          place.rating.toString(),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    if (isSelected)
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Color(0xFF2D9C7C),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Added',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF2D9C7C),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

        // Map Button
        if (_selectedPlaces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openFullScreenMap,
                icon: const Icon(Icons.map),
                label: const Text('View on Full Screen Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D9C7C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== STEP 3: HOTELS & DRIVER ====================
  Widget _buildStep3() {
    final hotels = getHotels();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏨 Select Hotel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...hotels.map(
            (hotel) => RadioListTile<Map<String, dynamic>>(
              title: Text(
                hotel['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '⭐ ${hotel['rating']} • LKR ${hotel['price']}/night',
              ),
              secondary: IconButton(
                icon: const Icon(Icons.phone, color: Color(0xFF2D9C7C)),
                onPressed: () {},
              ),
              value: hotel,
              groupValue: _selectedHotel,
              onChanged: (value) => setState(() => _selectedHotel = value),
              activeColor: const Color(0xFF2D9C7C),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🚗 Select Driver',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...getDrivers().map(
            (driver) => RadioListTile<Driver>(
              title: Text(
                driver.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${driver.vehicleType} • ⭐ ${driver.rating} • LKR ${driver.pricePerDay}/day',
              ),
              secondary: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {},
              ),
              value: driver,
              groupValue: _selectedDriver,
              onChanged: (value) => setState(() => _selectedDriver = value),
              activeColor: const Color(0xFF2D9C7C),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 4: FRIENDS ====================
  Widget _buildStep4() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsPage()),
              );
              if (result != null) setState(() => _friends = result);
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Travel Buddies'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D9C7C),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: _friends.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No friends added yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add friends to plan together',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF2D9C7C,
                          ).withOpacity(0.2),
                          child: Text(
                            friend['name'][0],
                            style: const TextStyle(color: Color(0xFF2D9C7C)),
                          ),
                        ),
                        title: Text(friend['name']),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.chat,
                            color: Color(0xFF2D9C7C),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(friend: friend),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
