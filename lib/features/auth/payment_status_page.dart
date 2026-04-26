import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentStatusPage extends StatelessWidget {
  // මෙම variables දෙක අනිවාර්යයෙන්ම ඇතුළත් කරන්න
  final double paidAmount;
  final String paymentMethod;

  // Constructor එක හරහා දත්ත ලබාගැනීමට මෙලෙස සකසන්න
  const PaymentStatusPage({
    super.key, 
    required this.paidAmount, 
    required this.paymentMethod
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon Section
              const CircleAvatar(
                radius: 50, 
                backgroundColor: Color(0xFFE3F2FD), 
                child: Icon(Icons.check, color: Colors.blue, size: 50)
              ),
              const SizedBox(height: 30),
              Text(
                "Payment Successful", 
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const Text(
                "Your transaction is being processed.", 
                style: TextStyle(color: Colors.grey)
              ),
              
              const SizedBox(height: 40),
              const Divider(),
              
              // ලැබෙන දත්ත මෙහි ප්‍රදර්ශනය වේ
              _statusRow("Payment Method", paymentMethod),
              _statusRow("Date", "26 Apr 2026"),
              _statusRow("Transaction ID", "FT4J5KN0"),
              _statusRow("Total Paid", "LKR ${paidAmount.toStringAsFixed(2)}"),
              
              const Divider(),
              const SizedBox(height: 50),
              
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: Text(
                    "Back to Home", 
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)), 
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
        ]
      ),
    );
  }
}