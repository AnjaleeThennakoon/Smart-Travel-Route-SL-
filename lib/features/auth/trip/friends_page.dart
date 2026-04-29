import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> _allFriends = [];
  List<Map<String, dynamic>> _selectedFriends = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    _allFriends = [
      {'id': '1', 'name': 'Sarah Johnson', 'avatar': '👩', 'rating': 4.8},
      {'id': '2', 'name': 'Mike Chen', 'avatar': '👨', 'rating': 4.9},
      {'id': '3', 'name': 'Emma Watson', 'avatar': '👩', 'rating': 4.7},
      {'id': '4', 'name': 'Alex Kumar', 'avatar': '👨', 'rating': 4.6},
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends to Trip'),
        backgroundColor: const Color(0xFF2D9C7C),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedFriends),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allFriends.length,
              itemBuilder: (context, index) {
                final friend = _allFriends[index];
                final isSelected = _selectedFriends.contains(friend);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected!) {
                        _selectedFriends.add(friend);
                      } else {
                        _selectedFriends.remove(friend);
                      }
                    });
                  },
                  title: Text(friend['name']),
                  subtitle: Text('⭐ ${friend['rating']}'),
                  secondary: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(child: Text(friend['avatar'])),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showProfile(friend),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProfile(Map<String, dynamic> friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(friend['avatar'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Text(
              friend['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(' ${friend['rating']}'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.message),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9C7C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
