import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/venue/provider/venue_provider.dart';
import 'package:provider/provider.dart';

class VenueEditPage extends StatefulWidget {
  final Map<String, dynamic> venue;
  const VenueEditPage({super.key, required this.venue});

  @override
  State<VenueEditPage> createState() => _VenueEditPageState();
}

class _VenueEditPageState extends State<VenueEditPage> {
  late TextEditingController imageController;
  late TextEditingController themeController;

  @override
  void initState() {
    super.initState();
    imageController = TextEditingController(text: widget.venue['imageUrl'] ?? '');
    themeController = TextEditingController(text: widget.venue['theme'] ?? '');
  }

  @override
  void dispose() {
    imageController.dispose();
    themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Venue: ${widget.venue['name']}",
        style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Preview existing image
            if(venueProvider.imageBytes !=null)
              CircleAvatar(
                backgroundImage: MemoryImage(venueProvider.imageBytes!),
                radius: 50,
              )
            else if (widget.venue['imageUrl'] != null &&
                widget.venue['imageUrl'].toString().isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.venue['imageUrl']),
                radius: 50,
              )
            else
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFF6F61),
                child: Icon(Icons.image, size: 40, color: Colors.white),
              ),

            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await venueProvider.pickAndUploadImage(widget.venue['id'].toString());
                },
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Venue Logo"),
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
            const SizedBox(height: 20),

            // Theme input
            TextField(
              controller: themeController,
              decoration: const InputDecoration(
                labelText: "Theme",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  if(themeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Theme cannot be empty")),
                    );
                    return;
                  }
                  if(venueProvider.uploadedImageUrl == null || venueProvider.uploadedImageUrl!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please upload a venue image")),
                    );
                    return;
                  }

                  final result = await venueProvider.updateVenue(
                     widget.venue['id'],
                     themeController.text.trim(),
                     context
                   );
                  if(result['success']==true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Venue updated successfully")),
                    );
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Update failed: ${result['data']}")),
                    );
                  }
                   Navigator.pop(context); // go back after update
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Update Venue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

