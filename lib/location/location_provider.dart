import 'package:flutter/cupertino.dart';
import 'package:inyzo_admin_web/model/location_api_response.dart';
import 'package:inyzo_admin_web/service/location_api_service.dart';

class LocationProvider extends ChangeNotifier{

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _placePredictions=[];
  LocationAPIResponse? _selectedLocation;

  bool get isLoading =>_isLoading;
  String? get error=>_errorMessage;
  List<dynamic> get placePredictions=>_placePredictions;
  LocationAPIResponse? get selectedLocation=>_selectedLocation;

  LocationApiService locationApiService = LocationApiService();


  Future<void> searchPlaces(String input) async{
     if(input.isEmpty){
       _placePredictions =[];
       notifyListeners();
       return;
     }

     _setLoading(true);
     try{
       _placePredictions = await locationApiService.getPlacePrediction(input);
       _errorMessage =null;
     }catch(e){
       _errorMessage = "Failed to fetch place details";
       _placePredictions=[];
     }finally{
       _setLoading(false);
     }
  }

  Future<void> fetchPlaceDetails(String placeId) async{
    _setLoading(true);
    try{
      final details = await locationApiService.getPlaceDetails(placeId);
     _selectedLocation = details;
     _errorMessage =null;
    }catch(e){
      _errorMessage = "Failed to fetch places";
      _selectedLocation = null;
    }finally{
      _setLoading(false);
    }
  }


  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  void clearLocation(){
    _errorMessage = null;
    _selectedLocation = null;
    _placePredictions = [];
    notifyListeners();
  }



}