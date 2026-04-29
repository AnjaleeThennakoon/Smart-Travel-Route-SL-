import 'package:auboo_travel/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import 'explore_screen.dart';
import 'saved_page.dart';
import 'bucket_page.dart'; // ✅ hide BucketPage ඉවත් කරන්න

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _userName = 'Traveler';

  final List<Widget> _pages = [
    const HomeBody(),
    const ExploreScreen(),
    const BucketPage(), // ✅ දැන් හරියට වැඩ කරයි
    const SavedPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadDestinations();
  }

  void _loadUserName() {
    setState(() {
      _userName = ApiService.getUserName();
    });
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);
    final destinations = await ApiService.getDestinationsByCategory(
      _selectedCategory,
    );
    setState(() {
      _destinations = destinations;
      _isLoading = false;
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await ApiService.searchPlaces(query);
    setState(() => _searchResults = results);
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    final destinations = await ApiService.getDestinationsByCategory(category);
    setState(() {
      _destinations = destinations;
      _isLoading = false;
    });
  }

  void _showEmergencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Emergency Help",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmergencyTile(
              Icons.local_police,
              "Police (Sri Lanka)",
              "119",
              Colors.blue,
            ),
            _buildEmergencyTile(
              Icons.medical_services,
              "Ambulance / Suwa Seriya",
              "1990",
              Colors.green,
            ),
            _buildEmergencyTile(
              Icons.local_fire_department,
              "Fire & Rescue",
              "110",
              Colors.orange,
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildLocationSearchBtn(
                    Icons.local_hospital,
                    "Near Hospital",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLocationSearchBtn(Icons.security, "Near Police"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTile(
    IconData icon,
    String title,
    String number,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        number,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {},
      ),
    );
  }

  Widget _buildLocationSearchBtn(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentIndex == 0 ? _buildHomeContent() : _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildEmergencyBar(),
            _buildSearchBar(),
            _buildBookingShortcuts(),
            _buildCategories(),
            _buildSectionTitle(),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _searchController.text.isEmpty
                ? _buildDestinationsList()
                : _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hey, ',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_userName.toUpperCase()} 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Text(
                'Colombo, Sri Lanka',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.black87,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF3498DB),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: GestureDetector(
        onTap: _showEmergencySheet,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            children: [
              const Icon(Icons.emergency_share, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                "Emergency Help & Numbers",
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _searchPlaces,
          decoration: const InputDecoration(
            hintText: 'Find things you interested in',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.black54),
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingShortcuts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Book Now",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShortcutIcon(
                Icons.map_outlined,
                "Trip",
                () => setState(() => _currentIndex = 2),
              ),
              _buildShortcutIcon(Icons.flight, "Flight", () {}),
              _buildShortcutIcon(
                Icons.hotel,
                "Hotel",
                () => setState(() => _currentIndex = 1),
              ),
              _buildShortcutIcon(Icons.train, "Train", () {}),
              _buildShortcutIcon(Icons.directions_bus, "Bus", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ApiService.getCategories();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text(
            "Categories",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 25),
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () => _filterByCategory(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDFFF00) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Popular Trips',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _currentIndex = 1),
            child: const Text('See all', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsList() {
    if (_destinations.isEmpty) {
      return const Center(child: Text('No destinations found'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: _destinations.length,
      itemBuilder: (context, index) =>
          _buildDestinationCard(_destinations[index]),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) =>
          _buildDestinationCard(_searchResults[index]),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination) {
    final isSaved = ApiService.isDestinationSaved(destination['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(destination['imageUrl']),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 18,
                ),
                onPressed: () => setState(
                  () => ApiService.toggleSaveDestination(destination),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'LKR ${destination['price']}/person',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(
                        " ${destination['rating']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.explore_outlined, 1),
          _buildNavItem(Icons.favorite_outline, 2),
          _buildNavItem(Icons.bookmark_outline, 3),
          _buildNavItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.grey,
        size: 28,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
