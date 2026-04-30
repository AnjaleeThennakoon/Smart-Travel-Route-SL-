import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../models/trip_model.dart';
import '../../services/api_service.dart';
import 'hotel_page.dart';

// ─── CONFIG ──────────────────────────────────────────────────────────────────
const String _orsApiKey =
    'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjVkMGNkOTE1NjQ5MzQ1MjZhMzRlNmM4YmUyMzFkNzc5IiwiaCI6Im11cm11cjY0In0='; // ← replace with your key

// ─── DATA MODEL ──────────────────────────────────────────────────────────────
class Place {
  final String name;
  final String address;
  final LatLng latLng;

  const Place({
    required this.name,
    required this.address,
    required this.latLng,
  });
}

List<Place> _nearestNeighborOrder(List<Place> source) {
  if (source.length <= 2) return List<Place>.from(source);
  final remaining = List<Place>.from(source);
  final ordered = <Place>[remaining.removeAt(0)];

  while (remaining.isNotEmpty) {
    final current = ordered.last;
    remaining.sort((a, b) {
      final da = _distanceKm(current.latLng, a.latLng);
      final db = _distanceKm(current.latLng, b.latLng);
      return da.compareTo(db);
    });
    ordered.add(remaining.removeAt(0));
  }

  return ordered;
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

// ─── MAIN ENTRY ──────────────────────────────────────────────────────────────
void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Place Finder',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}

// ─── MAP PAGE ─────────────────────────────────────────────────────────────────
class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) => const MapPage();
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  // Map
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(6.9271, 79.8612); // Colombo default

  // Search
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Place> _suggestions = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Added places
  final List<Place> _addedPlaces = [];
  final List<Marker> _markers = [];

  // Bottom sheet animation
  late final AnimationController _sheetAnim;
  late final Animation<double> _sheetSlide;
  bool _sheetOpen = false;

  // Filter chips
  final List<String> _filters = [
    'Mountain',
    'Beach',
    'Temples',
    'Nature pools',
    'Old',
  ];
  final Set<String> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _sheetAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _sheetSlide = CurvedAnimation(
      parent: _sheetAnim,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    _sheetAnim.dispose();
    super.dispose();
  }

  // ── ORS Geocode search ──────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final uri = Uri.parse(
        'https://api.openrouteservice.org/geocode/search'
        '?api_key=$_orsApiKey'
        '&text=${Uri.encodeComponent(query)}'
        '&size=6',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final features = json['features'] as List<dynamic>;
        setState(() {
          _suggestions = features.map((f) {
            final props = f['properties'] as Map<String, dynamic>;
            final coords = f['geometry']['coordinates'] as List<dynamic>;
            return Place(
              name: props['name'] ?? props['label'] ?? 'Unknown',
              address: props['label'] ?? '',
              latLng: LatLng(
                (coords[1] as num).toDouble(),
                (coords[0] as num).toDouble(),
              ),
            );
          }).toList();
        });
      }
    } catch (_) {
      // silently fail
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(v));
  }

  // ── Add / remove place ──────────────────────────────────────────────────────
  void _addPlace(Place place) {
    if (_addedPlaces.any((p) => p.latLng == place.latLng)) return;

    setState(() {
      _addedPlaces.add(place);
      _markers.add(
        Marker(
          point: place.latLng,
          width: 48,
          height: 48,
          child: _PlaceMarker(label: place.name),
        ),
      );
      _center = place.latLng;
      _suggestions = [];
      _searchCtrl.clear();
      _searchFocus.unfocus();
    });

    _mapController.move(place.latLng, 14);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.name} added'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removePlace(int index) {
    setState(() {
      _markers.removeAt(index);
      _addedPlaces.removeAt(index);
    });
  }

  // ── Bottom sheet toggle ─────────────────────────────────────────────────────
  void _toggleSheet() {
    setState(() => _sheetOpen = !_sheetOpen);
    _sheetOpen ? _sheetAnim.forward() : _sheetAnim.reverse();
  }

  void _openShortestPathPage() {
    if (_addedPlaces.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least 2 places to show a path.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ShortestPathPage(places: List<Place>.from(_addedPlaces)),
      ),
    );
  }

  void _openHotelsPage() {
    if (_addedPlaces.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least 2 places to find hotels along the route.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ordered = _nearestNeighborOrder(_addedPlaces);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelPage(
          routeWaypoints: ordered.map((p) => p.latLng).toList(),
          routeLabel: '${ordered.first.name} → ${ordered.last.name}',
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── MAP ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13,
              onTap: (_, _) {
                _searchFocus.unfocus();
                setState(() => _suggestions = []);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.placefinder',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // ── TOP BAR ────────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  isSearching: _isSearching,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _suggestions = []);
                  },
                ),

                // Suggestions dropdown
                if (_suggestions.isNotEmpty)
                  _SuggestionList(places: _suggestions, onSelect: _addPlace),
              ],
            ),
          ),

          // ── FILTER CHIPS ───────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: _sheetOpen ? 280 : 80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: _FilterChips(
                filters: _filters,
                active: _activeFilters,
                onToggle: (f) => setState(() {
                  _activeFilters.contains(f)
                      ? _activeFilters.remove(f)
                      : _activeFilters.add(f);
                }),
              ),
            ),
          ),

          // ── BOTTOM SHEET (Added Places) ────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle button
                GestureDetector(
                  onTap: _toggleSheet,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    width: 56,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedRotation(
                      turns: _sheetOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Sheet body
                SizeTransition(
                  sizeFactor: _sheetSlide,
                  axisAlignment: -1,
                  child: _AddedPlacesSheet(
                    places: _addedPlaces,
                    onRemove: _removePlace,
                    onTap: (p) => _mapController.move(p.latLng, 15),
                    onShowPath: _openShortestPathPage,
                    onShowHotels: _openHotelsPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TOP SEARCH BAR ───────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _TopBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Back button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),

          // Search field
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Search here...',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (isSearching)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2,
                      ),
                    )
                  else if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Filter icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUGGESTION LIST ──────────────────────────────────────────────────────────
class _SuggestionList extends StatelessWidget {
  final List<Place> places;
  final ValueChanged<Place> onSelect;

  const _SuggestionList({required this.places, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: places.map((p) {
            return InkWell(
              onTap: () => onSelect(p),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF1565C0),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (p.address.isNotEmpty)
                            Text(
                              p.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF1565C0),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── FILTER CHIPS ─────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final Set<String> active;
  final ValueChanged<String> onToggle;

  const _FilterChips({
    required this.filters,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isActive = active.contains(f);
          return GestureDetector(
            onTap: () => onToggle(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1565C0)
                    : Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF1565C0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── ADDED PLACES SHEET ───────────────────────────────────────────────────────
class _AddedPlacesSheet extends StatelessWidget {
  final List<Place> places;
  final ValueChanged<int> onRemove;
  final ValueChanged<Place> onTap;
  final VoidCallback onShowPath;
  final VoidCallback onShowHotels;

  const _AddedPlacesSheet({
    required this.places,
    required this.onRemove,
    required this.onTap,
    required this.onShowPath,
    required this.onShowHotels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'added Places',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  places.isEmpty
                      ? 'mekata report eka hadanna patan gannavada'
                      : '${places.length} place${places.length == 1 ? '' : 's'} added',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // List
          if (places.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search and add places above',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shrinkWrap: true,
                itemCount: places.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = places[i];
                  return GestureDetector(
                    onTap: () => onTap(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.address.isNotEmpty)
                                  Text(
                                    p.address,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onRemove(i),
                            child: Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: places.length >= 2 ? onShowPath : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.route_rounded),
                label: const Text(
                  'Show Path',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: places.length >= 2 ? onShowHotels : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.hotel_rounded),
                label: const Text(
                  'Hotels Along Route',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShortestPathPage extends StatefulWidget {
  final List<Place> places;

  const ShortestPathPage({super.key, required this.places});

  @override
  State<ShortestPathPage> createState() => _ShortestPathPageState();
}

class _ShortestPathPageState extends State<ShortestPathPage> {
  final MapController _mapController = MapController();
  List<Place> _orderedPlaces = [];
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String? _error;
  String _distance = '';
  String _duration = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final ordered = _nearestNeighborOrder(widget.places);
    setState(() {
      _orderedPlaces = ordered;
      _routePoints = ordered.map((p) => p.latLng).toList();
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
      );
      final coordinates = ordered
          .map((p) => [p.latLng.longitude, p.latLng.latitude])
          .toList();
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
        throw Exception('No route returned for selected places.');
      }

      final feature = features.first as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final rawCoords = geometry['coordinates'] as List<dynamic>;
      final summary =
          (feature['properties'] as Map<String, dynamic>)['summary']
              as Map<String, dynamic>;

      final points = rawCoords.map((item) {
        final pair = item as List<dynamic>;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();

      setState(() {
        _routePoints = points;
        _distance = _formatDistance(summary['distance']);
        _duration = _formatDuration(summary['duration']);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _routePoints.isEmpty) return;
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_routePoints),
            padding: const EdgeInsets.all(32),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Place> _nearestNeighborOrder(List<Place> source) {
    if (source.length <= 2) return List<Place>.from(source);
    final remaining = List<Place>.from(source);
    final ordered = <Place>[remaining.removeAt(0)];
    while (remaining.isNotEmpty) {
      final current = ordered.last;
      remaining.sort((a, b) {
        final da = _distanceKm(current.latLng, a.latLng);
        final db = _distanceKm(current.latLng, b.latLng);
        return da.compareTo(db);
      });
      ordered.add(remaining.removeAt(0));
    }
    return ordered;
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

  String _formatDistance(dynamic value) {
    final meters = (value as num?)?.toDouble() ?? 0;
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(dynamic value) {
    final seconds = (value as num?)?.toDouble() ?? 0;
    final minutes = (seconds / 60).round();
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '${h}h ${m}m';
    }
    return '$minutes min';
  }

  double _parseDistanceKm(String value) {
    final match = RegExp(r'([\d.]+)').firstMatch(value);
    final number = double.tryParse(match?.group(1) ?? '') ?? 0;
    if (value.toLowerCase().contains(' m') &&
        !value.toLowerCase().contains('km')) {
      return number / 1000;
    }
    return number;
  }

  int _parseDurationMinutes(String value) {
    final lower = value.toLowerCase();
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(lower);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(lower);
    if (hMatch != null || mMatch != null) {
      final h = int.tryParse(hMatch?.group(1) ?? '') ?? 0;
      final m = int.tryParse(mMatch?.group(1) ?? '') ?? 0;
      return (h * 60) + m;
    }
    final minMatch = RegExp(r'(\d+)').firstMatch(lower);
    return int.tryParse(minMatch?.group(1) ?? '') ?? 0;
  }

  Future<void> _saveRouteToMyTrips() async {
    if (_orderedPlaces.length < 2 || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final title =
          '${_orderedPlaces.first.name} to ${_orderedPlaces.last.name} Route';
      final location = _orderedPlaces.map((p) => p.name).join(' → ');
      final tripPlaces = _orderedPlaces.asMap().entries.map((entry) {
        final p = entry.value;
        return TripPlace(
          tripPlaceId: '',
          tripId: '',
          placeName: p.name,
          latitude: p.latLng.latitude,
          longitude: p.latLng.longitude,
          visitOrder: entry.key + 1,
          distanceFromPrevious: 0,
          durationFromPrevious: 0,
        );
      }).toList();

      await ApiService.saveTripForCurrentUser(
        tripName: title,
        startLocation: location,
        totalDistance: _parseDistanceKm(_distance),
        totalDuration: _parseDurationMinutes(_duration),
        description: 'Route with ${_orderedPlaces.length} stops',
        places: tripPlaces,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route saved to My Trips.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save trip: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shortest Path')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _orderedPlaces.isNotEmpty
                    ? _orderedPlaces.first.latLng
                    : const LatLng(6.9271, 79.8612),
                initialZoom: 11,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.placefinder',
                ),
                if (_routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _orderedPlaces.asMap().entries.map((entry) {
                    return Marker(
                      point: entry.value.latLng,
                      width: 36,
                      height: 36,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF1565C0),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: _isLoading
                ? const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Calculating shortest path...'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_error != null)
                        Text(_error!, style: const TextStyle(color: Colors.red))
                      else
                        Text(
                          'Distance: $_distance   •   Duration: $_duration',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _orderedPlaces.map((p) => p.name).join('  →  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading || _error != null || _isSaving
                              ? null
                              : _saveRouteToMyTrips,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(_isSaving ? 'Saving...' : 'Save Route'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
}

// ─── MAP MARKER ───────────────────────────────────────────────────────────────
class _PlaceMarker extends StatelessWidget {
  final String label;

  const _PlaceMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CustomPaint(size: const Size(10, 6), painter: _TrianglePainter()),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1565C0);
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
