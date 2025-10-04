import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/venue/provider/venue_provider.dart';
import 'package:inyzo_admin_web/venue/venue_edit_page.dart';
import 'package:provider/provider.dart';

class VenuePage extends StatefulWidget {
  const VenuePage({super.key});

  @override
  State<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back),color: Colors.white,),
        title: Text(
            "Venue Admin",
            style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFFFF6F61),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "search venues ...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                ElevatedButton(onPressed: (){
                  venueProvider.searchVenues(_searchController.text);
                }, child: const Text('search'))
              ],
            ),
            const SizedBox(height: 20),
            if(venueProvider.isLoading)
               const Center(child: CircularProgressIndicator())
            else if(venueProvider.errorMessage != null)
               Center(child: Text(venueProvider.errorMessage!))
            else if(venueProvider.venues.isEmpty)
               const Center(child: Text("No venues found"))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: venueProvider.venues.length,
                  itemBuilder: (context,index){
                    final venue = venueProvider.venues[index];
                    return Card(
                      child: ListTile(
                        leading: venue['imageUrl'] != null
                            ? Image.network(
                          venue['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image_not_supported, size: 40),
                        title: Text(venue['name']),
                        subtitle:
                        Text("Theme: ${venue['theme'] ?? 'N/A'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: (){
                            // Navigate to edit page with venue details
                             Navigator.push(context, MaterialPageRoute(builder: (_)=>VenueEditPage(venue: venue)));
                          },
                        ),
                      ),
                    );
                  },
                ),
              )

          ],
        ),
      ),
    );
  }
}
