import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAddress;
  Timer? _debounce;
  List<dynamic> _placePredictions=[];

  String? _selectedLocationName;
  String? _selectedFormattedAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;

  final String googleApiKey = "AIzaSyDFTqdSr-YyaFrv5B1mNFHOMyHUa9d4x2Y";


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged(){
    if(_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), (){
      if(_searchController.text.isNotEmpty){
          _getPlacePrediction(_searchController.text);
      }else{
        setState(() {
          _placePredictions=[];
          _selectedLocationName =null;
          _selectedFormattedAddress=null;
          _selectedLatitude=null;
          _selectedLongitude=null;
        });
      }
    });
  }


  Future<void> _getPlacePrediction(String input) async{
    final String url =
        "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&components=country:IN&types=geocode&language=en";
    try{
      final response = await http.get(Uri.parse(url));

      if(response.statusCode ==200){
        final data = json.decode(response.body);
        if(data['status'] == 'OK'){
          setState(() {
            _placePredictions = data['predictions'];
          });
        }else{
          print('Google Places imcomplete ${data['status']}');
          setState(() {
            _placePredictions=[];
          });
        }
      }else{
        print('HTTP error for AutoCompletye');
        setState(() {
          _placePredictions=[];
        });
      }
    }catch(e){
      print('Network or parsing error for Autocomplete');
      setState(() {
        _placePredictions = [];
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId) async{
    final String url =
        'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,name&key=$googleApiKey';

    try{
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        final data = json.decode(response.body);
        if(data['status']=='OK'){
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          final double lat = location['lat'];
          final double long = location['lng'];
          final String name = result['name'];
         // final String formattedAddress = result['formatted_address'];

          print('Lat : $lat and long : $long');

          setState(() {
            _selectedLocationName = name;
            _selectedFormattedAddress = 'formattedAddress';
            _selectedLatitude = lat;
            _selectedLongitude = long;
          });

        }
      }

    }catch(e){
      print('Network or parsing error for place details :$e');
    }

  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Location")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                hintText: 'e.g., Eiffel Tower, Paris',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _placePredictions.isEmpty && _searchController.text.isNotEmpty ?
                  Center(
                    child: const Text('No suggestions found,please try a different place',
                    style: TextStyle(color: Colors.grey,fontSize: 16)),
                  )
                  : ListView.builder(
                  itemCount: _placePredictions.length,
                  itemBuilder: (context,index){
                    final prediction = _placePredictions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Call _getPlaceDetails with the selected place_id
                          _getPlaceDetails(prediction['place_id']);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  prediction['description'],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

            SizedBox(height: 20),
            const SizedBox(height: 20),

            // Display selected address details
            if (_selectedLocationName != null)
              Column(
                children: [
                  Text(
                    "Location: ${_selectedLocationName!}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Address: ${_selectedFormattedAddress!}",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Lat: ${_selectedLatitude!}, Lng: ${_selectedLongitude!}",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Only pop if a location has been fully selected and details fetched
                if (_selectedLocationName != null &&
                    _selectedFormattedAddress != null &&
                    _selectedLatitude != null &&
                    _selectedLongitude != null) {
                  Navigator.pop(
                    context,
                    LocationResult(
                      name: _selectedLocationName!,
                      address: _selectedFormattedAddress!,
                      latitude: _selectedLatitude!,
                      longitude: _selectedLongitude!,
                    ),
                  );
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
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Define the LocationResult class (you can put this in a separate file)
class LocationResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'LocationResult(name: $name, address: $address, latitude: $latitude, longitude: $longitude)';
  }
}
