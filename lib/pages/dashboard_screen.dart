import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context,listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth > 600 ? 400 : double.infinity;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F61),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              provider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Center content on big screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Create Event Button
              _buildStylishButton(
              context,
              label: "Create Public Event",
              icon: Icons.add_circle_outline,
              onTap: () {
                Navigator.pushNamed(context, '/create-event');
              },
              width: buttonWidth,
            ),
            const SizedBox(height: 20),
            _buildStylishButton(
              context,
              label: "View Created Events",
              icon: Icons.event_note,
              onTap: () {
                Navigator.pushNamed(context, '/event-listing');
              },
              width: buttonWidth,
             ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}


Widget _buildStylishButton(BuildContext context,
    {required String label,
      required IconData icon,
      required VoidCallback onTap,
      required double width}) {
  return SizedBox(
    width: width,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6F61), // Coral Accent
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    ),
  );
}
