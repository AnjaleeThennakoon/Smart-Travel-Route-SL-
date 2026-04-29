import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  List<Map<String, dynamic>> stops = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stops (Like Uber)'),
        backgroundColor: const Color(0xFF2D9C7C),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, stops),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map preview
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(6.9271, 79.8612),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (stops.isNotEmpty)
                  MarkerLayer(
                    markers: stops.asMap().entries.map((entry) {
                      return Marker(
                        point: LatLng(
                          entry.value['lat'] ?? 6.9271,
                          entry.value['lng'] ?? 79.8612,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D9C7C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_location),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      setState(() {
                        stops.add({
                          'name': _searchController.text,
                          'lat': 6.9271 + (stops.length * 0.01),
                          'lng': 79.8612 + (stops.length * 0.01),
                        });
                        _searchController.clear();
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = stops.removeAt(oldIndex);
                  stops.insert(newIndex, item);
                });
              },
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return ListTile(
                  key: ValueKey(stop),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(stop['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => stops.removeAt(index)),
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
