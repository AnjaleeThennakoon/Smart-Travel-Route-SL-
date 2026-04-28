import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'bucket_page.dart';
import 'payment_details_page.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Route data
  List<LatLng> routePoints = [];
  String distance = "";
  String duration = "";
  bool isLoading = false;

  // Search
  List<Map<String, dynamic>> _searchSuggestions = [];
  Timer? _debounce;
  bool _isLoadingSuggestions = false;

  // Destinations
  List<Map<String, dynamic>> _allDestinations = [];
  List<Map<String, dynamic>> _filteredDestinations = [];
  bool _isLoadingDestinations = true;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Beach',
    'Mountain',
    'City',
    'Historical',
    'Temple',
  ];

  // Hotels
  List<Map<String, dynamic>> _hotels = [];
  bool _isLoadingHotels = false;
  String _selectedHotelId = '';

  // Selected destination for trip planning
  Map<String, dynamic>? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _loadHotels();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoadingDestinations = true);
    await Future.delayed(const Duration(milliseconds: 500));

    _allDestinations = [
      {
        'id': '1',
        'name': 'Sigiriya Rock',
        'location': 'Sigiriya',
        'country': 'Sri Lanka',
        'category': 'Historical',
        'rating': 4.8,
        'price': 50,
        'image': '🏔️',
        'description': 'Ancient rock fortress and palace ruins',
        'imageUrl': 'https://picsum.photos/400/200?random=1',
      },
      {
        'id': '2',
        'name': 'Ella Gap',
        'location': 'Ella',
        'country': 'Sri Lanka',
        'category': 'Mountain',
        'rating': 4.7,
        'price': 40,
        'image': '🌄',
        'description': 'Beautiful mountain views and hiking trails',
        'imageUrl': 'https://picsum.photos/400/200?random=2',
      },
      {
        'id': '3',
        'name': 'Bentota Beach',
        'location': 'Bentota',
        'country': 'Sri Lanka',
        'category': 'Beach',
        'rating': 4.5,
        'price': 60,
        'image': '🏖️',
        'description': 'Beautiful sandy beach with water sports',
        'imageUrl': 'https://picsum.photos/400/200?random=3',
      },
      {
        'id': '4',
        'name': 'Galle Fort',
        'location': 'Galle',
        'country': 'Sri Lanka',
        'category': 'Historical',
        'rating': 4.6,
        'price': 35,
        'image': '🏰',
        'description': 'Dutch colonial fort by the sea',
        'imageUrl': 'https://picsum.photos/400/200?random=4',
      },
      {
        'id': '5',
        'name': 'Kandy Temple',
        'location': 'Kandy',
        'country': 'Sri Lanka',
        'category': 'Temple',
        'rating': 4.9,
        'price': 25,
        'image': '🛕',
        'description': 'Temple of the Sacred Tooth Relic',
        'imageUrl': 'https://picsum.photos/400/200?random=5',
      },
      {
        'id': '6',
        'name': 'Nuwara Eliya',
        'location': 'Nuwara Eliya',
        'country': 'Sri Lanka',
        'category': 'Mountain',
        'rating': 4.4,
        'price': 45,
        'image': '⛰️',
        'description': 'Little England of Sri Lanka',
        'imageUrl': 'https://picsum.photos/400/200?random=6',
      },
    ];

    _filteredDestinations = _allDestinations;
    setState(() => _isLoadingDestinations = false);
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoadingHotels = true);
    await Future.delayed(const Duration(milliseconds: 300));

    _hotels = [
      {
        'id': 'h1',
        'name': 'Grand Plaza Hotel',
        'location': 'Colombo',
        'price': 8500,
        'rating': 4.5,
        'phone': '+94 112345678',
        'address': 'Colombo 01',
        'image': '🏨',
        'amenities': ['WiFi', 'Pool', 'Restaurant'],
      },
      {
        'id': 'h2',
        'name': 'Sunset Resort',
        'location': 'Bentota',
        'price': 6200,
        'rating': 4.3,
        'phone': '+94 342345678',
        'address': 'Bentota Beach',
        'image': '🏨',
        'amenities': ['Beach Access', 'WiFi', 'Spa'],
      },
      {
        'id': 'h3',
        'name': 'Sigiriya Lodge',
        'location': 'Sigiriya',
        'price': 5500,
        'rating': 4.7,
        'phone': '+94 662345678',
        'address': 'Sigiriya Road',
        'image': '🏨',
        'amenities': ['Pool', 'Restaurant', 'WiFi'],
      },
      {
        'id': 'h4',
        'name': 'Ella Retreat',
        'location': 'Ella',
        'price': 4800,
        'rating': 4.6,
        'phone': '+94 572345678',
        'address': 'Ella Gap',
        'image': '🏨',
        'amenities': ['Mountain View', 'WiFi'],
      },
      {
        'id': 'h5',
        'name': 'Kandy City Hotel',
        'location': 'Kandy',
        'price': 7200,
        'rating': 4.8,
        'phone': '+94 812345678',
        'address': 'Kandy City Center',
        'image': '🏨',
        'amenities': ['WiFi', 'Restaurant', 'Gym'],
      },
      {
        'id': 'h6',
        'name': 'Galle Fort Inn',
        'location': 'Galle',
        'price': 5800,
        'rating': 4.4,
        'phone': '+94 912345678',
        'address': 'Galle Fort',
        'image': '🏨',
        'amenities': ['WiFi', 'Sea View'],
      },
    ];

    setState(() => _isLoadingHotels = false);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _getSearchSuggestions(query);
      } else {
        setState(() => _searchSuggestions = []);
      }
    });
  }

  void _getSearchSuggestions(String query) {
    setState(() => _isLoadingSuggestions = true);

    final lowerQuery = query.toLowerCase();
    final destinationSuggestions = _allDestinations
        .where(
          (d) =>
              d['name'].toLowerCase().contains(lowerQuery) ||
              d['location'].toLowerCase().contains(lowerQuery),
        )
        .map(
          (d) => {
            'type': 'destination',
            'id': d['id'],
            'name': d['name'],
            'location': d['location'],
            'image': d['image'],
            'rating': d['rating'],
            'price': d['price'],
          },
        )
        .toList();

    final hotelSuggestions = _hotels
        .where(
          (h) =>
              h['name'].toLowerCase().contains(lowerQuery) ||
              h['location'].toLowerCase().contains(lowerQuery),
        )
        .map(
          (h) => {
            'type': 'hotel',
            'id': h['id'],
            'name': h['name'],
            'location': h['location'],
            'phone': h['phone'],
            'price': h['price'],
            'rating': h['rating'],
            'image': h['image'],
            'amenities': h['amenities'],
          },
        )
        .toList();

    setState(() {
      _searchSuggestions = [...destinationSuggestions, ...hotelSuggestions];
      _isLoadingSuggestions = false;
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    _searchController.text = suggestion['name'];
    setState(() => _searchSuggestions = []);

    if (suggestion['type'] == 'destination') {
      _filterDestinations(suggestion['name']);
      _showDestinationDetails(suggestion);
    } else if (suggestion['type'] == 'hotel') {
      _showHotelDetails(suggestion);
    }
  }

  void _filterDestinations(String query) {
    setState(() {
      _filteredDestinations = _allDestinations
          .where(
            (d) =>
                d['name'].toLowerCase().contains(query.toLowerCase()) ||
                d['location'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _showDestinationDetails(Map<String, dynamic> destination) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  destination['image'],
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${destination['location']}, ${destination['country']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${destination['rating']} • ${destination['category']}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'LKR ${destination['price']}/person',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _planTripFromDestination(destination);
                },
                icon: const Icon(Icons.airplane_ticket),
                label: const Text('Plan a Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D9C7C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHotelDetails(Map<String, dynamic> hotel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(hotel['image'], style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hotel['location'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${hotel['rating']}'),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(hotel['phone']),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'LKR ${hotel['price']}/night',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2D9C7C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${hotel['address']}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'Amenities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: (hotel['amenities'] as List)
                  .map(
                    (a) =>
                        Chip(label: Text(a), backgroundColor: Colors.grey[100]),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Call hotel
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 1. දැනට විවෘතව ඇති Modal Bottom Sheet එක වසන්න
                      Navigator.pop(context);

                      // 2. PaymentDetailsPage වෙත දත්ත සමඟ ගමන් කරන්න
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentDetailsPage(
                            // හෝටලයේ මිල String එකක් නම් එය double එකකට convert කිරීම මෙහිදී වැදගත් වේ
                            amount:
                                double.tryParse(hotel['price'].toString()) ??
                                0.0,
                            hotelName: hotel['name'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.airplane_ticket,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Book Now',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D9C7C),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _planTripFromDestination(Map<String, dynamic> destination) {
    _selectedDestination = destination;
    _selectedHotelId = '';
    _showCreateTripDialog();
  }

  void _planTripWithHotel(Map<String, dynamic> hotel) {
    _selectedHotelId = hotel['id'];
    _selectedDestination = null;
    _showCreateTripDialog();
  }

  void _showCreateTripDialog() {
    final destinationCtrl = TextEditingController(
      text: _selectedDestination != null ? _selectedDestination!['name'] : '',
    );
    final locationCtrl = TextEditingController(
      text: _selectedDestination != null
          ? _selectedDestination!['location']
          : '',
    );

    DateTime startDate = DateTime.now().add(const Duration(days: 30));
    DateTime endDate = DateTime.now().add(const Duration(days: 37));
    int travelers = 2;
    double budget = 50000;
    String selectedTransport = 'Flight';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✈️ Plan Your Trip',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: destinationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (picked != null) {
                                  setStateModal(() => startDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${startDate.day}/${startDate.month}/${startDate.year}',
                                    ),
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
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: startDate.add(
                                    const Duration(days: 30),
                                  ),
                                );
                                if (picked != null) {
                                  setStateModal(() => endDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${endDate.day}/${endDate.month}/${endDate.year}',
                                    ),
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
                            child: DropdownButtonFormField<int>(
                              initialValue: travelers,
                              decoration: const InputDecoration(
                                labelText: 'Travelers',
                                border: OutlineInputBorder(),
                              ),
                              items: [1, 2, 3, 4, 5, 6]
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        '$t ${t == 1 ? 'person' : 'persons'}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setStateModal(() => travelers = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: budget.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Budget (LKR)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) =>
                                  budget = double.tryParse(v) ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedTransport,
                        decoration: const InputDecoration(
                          labelText: 'Transport',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Flight', 'Train', 'Bus', 'Car']
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setStateModal(() => selectedTransport = v!),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedHotelId.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D9C7C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.hotel, color: Color(0xFF2D9C7C)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hotel selected: ${_hotels.firstWhere((h) => h['id'] == _selectedHotelId)['name']}',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Get hotel name safely
                        String hotelName = '';
                        String hotelPhone = '';
                        String hotelAddress = '';

                        if (_selectedHotelId.isNotEmpty) {
                          try {
                            final hotel = _hotels.firstWhere(
                              (h) => h['id'] == _selectedHotelId,
                            );
                            hotelName = hotel['name'];
                            hotelPhone = hotel['phone'];
                            hotelAddress = hotel['address'];
                          } catch (e) {
                            // Hotel not found
                          }
                        }

                        final newTrip = TripPlan(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          destination: destinationCtrl.text,
                          country:
                              _selectedDestination?['country'] ?? 'Sri Lanka',
                          countryFlag: '🇱🇰',
                          image: _selectedDestination?['image'] ?? '✈️',
                          startDate: startDate,
                          endDate: endDate,
                          travelers: travelers,
                          budget: budget,
                          accommodation: 'Hotel',
                          transport: selectedTransport,
                          activities: ['Sightseeing'],
                          notes: '',
                          status: 'Planning',
                          hotelName: hotelName,
                          hotelPhone: hotelPhone,
                          hotelAddress: hotelAddress,
                        );

                        BucketService.addTrip(newTrip);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Trip added to your Bucket List!'),
                            backgroundColor: Color(0xFF2D9C7C),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D9C7C),
                      ),
                      child: const Text('Save Trip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D9C7C),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus search field
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '🔍 Search destinations, hotels...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF2D9C7C),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchSuggestions = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                if (_isLoadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: Text(
                          _searchSuggestions[index]['image'],
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(_searchSuggestions[index]['name']),
                        subtitle: Text(
                          _searchSuggestions[index]['type'] == 'hotel'
                              ? '🏨 ${_searchSuggestions[index]['location']} • LKR ${_searchSuggestions[index]['price']}/night'
                              : '📍 ${_searchSuggestions[index]['location']} • LKR ${_searchSuggestions[index]['price']}/person',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            Text(' ${_searchSuggestions[index]['rating']}'),
                          ],
                        ),
                        onTap: () =>
                            _selectSuggestion(_searchSuggestions[index]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Categories
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => FilterChip(
                label: Text(_categories[index]),
                selected: _selectedCategory == _categories[index],
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = _categories[index];
                    if (_selectedCategory == 'All') {
                      _filteredDestinations = _allDestinations;
                    } else {
                      _filteredDestinations = _allDestinations
                          .where((d) => d['category'] == _selectedCategory)
                          .toList();
                    }
                  });
                },
                selectedColor: const Color(0xFF2D9C7C).withOpacity(0.2),
              ),
            ),
          ),
          // Hotels Section - FIXED OVERFLOW ISSUE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.hotel, color: Color(0xFF2D9C7C)),
                const SizedBox(width: 8),
                const Text(
                  'Recommended Hotels',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(color: Color(0xFF3498DB)),
                  ),
                ),
              ],
            ),
          ),
          // Fixed Hotel List with proper sizing
          SizedBox(
            height: 110, // Fixed height to prevent overflow
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _hotels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () => _showHotelDetails(_hotels[index]),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(8), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Minimize height
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hotels[index]['image'],
                        style: const TextStyle(fontSize: 28), // Reduced size
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      Text(
                        _hotels[index]['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11, // Reduced font size
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _hotels[index]['location'],
                        style: const TextStyle(
                          fontSize: 9, // Reduced font size
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10, // Reduced icon size
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${_hotels[index]['rating']}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const Spacer(),
                          Text(
                            'LKR ${_hotels[index]['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9, // Reduced font size
                              color: Color(0xFF2D9C7C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Destinations Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF3498DB)),
                const SizedBox(width: 8),
                const Text(
                  'Popular Destinations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingDestinations
                ? const Center(child: CircularProgressIndicator())
                : _filteredDestinations.isEmpty
                ? const Center(child: Text('No destinations found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (_, index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              _filteredDestinations[index]['imageUrl'],
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 160,
                                color: const Color(0xFF2D9C7C).withOpacity(0.1),
                                child: Center(
                                  child: Text(
                                    _filteredDestinations[index]['image'],
                                    style: const TextStyle(fontSize: 50),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _filteredDestinations[index]['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_filteredDestinations[index]['rating']}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_filteredDestinations[index]['location']}, ${_filteredDestinations[index]['country']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'LKR ${_filteredDestinations[index]['price']}/person',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3498DB),
                                        fontSize: 14,
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _planTripFromDestination(
                                        _filteredDestinations[index],
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF2D9C7C),
                                        ),
                                      ),
                                      child: const Text(
                                        'Plan Trip',
                                        style: TextStyle(fontSize: 12),
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
                  ),
          ),
        ],
      ),
    );
  }
}
