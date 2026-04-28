import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auboo_travel/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_page.dart';
import 'explore_screen.dart';
import 'add_page.dart';
import 'saved_page.dart';
import 'bucket_page.dart';
import 'trip_tracker_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _curr = 0;
  String _cat = 'All', _user = 'Traveler';
  List<Map<String, dynamic>> _dest = [], _search = [];
  bool _loading = true;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = ApiService.getUserName();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getDestinationsByCategory(_cat);
    setState(() {
      _dest = data;
      _loading = false;
    });
  }

  void _showSheet(Widget child) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => child,
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      const SizedBox.shrink(),
      const ExploreScreen(),
      const AddPage(),
      const BucketPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: _curr == 0
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _header(),
                    _weatherCard(),
                    _emerBar(),
                    _searchBar(),
                    _booking(),
                    _categories(),
                    _title(),
                    _loading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _list(),
                  ],
                ),
              ),
            )
          : pages[_curr],
      bottomNavigationBar: _nav(),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.all(25),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Hey, ', style: GoogleFonts.poppins(fontSize: 18)),
                Text(
                  '${_user.toUpperCase()} 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
        GestureDetector(
          onTap: () => setState(() => _curr = 4),
          child: const CircleAvatar(
            backgroundColor: Color(0xFF3498DB),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _weatherCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getWeather("Colombo"),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        var temp = snapshot.data!['main']['temp'].round();
        var condition = snapshot.data!['weather'][0]['main'];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Weather",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "Colombo, SL",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    _getWeatherIcon(condition),
                    color: Colors.white,
                    size: 35,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$temp°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.contains("Cloud")) return Icons.cloud;
    if (condition.contains("Rain")) return Icons.beach_access;
    return Icons.wb_sunny;
  }

  Widget _emerBar() => GestureDetector(
    onTap: () => _showSheet(const EmergencySheetContent()),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_share,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            "Emergency Help",
            style: GoogleFonts.poppins(
              color: Colors.red.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red.shade300),
        ],
      ),
    ),
  );

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.all(25),
    child: TextField(
      controller: _ctrl,
      onChanged: (q) async {
        final r = q.isEmpty
            ? <Map<String, dynamic>>[]
            : await ApiService.searchPlaces(q);
        setState(() => _search = r);
      },
      decoration: InputDecoration(
        hintText: 'Find destinations...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget _booking() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _shortcut(
          Icons.map,
          "Trip",
          Colors.orange,
          () => setState(() => _curr = 1),
        ),
        _shortcut(
          Icons.flight_takeoff,
          "Flight",
          Colors.blue,
          () => _showSheet(const FlightSearchSheet()),
        ),
        _shortcut(
          Icons.hotel,
          "Hotel",
          Colors.purple,
          () => setState(() => _curr = 1),
        ),
        _shortcut(
          Icons.local_taxi,
          "Vehicle",
          Colors.green,
          () => _showSheet(const VehicleSearchSheet()),
        ),
      ],
    ),
  );

  Widget _shortcut(IconData i, String l, Color c, VoidCallback t) =>
      GestureDetector(
        onTap: t,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(i, size: 28, color: c),
            ),
            const SizedBox(height: 8),
            Text(
              l,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _categories() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
        child: Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 25),
          children: ApiService.getCategories()
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => _cat = c);
                    _load();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: _cat == c
                          ? const Color(0xFFDFFF00)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        c,
                        style: TextStyle(
                          fontWeight: _cat == c
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );

  Widget _title() => Padding(
    padding: const EdgeInsets.all(25),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Popular Trips',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => setState(() => _curr = 1),
          child: const Text('See all'),
        ),
      ],
    ),
  );

  Widget _list() {
    final l = _ctrl.text.isEmpty ? _dest : _search;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: l.length,
      itemBuilder: (c, i) => _card(l[i]),
    );
  }

  Widget _card(Map<String, dynamic> d) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    height: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      image: DecorationImage(
        image: NetworkImage(d['imageUrl']),
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
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                    d['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'LKR ${d['price']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      " ${d['rating']}",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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

  Widget _nav() => BottomNavigationBar(
    currentIndex: _curr,
    onTap: (i) => setState(() => _curr = i),
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.black,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.explore), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
    ],
  );
}

// --- FLIGHT SEARCH ---
class FlightSearchSheet extends StatelessWidget {
  const FlightSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final flights = [
      {
        'airline': 'SriLankan',
        'from': 'CMB',
        'to': 'MLE',
        'price': '45,000',
        'time': '1h 15m',
      },
      {
        'airline': 'Emirates',
        'from': 'CMB',
        'to': 'DXB',
        'price': '125,000',
        'time': '4h 30m',
      },
      {
        'airline': 'Indigo',
        'from': 'CMB',
        'to': 'MAA',
        'price': '32,000',
        'time': '1h 05m',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Available Flights",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...flights.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.airplanemode_active,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${f['airline']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${f['from']} ➔ ${f['to']} (${f['time']})",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "LKR ${f['price']}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- VEHICLE SEARCH (Updated with Fair Pricing & Live Tracking) ---
class VehicleSearchSheet extends StatelessWidget {
  const VehicleSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      {
        'name': 'Tuk-Tuk',
        'icon': Icons.electric_rickshaw,
        'rate': 80.0,
        'desc': 'Best for city tours - No hidden costs',
      },
      {
        'name': 'Budget Car',
        'icon': Icons.directions_car,
        'rate': 120.0,
        'desc': 'AC Sedan - Verified drivers only',
      },
      {
        'name': 'Luxury Van',
        'icon': Icons.airport_shuttle,
        'rate': 180.0,
        'desc': 'Ideal for groups - All fuel included',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Fair Price Vehicle Hire",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Verified",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Transparent rates. No price traps for tourists. Live tracking enabled for safety.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ...vehicles.map(
            (v) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    v['icon'] as IconData,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  v['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  v['desc'] as String,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "LKR ${v['rate']}/km",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Fair Rate",
                      style: TextStyle(fontSize: 9, color: Colors.green),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context); // Bottom sheet එක වසා දැමීමට
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripTrackerPage(
                        vehicleName: v['name'] as String,
                        ratePerKm: (v['rate'] as num)
                            .toDouble(), // ratePerKm මෙහිදී ලබා දෙන්න
                        baseFee:
                            0.0, // දැනට baseFee එක 0.0 ලෙස හෝ v['fee'] ලෙස ලබා දෙන්න
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- EMERGENCY SHEET ---
class EmergencySheetContent extends StatelessWidget {
  const EmergencySheetContent({super.key});
  Future<void> _makeCall(String n) async {
    final u = Uri.parse('tel:$n');
    if (await canLaunchUrl(u)) await launchUrl(u);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(25),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 40, height: 4, color: Colors.grey[300]),
        const SizedBox(height: 25),
        _tile(Icons.local_police, "Police", "119", Colors.blue),
        const SizedBox(height: 12),
        _tile(Icons.medical_services, "Ambulance", "1990", Colors.green),
        const SizedBox(height: 12),
        _tile(Icons.local_fire_department, "Fire", "110", Colors.orange),
        const SizedBox(height: 30),
      ],
    ),
  );
  Widget _tile(IconData i, String t, String n, Color c) => InkWell(
    onTap: () => _makeCall(n),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: c.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: c,
            child: Icon(i, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(n, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}
