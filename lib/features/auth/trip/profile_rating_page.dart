import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileRatingPage extends StatefulWidget {
  const ProfileRatingPage({super.key, required this.userId});

  final String userId;

  @override
  State<ProfileRatingPage> createState() => _ProfileRatingPageState();
}

class _ProfileRatingPageState extends State<ProfileRatingPage> {
  double _rating = 0;
  String _review = '';
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviews = [
      {
        'user': 'Sarah',
        'rating': 5,
        'comment': 'Great travel buddy!',
        'date': '2025-01-15',
      },
      {
        'user': 'Mike',
        'rating': 4,
        'comment': 'Punctual and friendly.',
        'date': '2025-01-10',
      },
    ];
  }

  void _submitRating() {
    if (_rating > 0) {
      setState(() {
        _reviews.insert(0, {
          'user': 'You',
          'rating': _rating,
          'comment': _review.isEmpty ? 'Good companion' : _review,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });
        _rating = 0;
        _review = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted!'),
          backgroundColor: Color(0xFF2D9C7C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Travel Companion'),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'How was your experience?',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () => setState(() => _rating = index + 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Write a review...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (v) => _review = v,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9C7C),
                  ),
                  child: const Text('Submit Rating'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(review['user'][0])),
                  title: Row(
                    children: [
                      ...List.generate(
                        review['rating'],
                        (i) => const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review['date'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(review['comment']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
