import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelBookingPage extends StatefulWidget {
  const HotelBookingPage({super.key, required this.hotel});

  final Map<String, dynamic> hotel;

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 30));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 33));
  int _rooms = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.hotel['name']}'),
        backgroundColor: const Color(0xFF2D9C7C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.hotel, size: 60, color: Color(0xFF2D9C7C)),
                    Text(
                      widget.hotel['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '⭐ ${widget.hotel['rating']} • LKR ${widget.hotel['price']}/night',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _checkIn,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _checkIn = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Check-in'),
                          Text(DateFormat('MMM dd, yyyy').format(_checkIn)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _checkOut,
                        firstDate: _checkIn,
                        lastDate: _checkIn.add(const Duration(days: 30)),
                      );
                      if (picked != null) setState(() => _checkOut = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Check-out'),
                          Text(DateFormat('MMM dd, yyyy').format(_checkOut)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Color(0xFF2D9C7C),
                  ),
                  onPressed: () =>
                      setState(() => _rooms = _rooms > 1 ? _rooms - 1 : 1),
                ),
                Text(
                  '$_rooms ${_rooms == 1 ? 'Room' : 'Rooms'}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF2D9C7C)),
                  onPressed: () => setState(() => _rooms++),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hotel booked successfully!'),
                    backgroundColor: Color(0xFF2D9C7C),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9C7C),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
