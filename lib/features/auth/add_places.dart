import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auboo_travel/services/api_service.dart';

class AddPlacesPage extends StatefulWidget {
  const AddPlacesPage({super.key});

  @override
  State<AddPlacesPage> createState() => _AddPlacesPageState();
}

class _AddPlacesPageState extends State<AddPlacesPage> {
  LatLng? _currentLocation;
  bool _permissionDenied = false;
  final List<PlaceMarker> _markers = [];
  final List<String> _categories = [
    'Hotels',
    'Restaurants',
    'Gas Stations',
    'Visiting Places',
    'Other',
  ];
  final List<String> _quickCategoryFilters = [
    'All',
    'Hotels',
    'Restaurants',
    'Gas Stations',
    'Visiting Places',
    'Other',
  ];
  String _selectedQuickCategory = 'All';
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  List<PlaceMarker> _nearbyCategoryMarkers = [];
  List<PlaceMarker> _savedPlaceMarkers = [];
  List<PlaceMarker> _savedVisitingPlaceMarkers = [];
  bool _isLoadingNearbyCategory = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await locationFromAddress(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location not found: $e')));
    }
  }

  Future<void> _goToLocation(Location location) async {
    final newLocation = LatLng(location.latitude, location.longitude);
    _mapController.move(newLocation, 14);
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _loadNearbyForCategory(String category) async {
    if (_currentLocation == null) {
      setState(() => _nearbyCategoryMarkers = []);
      return;
    }

    final mapCenter = _mapController.camera.center;
    final center = (mapCenter.latitude == 0 && mapCenter.longitude == 0)
        ? _currentLocation!
        : mapCenter;
    setState(() => _isLoadingNearbyCategory = true);
    try {
      final places = await ApiService.searchNearbyPlacesByCategory(
        category: category,
        latitude: center.latitude,
        longitude: center.longitude,
      );

      final markers = places
          .where(
            (p) =>
                (p['latitude'] as double) != 0 &&
                (p['longitude'] as double) != 0,
          )
          .map(
            (p) => PlaceMarker(
              location: LatLng(
                p['latitude'] as double,
                p['longitude'] as double,
              ),
              category: category,
              label: (p['name'] ?? category).toString(),
              isSuggested: true,
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() => _nearbyCategoryMarkers = markers);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load $category: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoadingNearbyCategory = false);
      }
    }
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _permissionDenied = true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _permissionDenied = true);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      await _loadSavedPlaces();
      await _loadSavedVisitingPlaces();
      _loadNearbyForCategory(_selectedQuickCategory);
    } catch (_) {
      setState(() => _permissionDenied = true);
    }
  }

  Future<void> _loadSavedPlaces() async {
    try {
      final hotels = await ApiService.getAllHotels();
      debugPrint('Loaded ${hotels.length} saved hotels');
      if (!mounted) return;
      setState(() {
        _savedPlaceMarkers = hotels
            .map(
              (hotel) => PlaceMarker(
                location: LatLng(hotel.latitude, hotel.longitude),
                category: 'Hotels',
                label: hotel.hotelName,
                isSuggested: false,
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Failed to load saved hotels: $e');
      // Ignore loading failures for saved markers.
    }
  }

  Future<void> _loadSavedVisitingPlaces() async {
    try {
      final visitingPlaces = await ApiService.getAllVisitingPlaces();
      debugPrint('Loaded ${visitingPlaces.length} saved visiting places');
      if (!mounted) return;
      setState(() {
        _savedVisitingPlaceMarkers = visitingPlaces
            .map(
              (place) => PlaceMarker(
                location: LatLng(place.latitude, place.longitude),
                category: 'Visiting Places',
                label: place.name,
                isSuggested: false,
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Failed to load saved visiting places: $e');
      // Ignore loading failures for saved markers.
    }
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng latlng) {
    final defaultCategory = _selectedQuickCategory == 'All'
        ? 'Other'
        : _selectedQuickCategory;
    final newMarker = PlaceMarker(location: latlng, category: defaultCategory);
    setState(() => _markers.add(newMarker));
    _showCategoryMenu(newMarker);
  }

  Future<void> _showCategoryMenu(PlaceMarker marker) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._categories.map(
                (category) => ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(category),
                  onTap: () => Navigator.pop(context, category),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) {
      setState(() => _markers.remove(marker));
      return;
    }

    if (selected == 'Hotels') {
      setState(() => marker.category = selected);
      final saved = await _showHotelDetailsForm(marker);
      if (!saved) {
        setState(() => _markers.remove(marker));
      }
      return;
    }

    if (selected == 'Visiting Places') {
      setState(() => marker.category = selected);
      final saved = await _showVisitingPlaceDetailsForm(marker);
      if (!saved) {
        setState(() => _markers.remove(marker));
      }
      return;
    }

    setState(() => marker.category = selected);
  }

  Future<bool> _showHotelDetailsForm(PlaceMarker marker) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactController = TextEditingController();
    final priceController = TextEditingController();
    var saving = false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hotel details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Hotel name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price for one night',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final hotelName = nameController.text.trim();
                                  final description = descriptionController.text
                                      .trim();
                                  final contact = contactController.text.trim();
                                  final priceText = priceController.text.trim();
                                  final price = double.tryParse(priceText);

                                  if (hotelName.isEmpty ||
                                      price == null ||
                                      price <= 0) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a hotel name and valid price.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => saving = true);
                                  try {
                                    await ApiService.saveHotelForCurrentUser(
                                      hotelName: hotelName,
                                      description: description.isEmpty
                                          ? null
                                          : description,
                                      contactNumber: contact.isEmpty
                                          ? null
                                          : contact,
                                      pricePerNight: price,
                                      latitude: marker.location.latitude,
                                      longitude: marker.location.longitude,
                                    );
                                    if (!mounted) return;
                                    setState(() => marker.label = hotelName);
                                    await _loadSavedPlaces();
                                    if (!mounted) return;
                                    Navigator.pop(context, true);
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Hotel saved.'),
                                      ),
                                    );
                                  } catch (e, st) {
                                    debugPrint('Hotel save failed: $e\n$st');
                                    setModalState(() => saving = false);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to save hotel: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save hotel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result == true;
  }

  Future<bool> _showVisitingPlaceDetailsForm(PlaceMarker marker) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var saving = false;
    List<String> selectedPhotoUrls = [];
    final imagePicker = ImagePicker();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visiting place details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Place name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Photos (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  final XFile? image = await imagePicker
                                      .pickImage(source: ImageSource.camera);
                                  if (image != null) {
                                    setModalState(
                                      () => selectedPhotoUrls.add(image.path),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  final XFile? image = await imagePicker
                                      .pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setModalState(
                                      () => selectedPhotoUrls.add(image.path),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedPhotoUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Selected photos:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedPhotoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(selectedPhotoUrls[index]),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(
                                        () => selectedPhotoUrls.removeAt(index),
                                      );
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final placeName = nameController.text.trim();

                                  if (placeName.isEmpty) {
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a place name.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => saving = true);
                                  try {
                                    // First, save the visiting place without photos
                                    final savedPlace =
                                        await ApiService.saveVisitingPlaceForCurrentUser(
                                          name: placeName,
                                          description:
                                              descriptionController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : descriptionController.text
                                                    .trim(),
                                          photos:
                                              null, // We'll update this after uploading
                                          latitude: marker.location.latitude,
                                          longitude: marker.location.longitude,
                                        );

                                    // Upload photos if any were selected
                                    List<String>? uploadedPhotoUrls;
                                    if (selectedPhotoUrls.isNotEmpty) {
                                      uploadedPhotoUrls = [];
                                      for (final photoPath
                                          in selectedPhotoUrls) {
                                        try {
                                          final url =
                                              await ApiService.uploadVisitingPlacePhoto(
                                                savedPlace.visitingPlaceId,
                                                photoPath,
                                              );
                                          uploadedPhotoUrls.add(url);
                                        } catch (e) {
                                          debugPrint(
                                            'Failed to upload photo: $e',
                                          );
                                        }
                                      }

                                      // Update the place with photo URLs
                                      if (uploadedPhotoUrls.isNotEmpty) {
                                        await ApiService.updateVisitingPlacePhotos(
                                          savedPlace.visitingPlaceId,
                                          uploadedPhotoUrls,
                                        );
                                      }
                                    }

                                    if (!mounted) return;
                                    setState(() => marker.label = placeName);
                                    await _loadSavedVisitingPlaces();
                                    if (!mounted) return;
                                    Navigator.pop(context, true);
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Visiting place saved.'),
                                      ),
                                    );
                                  } catch (e, st) {
                                    debugPrint(
                                      'Visiting place save failed: $e\n$st',
                                    );
                                    setModalState(() => saving = false);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to save visiting place: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save place'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result == true;
  }

  Color _colorForCategory(String category) {
    return switch (category) {
      'Hotels' => Colors.deepPurple,
      'Restaurants' => Colors.redAccent,
      'Gas Stations' => Colors.green,
      'Visiting Places' => Colors.teal,
      'Other' => Colors.orange,
      _ => Colors.blueGrey,
    };
  }

  void _showPlaceDetails(PlaceMarker marker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    marker.label ?? marker.category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Category: ${marker.category}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Latitude: ${marker.location.latitude.toStringAsFixed(6)}'),
              Text(
                'Longitude: ${marker.location.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Close')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceMarker(PlaceMarker marker, IconData icon) {
    return GestureDetector(
      onTap: () => _showPlaceDetails(marker),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _colorForCategory(marker.category), size: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              marker.label ?? marker.category,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _currentLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Places'),
        backgroundColor: const Color(0xFF3498DB),
      ),
      body: _permissionDenied
          ? _buildPermissionDenied()
          : currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _searchLocation,
                        decoration: InputDecoration(
                          hintText: 'Search city or location',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                  '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}',
                                ),
                                onTap: () => _goToLocation(result),
                              );
                            },
                          ),
                        ),
                      if (_isSearching)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: 30,
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[600]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Long press on the map to add a place marker.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'After long press, choose a category for the marker.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation,
                      initialZoom: 14,
                      onLongPress: _onMapLongPress,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.auboo_travel',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60,
                            height: 60,
                            point: _currentLocation!,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          ..._markers.map(
                            (marker) => Marker(
                              width: 80,
                              height: 80,
                              point: marker.location,
                              child: _buildPlaceMarker(
                                marker,
                                Icons.location_on,
                              ),
                            ),
                          ),
                          ..._savedPlaceMarkers.map(
                            (marker) => Marker(
                              width: 80,
                              height: 80,
                              point: marker.location,
                              child: _buildPlaceMarker(marker, Icons.hotel),
                            ),
                          ),
                          ..._savedVisitingPlaceMarkers.map(
                            (marker) => Marker(
                              width: 80,
                              height: 80,
                              point: marker.location,
                              child: _buildPlaceMarker(marker, Icons.place),
                            ),
                          ),
                          ..._nearbyCategoryMarkers.map(
                            (marker) => Marker(
                              width: 80,
                              height: 80,
                              point: marker.location,
                              child: _buildPlaceMarker(marker, Icons.place),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickCategoryFilters.map((category) {
                        final isSelected = _selectedQuickCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedQuickCategory = category);
                              _loadNearbyForCategory(category);
                            },
                            selectedColor: const Color(0xFF3498DB),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF3498DB)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_markers.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Markers',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _markers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final marker = _markers[index];
                              return Container(
                                width: 180,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.grey[100],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      marker.category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat ${marker.location.latitude.toStringAsFixed(4)}',
                                    ),
                                    Text(
                                      'Lng ${marker.location.longitude.toStringAsFixed(4)}',
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
                if (_isLoadingNearbyCategory)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Location permission is required to show your current location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
              ),
              child: const Text('Retry permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceMarker {
  final LatLng location;
  String category;
  String? label;
  final bool isSuggested;

  PlaceMarker({
    required this.location,
    required this.category,
    this.label,
    this.isSuggested = false,
  });
}
