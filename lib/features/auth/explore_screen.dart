import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config/app_config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final MapController _mapController = MapController();

  List<LatLng> routePoints = [];
  String distance = "";
  String duration = "";
  bool isLoading = false;

  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isOriginSearching = true;

  // --- නව විශේෂාංගය: Current Location ලබාගැනීම ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // GPS සක්‍රීයදැයි බැලීම
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("කරුණාකර GPS සක්‍රීය කරන්න.");
      return;
    }

    // අවසර පරීක්ෂා කිරීම
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("ස්ථානය ලබා ගැනීමට අවසර ලබා දී නොමැත.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        "අවසර ස්ථිරවම ප්‍රතික්ෂේප කර ඇත. Settings හරහා එය නිවැරදි කරන්න.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse Geocoding: Lat/Long වලින් ලිපිනය සෙවීම
      final apiKey = AppConfig.orsApiKey;
      final url =
          'https://api.openrouteservice.org/geocode/reverse?api_key=$apiKey&point=${position.longitude},${position.latitude}&size=1';

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['features'].isNotEmpty) {
          final String address = data['features'][0]['properties']['label'];
          setState(() {
            _originController.text = address;
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              14.0,
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      _showSnackBar("ඔබේ ස්ථානය හඳුනා ගැනීමට නොහැකි විය.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
  // ------------------------------------------

  void _onSearchChanged(String query, bool isOrigin) {
    _isOriginSearching = isOrigin;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _getSuggestions(query);
      } else {
        setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _getSuggestions(String query) async {
    final apiKey = AppConfig.orsApiKey;
    final url =
        'https://api.openrouteservice.org/geocode/autocomplete?api_key=$apiKey&text=$query&size=5';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = data['features'];
        });
      }
    } catch (e) {
      debugPrint("Autocomplete Error: $e");
    }
  }

  Future<void> calculateRoute() async {
    setState(() {
      isLoading = true;
      routePoints = [];
      _suggestions = [];
    });

    final apiKey = AppConfig.orsApiKey;

    try {
      final startRes = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/geocode/search?api_key=$apiKey&text=${_originController.text}&size=1',
        ),
      );
      final startCoords = json.decode(
        startRes.body,
      )['features'][0]['geometry']['coordinates'];

      final endRes = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/geocode/search?api_key=$apiKey&text=${_destController.text}&size=1',
        ),
      );
      final endCoords = json.decode(
        endRes.body,
      )['features'][0]['geometry']['coordinates'];

      final routeRes = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${startCoords[0]},${startCoords[1]}&end=${endCoords[0]},${endCoords[1]}',
        ),
      );

      if (routeRes.statusCode == 200) {
        final data = json.decode(routeRes.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];
        final summary = data['features'][0]['properties']['summary'];

        setState(() {
          routePoints = coords
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          distance = "${(summary['distance'] / 1000).toStringAsFixed(2)} km";
          duration = "${(summary['duration'] / 60).toStringAsFixed(0)} mins";

          if (routePoints.isNotEmpty) {
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(routePoints),
                padding: const EdgeInsets.all(50.0),
              ),
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar("ගමන් මාර්ගය සොයා ගැනීමට නොහැකි විය.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Trip"),
        backgroundColor: const Color(0xFF3498DB),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  onChanged: (value) => _onSearchChanged(value, true),
                  decoration: InputDecoration(
                    labelText: "From",
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                    ),
                    // GPS Button එක මෙතැනට
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.gps_fixed, color: Colors.blue),
                      onPressed: _getCurrentLocation,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destController,
                  onChanged: (value) => _onSearchChanged(value, false),
                  decoration: InputDecoration(
                    labelText: "To",
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                if (_suggestions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final label =
                            _suggestions[index]['properties']['label'];
                        return ListTile(
                          title: Text(
                            label,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            setState(() {
                              if (_isOriginSearching) {
                                _originController.text = label;
                              } else {
                                _destController.text = label;
                              }
                              _suggestions = [];
                            });
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : calculateRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Show Route Info",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(6.9271, 79.8612),
                    initialZoom: 9.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smart_travel_route_sl.app',
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blueAccent,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                    if (routePoints.isNotEmpty)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: routePoints.first,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 35,
                            ),
                          ),
                          Marker(
                            point: routePoints.last,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (distance.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              "Distance",
                              distance,
                              Icons.directions_car,
                            ),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(thickness: 1),
                            ),
                            _buildInfoItem("Duration", duration, Icons.timer),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
