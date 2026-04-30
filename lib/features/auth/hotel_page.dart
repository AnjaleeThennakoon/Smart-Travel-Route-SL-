import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../models/hotel_model.dart';
import '../../services/api_service.dart';

const String _orsApiKey =
    'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjVkMGNkOTE1NjQ5MzQ1MjZhMzRlNmM4YmUyMzFkNzc5IiwiaCI6Im11cm11cjY0In0=';

class HotelPage extends StatefulWidget {
  final List<LatLng>? routeWaypoints;
  final String? routeLabel;

  const HotelPage({super.key, this.routeWaypoints, this.routeLabel});

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> {
  final MapController _mapController = MapController();
  final List<Hotel> _allHotels = [];
  List<Hotel> _hotels = [];
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _error = '';
  String _warning = '';

  @override
  void initState() {
    super.initState();
    _loadHotels();
    if (widget.routeWaypoints != null && widget.routeWaypoints!.length >= 2) {
      _loadRoute();
    }
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _warning = '';
    });

    try {
      final hotels = await ApiService.getAllHotels();
      if (!mounted) return;
      _allHotels.clear();
      _allHotels.addAll(hotels);
      _applyHotelFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load hotels: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoute() async {
    try {
      final coordinates = widget.routeWaypoints!
          .map((p) => [p.longitude, p.latitude])
          .toList();
      final uri = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
      );
      final res = await http.post(
        uri,
        headers: {
          'Authorization': _orsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'coordinates': coordinates}),
      );
      if (res.statusCode != 200) {
        throw Exception('Could not fetch route (${res.statusCode}).');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>;
      if (features.isEmpty) {
        throw Exception('No route returned for selected waypoints.');
      }
      final geometry =
          (features.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>;
      final rawCoords = geometry['coordinates'] as List<dynamic>;
      final points = rawCoords.map((item) {
        final pair = item as List<dynamic>;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();

      if (!mounted) return;
      setState(() {
        _routePoints = points;
      });
      if (_allHotels.isNotEmpty) {
        _applyHotelFilter();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _warning = 'Unable to load route geometry: $e';
      });
    }
  }

  void _applyHotelFilter() {
    final route = _routePoints.isNotEmpty
        ? _routePoints
        : widget.routeWaypoints ?? [];

    if (route.length >= 2) {
      final nearby = _allHotels.where((hotel) {
        return _distanceToRouteKm(
              LatLng(hotel.latitude, hotel.longitude),
              route,
            ) <=
            5.0;
      }).toList();

      if (nearby.isNotEmpty) {
        _hotels = nearby;
      } else {
        _hotels = List<Hotel>.from(_allHotels);
        _warning =
            'No hotels found within 5 km of the selected route. Showing all hotels.';
      }
    } else {
      _hotels = List<Hotel>.from(_allHotels);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _distanceToRouteKm(LatLng point, List<LatLng> route) {
    if (route.length < 2) return _distanceKm(point, route.first);

    var minDistance = double.infinity;
    for (var index = 0; index < route.length - 1; index++) {
      minDistance = math.min(
        minDistance,
        _distancePointToSegmentKm(point, route[index], route[index + 1]),
      );
    }

    return minDistance;
  }

  double _distancePointToSegmentKm(LatLng p, LatLng a, LatLng b) {
    final ax = a.longitude;
    final ay = a.latitude;
    final bx = b.longitude;
    final by = b.latitude;
    final px = p.longitude;
    final py = p.latitude;
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) return _distanceKm(p, a);

    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    final cx = (t < 0)
        ? ax
        : (t > 1)
        ? bx
        : ax + t * dx;
    final cy = (t < 0)
        ? ay
        : (t > 1)
        ? by
        : ay + t * dy;
    return _distanceKm(p, LatLng(cy, cx));
  }

  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final aa =
        sinDLat * sinDLat +
        math.cos(_degToRad(a.latitude)) *
            math.cos(_degToRad(b.latitude)) *
            sinDLng *
            sinDLng;
    final c = 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
    return r * c;
  }

  double _degToRad(double d) => d * 3.141592653589793 / 180;

  Future<void> _showHotelDetailsDialog(Hotel hotel) async {
    double averageRating = 0.0;
    int? userRating;
    int ratingCount = 0;

    try {
      averageRating = await ApiService.getHotelAverageRating(hotel.hotelId);
      userRating = await ApiService.getUserHotelRating(hotel.hotelId);
      ratingCount = await ApiService.getHotelRatingCount(hotel.hotelId);
    } catch (e) {
      debugPrint('Error loading ratings: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            hotel.hotelName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hotel.photos != null && hotel.photos!.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(hotel.photos!.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Description:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(hotel.description ?? 'No description available'),
                const SizedBox(height: 8),
                if (hotel.contactNumber != null &&
                    hotel.contactNumber!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(hotel.contactNumber!),
                      const SizedBox(height: 8),
                    ],
                  ),
                if (hotel.pricePerNight != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price per night:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text('\$${hotel.pricePerNight!.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                    ],
                  ),
                Text(
                  'Rating:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: averageRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      ignoreGestures: true,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {},
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${averageRating.toStringAsFixed(1)} ($ratingCount reviews)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Rating:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                RatingBar.builder(
                  initialRating: userRating?.toDouble() ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 30,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) async {
                    try {
                      await ApiService.submitHotelRating(
                        hotel.hotelId,
                        rating.toInt(),
                      );
                      final newAverage = await ApiService.getHotelAverageRating(
                        hotel.hotelId,
                      );
                      final newCount = await ApiService.getHotelRatingCount(
                        hotel.hotelId,
                      );
                      setState(() {
                        averageRating = newAverage;
                        userRating = rating.toInt();
                        ratingCount = newCount;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rating submitted successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit rating: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _routePoints.isNotEmpty
        ? _routePoints
        : widget.routeWaypoints ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hotels',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3498DB),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _hotels.isEmpty
          ? const Center(child: Text('No hotels available yet.'))
          : Column(
              children: [
                if (routePoints.length >= 2)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8F4FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      widget.routeLabel != null
                          ? 'Hotels near route: ${widget.routeLabel}'
                          : 'Hotels near selected route',
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_warning.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF3CD),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      _warning,
                      style: const TextStyle(
                        color: Color(0xFF856404),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: routePoints.isNotEmpty
                          ? routePoints.first
                          : LatLng(
                              _hotels.first.latitude,
                              _hotels.first.longitude,
                            ),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.auboo_travel',
                      ),
                      if (routePoints.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 4,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: _hotels.map((hotel) {
                          return Marker(
                            width: 80,
                            height: 80,
                            point: LatLng(hotel.latitude, hotel.longitude),
                            child: GestureDetector(
                              onTap: () => _showHotelDetailsDialog(hotel),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 36,
                                    color: Colors.purple,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromRGBO(
                                            0,
                                            0,
                                            0,
                                            0.15,
                                          ),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      hotel.hotelName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hotels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final hotel = _hotels[index];
                      return ListTile(
                        onTap: () => _showHotelDetailsDialog(hotel),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: Colors.white,
                        leading: const Icon(Icons.hotel, color: Colors.purple),
                        title: Text(
                          hotel.hotelName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.description ?? 'No description',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hotel.contactNumber != null &&
                                hotel.contactNumber!.isNotEmpty)
                              Text(
                                'Contact: ${hotel.contactNumber}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Text(
                          hotel.pricePerNight != null
                              ? '\$${hotel.pricePerNight!.toStringAsFixed(0)}'
                              : '',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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
