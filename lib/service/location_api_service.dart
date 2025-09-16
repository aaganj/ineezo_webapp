import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inyzo_admin_web/model/location_api_response.dart';

class LocationApiService{



  Future<List<dynamic>> getPlacePrediction(String input) async{

    List<dynamic> _placePredictions=[];

    //final String url = "http://13.219.188.62:8080/api/places/autocomplete?input=$input";
    try{
      // final (lat,long) = await _locationHelper.getUserLocation();
      final String url = "https://api.ineezo.com/api/places/autocomplete?input=$input";
      // final String url = "http://localhost:8080/api/places/autocomplete?input=$input";

      // final String url =
      //     "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&components=country:IN&language=en";

      final response = await http.get(Uri.parse(url));

      if(response.statusCode ==200){
        final data = json.decode(response.body);
        if(data['status'] == 'OK'){
          _placePredictions = data['predictions'];
        }else{
          print('Google Places incomplete ${data['status']}');
          _placePredictions=[];
        }
      }else{
        print('HTTP error for AutoComplete');
        _placePredictions=[];
      }
    }catch(e){
      print('Network or parsing error for Autocomplete ${e.toString()}');
      _placePredictions = [];
      return _placePredictions;
    }

    return _placePredictions;
  }

  Future<LocationAPIResponse?> getPlaceDetails(String placeId) async{
    // final String url =
    //     'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,name&key=$googleApiKey';

    //final url = 'http://13.219.188.62:8080/api/places/details?place_id=$placeId';
    final url = 'https://api.ineezo.com/api/places/details?place_id=$placeId';

    try{
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        final data = json.decode(response.body);
        if(data['status']=='OK'){
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          final formattedAddress = result['formatted_address'];
          final double lat = location['lat'];
          final double long = location['lng'];
          final String name = result['name'];
          // final String formattedAddress = result['formatted_address'];

          print('Lat : $lat and long : $long');
          LocationAPIResponse apiResponse = LocationAPIResponse(
              selectedLocationName: name,
              selectedFormattedAddress: formattedAddress,
              latitude: lat,
              longitude: long);

          return apiResponse;
        }
      }

    }catch(e){
      print('Network or parsing error for place details :$e');
      return null;
    }
   return null;
  }

}