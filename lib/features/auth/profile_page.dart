import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../routers/app_router.dart';
import '../auth/my_trips_page.dart';
import 'wishlist_page.dart';
import 'payment_details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Overlapping Stats Card
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildHeaderBackground(context),
                _buildStatsCard(context),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.2),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // --- Menu Items Section ---
            
            _buildMenuItem(
              Icons.location_on_outlined,
              "My Trips",
              Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyTripsPage()),
                );
              },
            ),

           

            _buildMenuItem(
              Icons.favorite_border,
              "Wishlist",
              Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              },
            ),

            _buildMenuItem(
              Icons.credit_card,
              "Payment Methods",
              Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentDetailsPage(
                      amount: 0.0,
                      hotelName: "No Booking Selected",
                    ),
                  ),
                );
              },
            ),

            _buildMenuItem(
              Icons.notifications_none,
              "Notifications",
              Colors.purple,
              onTap: () => _showFeatureNote(context, "Notifications"),
            ),

            _buildMenuItem(
              Icons.settings_outlined,
              "Settings",
              Colors.grey,
              onTap: () => _showFeatureNote(context, "Settings"),
            ),

            _buildMenuItem(
              Icons.logout,
              "Logout",
              Colors.redAccent,
              isLogout: true,
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeaderBackground(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            ApiService.getUserName().toUpperCase(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "International Traveller",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Positioned(
      bottom: -40,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("12", "Trips"),
            _buildStatItem("8", "Countries"),
            _buildStatItem("24", "Saved"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color, {
    String? subtitle,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.redAccent : Colors.black87,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)) 
          : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showFeatureNote(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature ensures fair pricing and safety for tourists!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D9C7C),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}