import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_status_page.dart';

class PaymentDetailsPage extends StatefulWidget {
  final double amount; // Explore පිටුවෙන් ලැබෙන ගාස්තුව
  final String hotelName; // Explore පිටුවෙන් ලැබෙන හෝටලයේ නම

  const PaymentDetailsPage({
    super.key, 
    required this.amount, 
    required this.hotelName
  });

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String selectedCard = "Visa"; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Payment Details", 
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Payment Method", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
            const SizedBox(height: 15),
            
            // Payment Options
            _buildPaymentOption("Visa Classic", "**** **** 1254", Icons.credit_card, "Visa"),
            _buildPaymentOption("Master Card", "**** **** 1254", Icons.payment, "Master"),
            _buildPaymentOption("Bank Transfer", "2316 **** **** 1254", Icons.account_balance, "Bank"),

            const SizedBox(height: 25),
            Text("Booking Info", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
            const SizedBox(height: 15),
            
            // Travel/Hotel Info Card (Dynamic Data)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Hotel:", style: const TextStyle(color: Colors.grey)),
                      Text(widget.hotelName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLocationInfo("From", "Colombo"),
                      const Icon(Icons.arrow_forward, color: Colors.blue, size: 16),
                      _buildLocationInfo("To", "Destination"),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
            
            // Total Price Section (Dynamic Amount)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("LKR ${widget.amount.toStringAsFixed(2)}", 
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
              ],
            ),
            const SizedBox(height: 20),
            
            // Pay Now Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Payment Status පිටුවට මුදල සහ කාඩ්පත් වර්ගය යැවීම
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => PaymentStatusPage(
                        paidAmount: widget.amount,
                        paymentMethod: selectedCard,
                      )
                    )
                  );
                },
                child: Text("Pay Now", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, String value) {
    bool isSelected = selectedCard == value;
    return GestureDetector(
      onTap: () => setState(() => selectedCard = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100], 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: Radio(
            value: value,
            groupValue: selectedCard,
            activeColor: Colors.blue,
            onChanged: (val) => setState(() => selectedCard = val.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String city) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(city, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}