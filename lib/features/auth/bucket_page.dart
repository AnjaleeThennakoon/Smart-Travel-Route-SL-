import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// ✅ Use your existing ApiService

// ==================== TRIP MODEL ====================
class TripPlan {
  final String id;
  final String destination;
  final String country;
  final String countryFlag;
  final String image;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;
  final double budget;
  final String accommodation;
  final String transport;
  final List<String> activities;
  final String notes;
  final String status;
  final String hotelName;
  final String hotelPhone;
  final String hotelAddress;
  final List<Map<String, dynamic>>? selectedPlaces;
  final double? spentAmount;

  TripPlan({
    required this.id,
    required this.destination,
    required this.country,
    required this.countryFlag,
    required this.image,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    required this.budget,
    required this.accommodation,
    required this.transport,
    required this.activities,
    required this.notes,
    required this.status,
    required this.hotelName,
    required this.hotelPhone,
    required this.hotelAddress,
    this.selectedPlaces,
    this.spentAmount,
  });

  int get duration => endDate.difference(startDate).inDays;
  double get budgetPerDay => budget / duration;
  double get remainingBudget => budget - (spentAmount ?? 0);
}

// ==================== BUCKET SERVICE ====================
class BucketService {
  static final List<TripPlan> _trips = [];
  static List<TripPlan> getTrips() => _trips;
  static void addTrip(TripPlan trip) => _trips.add(trip);
  static void deleteTrip(String id) => _trips.removeWhere((t) => t.id == id);
}

// ==================== COUNTRY DATA ====================
class CountryHelper {
  static List<Map<String, dynamic>> getCountries() {
    return [
      {
        'name': 'Sri Lanka',
        'emoji': '🇱🇰',
        'code': 'LK',
        'capital': 'Colombo',
        'currency': 'LKR',
        'lat': 7.8731,
        'lng': 80.7718,
      },
      {
        'name': 'India',
        'emoji': '🇮🇳',
        'code': 'IN',
        'capital': 'New Delhi',
        'currency': 'INR',
        'lat': 20.5937,
        'lng': 78.9629,
      },
      {
        'name': 'Thailand',
        'emoji': '🇹🇭',
        'code': 'TH',
        'capital': 'Bangkok',
        'currency': 'THB',
        'lat': 15.8700,
        'lng': 100.9925,
      },
      {
        'name': 'Maldives',
        'emoji': '🇲🇻',
        'code': 'MV',
        'capital': 'Malé',
        'currency': 'MVR',
        'lat': 3.2028,
        'lng': 73.2207,
      },
      {
        'name': 'Japan',
        'emoji': '🇯🇵',
        'code': 'JP',
        'capital': 'Tokyo',
        'currency': 'JPY',
        'lat': 36.2048,
        'lng': 138.2529,
      },
      {
        'name': 'France',
        'emoji': '🇫🇷',
        'code': 'FR',
        'capital': 'Paris',
        'currency': 'EUR',
        'lat': 46.6034,
        'lng': 1.8883,
      },
      {
        'name': 'Italy',
        'emoji': '🇮🇹',
        'code': 'IT',
        'capital': 'Rome',
        'currency': 'EUR',
        'lat': 41.9028,
        'lng': 12.4964,
      },
    ];
  }

