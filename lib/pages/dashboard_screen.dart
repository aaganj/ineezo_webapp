import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  void dispose() {
    // ✅ Clear AuthProvider data when leaving this page
    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.clearData();

    super.dispose();
  }

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
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.pushNamed(context, '/profile');
                } else if (value == 'logout') {
                  provider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              itemBuilder: (BuildContext context){
                return [
                  const PopupMenuItem(
                    value: 'profile',
                      child: Text('Profile')
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                      child: Text('Logout')
                  ),
                ];
              },
              icon: const Icon(Icons.account_circle,color: Colors.white,size: 32,),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Center content on big screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Update the Map Logo',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Avatar / Upload Preview
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.isUploading) {
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F61)),
                        ),
                      );
                    } else if (provider.uploadedImageUrl != null) {
                      return CircleAvatar(
                        backgroundImage: MemoryImage(provider.imageBytes!),
                        radius: 40,
                      );
                    } else if (provider.currentUser?.profileUrl != null) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(provider.currentUser!.profileUrl!),
                        radius: 40,
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFFF6F61),
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      );
                    }
                  },
                ),

                const SizedBox(height: 15),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () async {

                      final result = await provider.pickAndUploadImage();


                      if (provider.uploadedImageUrl == null &&
                          provider.currentUser?.profileUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please upload a logo/profile image")),
                        );
                        return;
                      }

                      final success = await provider.updateMapLogo(provider.uploadedImageUrl!,
                          provider.currentUser!.companyEmail);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Map logo updated successfully")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Map logo update failed")),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text("Upload Logo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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
