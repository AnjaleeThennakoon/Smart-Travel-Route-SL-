import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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
              onTap: (_, __) {
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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

  const _AddedPlacesSheet({
    required this.places,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
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
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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