  static List<Map<String, dynamic>> getPlacesForCountry(String country) {
    final places = {
      'Sri Lanka': [
        {
          'id': '1',
          'name': 'Sigiriya Rock',
          'days': 1,
          'price': 5000,
          'image': '🏔️',
          'rating': 4.8,
          'lat': 7.9569,
          'lng': 80.7598,
          'desc': 'Ancient rock fortress',
        },
        {
          'id': '2',
          'name': 'Kandy Temple',
          'days': 1,
          'price': 3000,
          'image': '🛕',
          'rating': 4.9,
          'lat': 7.2936,
          'lng': 80.6336,
          'desc': 'Temple of Tooth',
        },
        {
          'id': '3',
          'name': 'Ella Gap',
          'days': 1,
          'price': 4000,
          'image': '🌄',
          'rating': 4.7,
          'lat': 6.8668,
          'lng': 81.0461,
          'desc': 'Mountain views',
        },
        {
          'id': '4',
          'name': 'Galle Fort',
          'days': 1,
          'price': 3500,
          'image': '🏰',
          'rating': 4.6,
          'lat': 6.0322,
          'lng': 80.2151,
          'desc': 'Dutch Fort',
        },
        {
          'id': '5',
          'name': 'Bentota Beach',
          'days': 1,
          'price': 6000,
          'image': '🏖️',
          'rating': 4.5,
          'lat': 6.4190,
          'lng': 80.0030,
          'desc': 'Beach paradise',
        },
      ],
      'India': [
        {
          'id': '1',
          'name': 'Taj Mahal',
          'days': 1,
          'price': 6000,
          'image': '🕌',
          'rating': 4.9,
          'lat': 27.1751,
          'lng': 78.0421,
          'desc': 'Iconic monument',
        },
        {
          'id': '2',
          'name': 'Goa Beach',
          'days': 2,
          'price': 7000,
          'image': '🏖️',
          'rating': 4.5,
          'lat': 15.2993,
          'lng': 74.1240,
          'desc': 'Beach parties',
        },
      ],
      'Thailand': [
        {
          'id': '1',
          'name': 'Phuket',
          'days': 2,
          'price': 8000,
          'image': '🏖️',
          'rating': 4.8,
          'lat': 7.8804,
          'lng': 98.3923,
          'desc': 'Beautiful beaches',
        },
        {
          'id': '2',
          'name': 'Bangkok',
          'days': 1,
          'price': 6000,
          'image': '🏙️',
          'rating': 4.6,
          'lat': 13.7367,
          'lng': 100.5231,
          'desc': 'Vibrant city',
        },
      ],
      'Maldives': [
        {
          'id': '1',
          'name': 'Malé',
          'days': 1,
          'price': 10000,
          'image': '🏙️',
          'rating': 4.3,
          'lat': 4.1755,
          'lng': 73.5093,
          'desc': 'Capital city',
        },
        {
          'id': '2',
          'name': 'Maafushi',
          'days': 2,
          'price': 15000,
          'image': '🏖️',
          'rating': 4.7,
          'lat': 3.9579,
          'lng': 73.4877,
          'desc': 'Local island',
        },
      ],
    };
    return places[country] ?? [];
  }

  static List<Map<String, dynamic>> getHotelsForLocation(String country) {
    final hotels = {
      'Sri Lanka': [
        {
          'id': 'h1',
          'name': 'Grand Plaza Hotel',
          'price': 8500,
          'rating': 4.7,
          'phone': '+94 112345678',
          'address': 'Colombo',
          'distance': '0.3 km',
          'image': '🏨',
          'amenities': ['Pool', 'WiFi', 'Restaurant'],
        },
        {
          'id': 'h2',
          'name': 'Sunset Resort',
          'price': 7200,
          'rating': 4.8,
          'phone': '+94 812345678',
          'address': 'Kandy',
          'distance': '0.7 km',
          'image': '🏨',
          'amenities': ['Beach View', 'WiFi'],
        },
        {
          'id': 'h3',
          'name': 'Sigiriya Lodge',
          'price': 5800,
          'rating': 4.5,
          'phone': '+94 572345678',
          'address': 'Sigiriya',
          'distance': '1.2 km',
          'image': '🏨',
          'amenities': ['Mountain View', 'WiFi'],
        },
      ],
      'India': [
        {
          'id': 'h1',
          'name': 'Taj Hotel',
          'price': 15000,
          'rating': 4.9,
          'phone': '+91 11234567',
          'address': 'Agra',
          'distance': '0.5 km',
          'image': '🏨',
          'amenities': ['Pool', 'Spa', 'Restaurant'],
        },
      ],
    };
    return hotels[country] ?? hotels['Sri Lanka']!;
  }

