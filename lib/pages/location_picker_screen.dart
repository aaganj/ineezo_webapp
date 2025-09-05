import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/location/location_provider.dart';
import 'package:provider/provider.dart';


class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<LocationProvider>().searchPlaces(_searchController.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _locationProvider.clearLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search Location",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // keeps content readable on wide screens
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for a place',
                    hintText: 'e.g., Manyata Tech Park, Bangalore ',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6F61)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),

                if (provider.isLoading) const CircularProgressIndicator(color: Color(0xFFFF6F61)),

                // Suggestions List
                Expanded(
                  child: provider.placePredictions.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(
                    child: Text(
                      'No suggestions found, please try a different place',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: provider.placePredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = provider.placePredictions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await provider.fetchPlaceDetails(prediction['place_id']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFFFF6F61)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    prediction['description'],
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Selected Location Details
                if (provider.selectedLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Location: ${provider.selectedLocation?.selectedLocationName ?? ""}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Address: ${provider.selectedLocation?.selectedFormattedAddress ?? ""}",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),

                const SizedBox(height: 20),

                // Confirm Button
                ElevatedButton(
                  onPressed: () {
                    if (provider.selectedLocation != null) {
                      Navigator.pop(context, provider.selectedLocation);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a location first.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F61),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 60 : 40,
                      vertical: isWideScreen ? 20 : 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Confirm Location",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}