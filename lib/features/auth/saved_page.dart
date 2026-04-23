import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'home_page.dart'; // ⭐ HomePage import කරන්න

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Map<String, dynamic>> _savedDestinations = [];
  bool _isLoading = true;

  // Edit mode variables
  bool _isEditMode = false;
  final List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDestinations();
  }

  void _loadSavedDestinations() {
    setState(() {
      _savedDestinations = ApiService.getSavedDestinations();
      _isLoading = false;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;

    setState(() {
      _savedDestinations.removeWhere((d) => _selectedIds.contains(d['id']));
      for (var id in _selectedIds) {
        final destination = ApiService.getSavedDestinations().firstWhere(
          (d) => d['id'] == id,
          orElse: () => {},
        );
        if (destination.isNotEmpty) {
          ApiService.toggleSaveDestination(destination);
        }
      }
      _selectedIds.clear();
      _isEditMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected places removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _deleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All'),
        content: const Text(
          'Are you sure you want to remove all saved places?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedDestinations.clear();
                ApiService.clearAllSavedDestinations();
                _isEditMode = false;
                _selectedIds.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All saved places removed'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromSaved(int index) {
    setState(() {
      final destination = _savedDestinations[index];
      ApiService.toggleSaveDestination(destination);
      _savedDestinations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from saved places'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ⭐⭐⭐⭐⭐ Home Page එකට යන method එක (මෙතන එකතු කරන්න) ⭐⭐⭐⭐⭐
  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }
  // ⭐⭐⭐⭐⭐ ⭐⭐⭐⭐⭐ ⭐⭐⭐⭐⭐

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Select Places' : 'Saved Places',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _isEditMode ? Icons.close : Icons.arrow_back,
            color: Color(0xFF2C3E50),
          ),
          onPressed: () {
            if (_isEditMode) {
              _toggleEditMode();
            } else {
              _goToHome(); // ⭐⭐⭐⭐⭐ මෙතන call කරන්න ⭐⭐⭐⭐⭐
            }
          },
        ),
        actions: [
          if (_savedDestinations.isNotEmpty)
            _isEditMode
                ? Row(
                    children: [
                      if (_selectedIds.isNotEmpty)
                        TextButton.icon(
                          onPressed: _deleteSelected,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Delete (${_selectedIds.length})',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextButton(
                        onPressed: _toggleEditMode,
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      TextButton.icon(
                        onPressed: _toggleEditMode,
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        onPressed: _deleteAll,
                        icon: const Icon(Icons.delete_sweep, size: 20),
                        label: const Text('Delete All'),
                      ),
                    ],
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedDestinations.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_savedDestinations.length} destinations saved',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _savedDestinations.length,
                    itemBuilder: (context, index) {
                      final destination = _savedDestinations[index];
                      return _buildSavedCard(destination, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No saved places yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon to save places you love',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goToHome, // ⭐⭐⭐⭐⭐ මෙතනත් call කරන්න ⭐⭐⭐⭐⭐
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(Map<String, dynamic> destination, int index) {
    final isSelected = _selectedIds.contains(destination['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isEditMode)
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(destination['id']),
              activeColor: Colors.blue,
            ),
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Image.network(
              destination['imageUrl'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        destination['country'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            destination['rating'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'LKR ${destination['price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!_isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeFromSaved(index),
              ),
            ),
        ],
      ),
    );
  }
}
