// lib/features/auth/explore_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/image_api_service.dart';

// ==================== DESTINATION MODEL ====================
class DestinationWithImages {
  final String id;
  final String name;
  final String location;
  final String country;
  final double rating;
  final double price;
  final String category;
  final String description;
  String imageUrl;
  List<String> galleryImages;

  DestinationWithImages({
    required this.id,
    required this.name,
    required this.location,
    required this.country,
    required this.rating,
    required this.price,
    required this.category,
    required this.description,
    this.imageUrl = '',
    this.galleryImages = const [],
  });
}

// ==================== HOTEL MODEL ====================
class HotelModel {
  final String id;
  final String name;
  final String location;
  final double price;
  final double rating;
  final String phone;
  final String address;
  final List<String> amenities;
  final String description;
  String imageUrl;
  List<String> galleryImages;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.phone,
    required this.address,
    required this.amenities,
    required this.description,
    this.imageUrl = '',
    this.galleryImages = const [],
  });
}

// ==================== EXPLORE SCREEN ====================
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<DestinationWithImages> _destinations = [];
  List<DestinationWithImages> _filteredDestinations = [];
  List<HotelModel> _hotels = [];
  List<Map<String, dynamic>> _searchSuggestions = [];

  bool _isLoading = true;
  bool _isLoadingHotels = true;
  bool _isLoadingSuggestions = false;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Beach',
    'Mountain',
    'City',
    'Historical',
    'Temple',
    'Cultural',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadDestinations(), _loadHotels()]);
  }

  // ==================== LOAD DESTINATIONS ====================
  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);

    final List<Map<String, dynamic>> baseDestinations = [
      {
        'id': '1',
        'name': 'Sigiriya Rock',
        'location': 'Sigiriya',
        'country': 'Sri Lanka',
        'category': 'Historical',
        'rating': 4.8,
        'price': 50,
        'description':
            'Ancient rock fortress and palace ruins with stunning views. A UNESCO World Heritage Site.',
      },
      {
        'id': '2',
        'name': 'Ella Gap',
        'location': 'Ella',
        'country': 'Sri Lanka',
        'category': 'Mountain',
        'rating': 4.7,
        'price': 40,
        'description':
            'Beautiful mountain views and amazing hiking trails. Famous for Nine Arch Bridge.',
      },
      {
        'id': '3',
        'name': 'Bentota Beach',
        'location': 'Bentota',
        'country': 'Sri Lanka',
        'category': 'Beach',
        'rating': 4.5,
        'price': 60,
        'description': 'Beautiful sandy beach with water sports activities.',
      },
      {
        'id': '4',
        'name': 'Galle Fort',
        'location': 'Galle',
        'country': 'Sri Lanka',
        'category': 'Historical',
        'rating': 4.6,
        'price': 35,
        'description': 'Dutch colonial fort by the sea with rich history.',
      },
      {
        'id': '5',
        'name': 'Temple of Tooth',
        'location': 'Kandy',
        'country': 'Sri Lanka',
        'category': 'Temple',
        'rating': 4.9,
        'price': 25,
        'description':
            'Sacred Buddhist temple housing the tooth relic of Buddha.',
      },
      {
        'id': '6',
        'name': 'Nuwara Eliya',
        'location': 'Nuwara Eliya',
        'country': 'Sri Lanka',
        'category': 'Mountain',
        'rating': 4.4,
        'price': 45,
        'description':
            '"Little England" with tea plantations and cool climate.',
      },
      {
        'id': '7',
        'name': 'Mirissa Beach',
        'location': 'Mirissa',
        'country': 'Sri Lanka',
        'category': 'Beach',
        'rating': 4.7,
        'price': 55,
        'description': 'Famous for whale watching and beautiful sunsets.',
      },
      {
        'id': '8',
        'name': 'Anuradhapura',
        'location': 'Anuradhapura',
        'country': 'Sri Lanka',
        'category': 'Historical',
        'rating': 4.6,
        'price': 30,
        'description': 'Ancient city with sacred Bodhi tree and ruins.',
      },
    ];

    List<DestinationWithImages> loadedDestinations = [];

    for (var dest in baseDestinations) {
      String imageUrl = await ImageApiService.getDestinationImage(
        dest['name'],
        dest['country'],
      );
      List<String> gallery = await ImageApiService.getDestinationGallery(
        dest['name'],
        dest['country'],
      );

      loadedDestinations.add(
        DestinationWithImages(
          id: dest['id'],
          name: dest['name'],
          location: dest['location'],
          country: dest['country'],
          rating: dest['rating'],
          price: dest['price'],
          category: dest['category'],
          description: dest['description'],
          imageUrl: imageUrl,
          galleryImages: gallery,
        ),
      );
    }

    setState(() {
      _destinations = loadedDestinations;
      _filteredDestinations = loadedDestinations;
      _isLoading = false;
    });
  }

  // ==================== LOAD HOTELS ====================
  Future<void> _loadHotels() async {
    setState(() => _isLoadingHotels = true);

    final List<Map<String, dynamic>> baseHotels = [
      {
        'id': 'h1',
        'name': 'Grand Plaza Hotel',
        'location': 'Colombo',
        'price': 8500,
        'rating': 4.5,
        'phone': '+94 112345678',
        'address': 'Colombo 01, Sri Lanka',
        'amenities': ['WiFi', 'Pool', 'Restaurant', 'Spa', 'Gym'],
        'description':
            'Luxury hotel in the heart of Colombo with modern amenities.',
      },
      {
        'id': 'h2',
        'name': 'Sunset Resort',
        'location': 'Bentota',
        'price': 6200,
        'rating': 4.3,
        'phone': '+94 342345678',
        'address': 'Bentota Beach, Sri Lanka',
        'amenities': ['Beach Access', 'WiFi', 'Spa', 'Restaurant', 'Pool'],
        'description': 'Beautiful beachfront resort with stunning ocean views.',
      },
      {
        'id': 'h3',
        'name': 'Sigiriya Lodge',
        'location': 'Sigiriya',
        'price': 5500,
        'rating': 4.7,
        'phone': '+94 662345678',
        'address': 'Sigiriya Road, Sri Lanka',
        'amenities': ['Pool', 'Restaurant', 'WiFi', 'Mountain View', 'Yoga'],
        'description':
            'Eco-friendly lodge with amazing views of Sigiriya Rock.',
      },
      {
        'id': 'h4',
        'name': 'Ella Retreat',
        'location': 'Ella',
        'price': 4800,
        'rating': 4.6,
        'phone': '+94 572345678',
        'address': 'Ella Gap, Sri Lanka',
        'amenities': [
          'Mountain View',
          'WiFi',
          'Restaurant',
          'Hiking',
          'Bonfire',
        ],
        'description': 'Cozy retreat in the misty mountains of Ella.',
      },
      {
        'id': 'h5',
        'name': 'Kandy City Hotel',
        'location': 'Kandy',
        'price': 7200,
        'rating': 4.8,
        'phone': '+94 812345678',
        'address': 'Kandy City Center, Sri Lanka',
        'amenities': ['WiFi', 'Restaurant', 'Gym', 'Rooftop Bar'],
        'description': 'Modern hotel near Temple of Tooth with city views.',
      },
      {
        'id': 'h6',
        'name': 'Galle Fort Inn',
        'location': 'Galle',
        'price': 5800,
        'rating': 4.4,
        'phone': '+94 912345678',
        'address': 'Galle Fort, Sri Lanka',
        'amenities': ['WiFi', 'Sea View', 'Restaurant', 'Heritage Building'],
        'description': 'Charming boutique hotel inside historic Galle Fort.',
      },
    ];

    List<HotelModel> loadedHotels = [];

    for (var hotel in baseHotels) {
      String imageUrl = await ImageApiService.getHotelImage(
        hotel['name'],
        hotel['location'],
      );
      List<String> gallery = await ImageApiService.getHotelGallery(
        hotel['name'],
        hotel['location'],
      );

      loadedHotels.add(
        HotelModel(
          id: hotel['id'],
          name: hotel['name'],
          location: hotel['location'],
          price: hotel['price'].toDouble(),
          rating: hotel['rating'],
          phone: hotel['phone'],
          address: hotel['address'],
          amenities: List<String>.from(hotel['amenities']),
          description: hotel['description'],
          imageUrl: imageUrl,
          galleryImages: gallery,
        ),
      );
    }

    setState(() {
      _hotels = loadedHotels;
      _isLoadingHotels = false;
    });
  }

  // ==================== SEARCH ====================
  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() => _searchSuggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final lowerQuery = query.toLowerCase();
    final destinationSuggestions = _destinations
        .where(
          (d) =>
              d.name.toLowerCase().contains(lowerQuery) ||
              d.location.toLowerCase().contains(lowerQuery),
        )
        .map(
          (d) => {
            'type': 'destination',
            'id': d.id,
            'name': d.name,
            'location': d.location,
            'rating': d.rating,
            'price': d.price,
            'imageUrl': d.imageUrl,
          },
        )
        .toList();

    final hotelSuggestions = _hotels
        .where(
          (h) =>
              h.name.toLowerCase().contains(lowerQuery) ||
              h.location.toLowerCase().contains(lowerQuery),
        )
        .map(
          (h) => {
            'type': 'hotel',
            'id': h.id,
            'name': h.name,
            'location': h.location,
            'rating': h.rating,
            'price': h.price,
            'imageUrl': h.imageUrl,
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
      final destination = _destinations.firstWhere(
        (d) => d.id == suggestion['id'],
      );
      _showDestinationDetails(destination);
    } else if (suggestion['type'] == 'hotel') {
      final hotel = _hotels.firstWhere((h) => h.id == suggestion['id']);
      _showHotelDetails(hotel);
    }
  }

  // ==================== SHOW DESTINATION DETAILS ====================
  void _showDestinationDetails(DestinationWithImages destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: destination.galleryImages.length + 1,
                itemBuilder: (context, index) {
                  final imageUrl = index == 0
                      ? destination.imageUrl
                      : destination.galleryImages[index - 1];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${destination.location}, ${destination.country}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${destination.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              destination.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price per person',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'LKR ${destination.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D9C7C),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.airplane_ticket),
                  label: const Text('Plan Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9C7C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  // ==================== SHOW HOTEL DETAILS ====================
  void _showHotelDetails(HotelModel hotel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: hotel.galleryImages.length + 1,
                itemBuilder: (context, index) {
                  final imageUrl = index == 0
                      ? hotel.imageUrl
                      : hotel.galleryImages[index - 1];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hotel.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Amenities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hotel.amenities
                  .map(
                    (a) => Chip(
                      label: Text(a),
                      backgroundColor: const Color(0xFF2D9C7C).withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              hotel.description,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Color(0xFF2D9C7C)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(hotel.phone)),
                  const Icon(Icons.location_on, color: Color(0xFF2D9C7C)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hotel.address,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price per night',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'LKR ${hotel.price}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D9C7C),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9C7C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredDestinations = category == 'All'
          ? _destinations
          : _destinations.where((d) => d.category == category).toList();
    });
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
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
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
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _searchSuggestions[index]['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        title: Text(
                          _searchSuggestions[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _searchSuggestions[index]['type'] == 'hotel'
                              ? '🏨 ${_searchSuggestions[index]['location']} • LKR ${_searchSuggestions[index]['price']}/night'
                              : '📍 ${_searchSuggestions[index]['location']} • ⭐ ${_searchSuggestions[index]['rating']}',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF2D9C7C),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) => FilterChip(
                label: Text(_categories[index]),
                selected: _selectedCategory == _categories[index],
                onSelected: (_) => _filterByCategory(_categories[index]),
                selectedColor: const Color(0xFF2D9C7C),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: _selectedCategory == _categories[index]
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),

          // Hotels Section
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

          _isLoadingHotels
              ? const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _hotels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () => _showHotelDetails(_hotels[index]),
                      child: Container(
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: _hotels[index].imageUrl,
                                height: 85,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  height: 85,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: 85,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hotels[index].name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _hotels[index].location,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 10,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text('${_hotels[index].rating}'),
                                      const Spacer(),
                                      Text(
                                        'LKR ${_hotels[index].price}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDestinations.isEmpty
                ? const Center(child: Text('No destinations found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (_, index) {
                      final destination = _filteredDestinations[index];
                      return GestureDetector(
                        onTap: () => _showDestinationDetails(destination),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: destination.imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${destination.rating}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      destination.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${destination.location}, ${destination.country}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2D9C7C,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Text(
                                            destination.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF2D9C7C),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'LKR ${destination.price}/person',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3498DB),
                                            fontSize: 16,
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
        ],
      ),
    );
  }
}
