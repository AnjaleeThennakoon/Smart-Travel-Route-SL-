import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wishlist එකට අදාළ දත්ත
    final List<Map<String, String>> wishlistItems = [
      {
        "name": "Sigiriya Rock",
        "location": "Matale, Sri Lanka",
        "rating": "4.9",
        "image": "https://picsum.photos/id/1022/400/400"
      },
      {
        "name": "Mirissa Beach",
        "location": "Matara, Sri Lanka",
        "rating": "4.7",
        "image": "https://picsum.photos/id/1025/400/400"
      },
      {
        "name": "Nine Arch Bridge",
        "location": "Ella, Sri Lanka",
        "rating": "4.8",
        "image": "https://picsum.photos/id/1039/400/400"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: wishlistItems.isEmpty 
        ? _buildEmptyState() 
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              return _buildWishlistItem(wishlistItems[index]);
            },
          ),
    );
  }

  Widget _buildWishlistItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item['image']!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item['location']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              Text(item['rating']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 10),
          const Icon(Icons.favorite, color: Colors.red, size: 24), // Wishlist නිසා රතු පාට හදවතක්
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("Your wishlist is empty!", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}