  static List<Map<String, dynamic>> filterCountries(String query) {
    final countries = getCountries();
    if (query.isEmpty) return countries;
    return countries
        .where(
          (c) =>
              c['name'].toLowerCase().contains(query.toLowerCase()) ||
              c['code'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

// ==================== MAP WIDGET ====================
class SimpleMapWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final String locationName;
  final List<Map<String, dynamic>> markers;
  final List<LatLng> routePoints;

  const SimpleMapWidget({
    super.key,
    required this.lat,
    required this.lng,
    required this.locationName,
    this.markers = const [],
    this.routePoints = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 7.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smart_travel_route_sl.app',
            ),
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: const Color(0xFF2D9C7C),
                    strokeWidth: 4,
                  ),
                ],
              ),
            if (markers.isNotEmpty)
              MarkerLayer(
                markers: markers
                    .map(
                      (m) => Marker(
                        point: LatLng(m['lat'], m['lng']),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D9C7C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${m['index']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== BUCKET PAGE ====================
class BucketPage extends StatefulWidget {
  const BucketPage({super.key});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  List<TripPlan> _trips = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  // Trip Wizard State
  List<Map<String, dynamic>> _countrySuggestions = [];
  final TextEditingController _searchController = TextEditingController();

  String _selectedCountry = '';
  String _selectedCountryFlag = '🇱🇰';
  double _selectedLat = 7.8731;
  double _selectedLng = 80.7718;

  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 33));
  int _travelers = 2;
  double _budget = 50000;

  List<Map<String, dynamic>> _availablePlaces = [];
  List<Map<String, dynamic>> _selectedPlaces = [];
  List<Map<String, dynamic>> _hotels = [];
  final List<Map<String, dynamic>> _nearbyPlaces = [];

  // Map
  List<Map<String, dynamic>> _mapMarkers = [];
  List<LatLng> _routePoints = [];

  final List<String> _filters = ['All', 'Upcoming', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadTrips() {
    setState(() {
      _trips = BucketService.getTrips();
      _isLoading = false;
    });
  }

  void _updateMapMarkers() {
    setState(() {
      _mapMarkers = [];
      _routePoints = [];
      for (int i = 0; i < _selectedPlaces.length; i++) {
        _mapMarkers.add({
          'lat': _selectedPlaces[i]['lat'],
          'lng': _selectedPlaces[i]['lng'],
          'index': i + 1,
        });
        _routePoints.add(
          LatLng(_selectedPlaces[i]['lat'], _selectedPlaces[i]['lng']),
        );
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _countrySuggestions = CountryHelper.filterCountries(query);
    });
  }

  void _selectCountry(Map<String, dynamic> country) {
    setState(() {
      _selectedCountry = country['name'];
      _selectedCountryFlag = country['emoji'];
      _selectedLat = country['lat'];
      _selectedLng = country['lng'];
      _searchController.text = country['name'];
      _countrySuggestions = [];
      _availablePlaces = CountryHelper.getPlacesForCountry(country['name']);
      _hotels = CountryHelper.getHotelsForLocation(country['name']);
      _selectedPlaces = [];
      _updateMapMarkers();
    });
  }

  void _togglePlace(Map<String, dynamic> place) {
    setState(() {
      if (_selectedPlaces.contains(place)) {
        _selectedPlaces.remove(place);
      } else {
        _selectedPlaces.add(place);
      }
      _updateMapMarkers();
    });
  }

  void _autoPlan() {
    setState(() {
      _selectedPlaces = [];
      final days = _endDate.difference(_startDate).inDays;
      final maxPlaces = days > _availablePlaces.length
          ? _availablePlaces.length
          : days;
      for (int i = 0; i < maxPlaces; i++) {
        _selectedPlaces.add(_availablePlaces[i]);
      }
      _updateMapMarkers();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Auto-planned places!'),
        backgroundColor: Color(0xFF2D9C7C),
      ),
    );
  }

  void _saveTrip() {
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one place'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final activitiesList = _selectedPlaces
        .map<String>((p) => p['name'] as String)
        .toList();
    final totalCost = _selectedPlaces.fold<double>(
      0.0,
      (sum, p) => sum + (p['price'] as double? ?? 0.0),
    );
    final days = _endDate.difference(_startDate).inDays;
    final daysCount = days > 0 ? days : 1;

    final newTrip = TripPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      destination: _selectedPlaces.map((p) => p['name'] as String).join(', '),
      country: _selectedCountry,
      countryFlag: _selectedCountryFlag,
      image: _selectedPlaces.first['image'] as String,
      startDate: _startDate,
      endDate: _endDate,
      travelers: _travelers,
      budget: totalCost + (5000 * _travelers * daysCount),
      accommodation: 'Hotel',
      transport: 'Flight',
      activities: activitiesList,
      notes: 'Planned via Trip Wizard',
      status: 'Planning',
      hotelName: _hotels.isNotEmpty ? _hotels.first['name'] : '',
      hotelPhone: _hotels.isNotEmpty ? _hotels.first['phone'] : '',
      hotelAddress: _hotels.isNotEmpty ? _hotels.first['address'] : '',
      selectedPlaces: List.from(_selectedPlaces),
      spentAmount: 0,
    );

    BucketService.addTrip(newTrip);
    _loadTrips();
    setState(() => _selectedTabIndex = 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Trip saved to $_selectedCountry!'),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
    );

    // Reset
    setState(() {
      _selectedPlaces = [];
      _selectedCountry = '';
      _searchController.clear();
      _availablePlaces = [];
      _hotels = [];
      _mapMarkers = [];
      _routePoints = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Travel Planner',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton('Trip Wizard', 1, Icons.auto_awesome),
                _buildTabButton('My Trips', 0, Icons.airplane_ticket),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTabIndex == 0 ? _buildMyTripsTab() : _buildTripWizard(),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2D9C7C) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTripsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airplane_ticket_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No trips planned yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap Trip Wizard to plan your next adventure',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTabIndex = 1),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Open Trip Wizard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9C7C),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      itemBuilder: (context, index) => _buildTripCard(_trips[index]),
    );
  }

  Widget _buildTripCard(TripPlan trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFF2D9C7C).withOpacity(0.1),
                  child: Center(
                    child: Text(
                      trip.image,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    Text(
                      trip.countryFlag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd').format(trip.endDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${trip.travelers}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LKR ${trip.budget.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D9C7C),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        BucketService.deleteTrip(trip.id);
                        _loadTrips();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripWizard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Country Search
          const Text(
            '🌍 1. Select Country',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '🔍 Type country name...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2D9C7C)),
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
                itemBuilder: (context, index) => ListTile(
                  leading: Text(
                    _countrySuggestions[index]['emoji'],
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    _countrySuggestions[index]['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_countrySuggestions[index]['capital']),
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF2D9C7C),
                  ),
                  onTap: () => _selectCountry(_countrySuggestions[index]),
                ),
              ),
            ),

          if (_selectedCountry.isNotEmpty) ...[
            const SizedBox(height: 24),

            // Step 2: Map View
            const Text(
              '🗺️ 2. Map View',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SimpleMapWidget(
              lat: _selectedLat,
              lng: _selectedLng,
              locationName: _selectedCountry,
              markers: _mapMarkers,
              routePoints: _routePoints,
            ),
            const SizedBox(height: 24),

            // Step 3: Trip Details
            const Text(
              '📋 3. Trip Details',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF2D9C7C),
                          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF2D9C7C),
                          ),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('👥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Color(0xFF2D9C7C),
                        ),
                        onPressed: () => setState(
                          () =>
                              _travelers = _travelers > 1 ? _travelers - 1 : 1,
                        ),
                      ),
                      Text(
                        '$_travelers',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF2D9C7C),
                        ),
                        onPressed: () => setState(() => _travelers++),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget (LKR)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    onChanged: (v) => _budget = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Step 4: Places to Visit
            const Text(
              '📍 4. Places to Visit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availablePlaces.map((place) {
                final isSelected = _selectedPlaces.contains(place);
                return GestureDetector(
                  onTap: () => _togglePlace(place),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2D9C7C)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2D9C7C)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place['image'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          place['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Auto Plan Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _autoPlan,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  'Auto Plan (${_endDate.difference(_startDate).inDays} days)',
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D9C7C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step 5: Hotels
            if (_hotels.isNotEmpty) ...[
              const Text(
                '🏨 5. Hotels Near You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._hotels.map(
                (hotel) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Text(
                        hotel['image'],
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '⭐ ${hotel['rating']} • ${hotel['distance']} • LKR ${hotel['price']}/night',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '📞 ${hotel['phone']}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2D9C7C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFF2D9C7C)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Step 6: Your Itinerary
            if (_selectedPlaces.isNotEmpty) ...[
              const Text(
                '📋 6. Your Itinerary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D9C7C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: _selectedPlaces
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2D9C7C),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value['days']} day(s)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTrip,
                icon: const Icon(Icons.save),
                label: const Text('Save Trip to My Trips'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D9C7C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}
