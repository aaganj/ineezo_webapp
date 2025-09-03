import 'dart:async';

import 'package:web/web.dart' as web;
import 'dart:js_interop';

class LocationHelper{

  Future<(double lat,double long)> getUserLocation() async{
     final completer = Completer<(double,double)>();

     final success = (web.GeolocationPosition position){
        final cords = position.coords;
        final lat = cords.latitude!;
        final lng = cords.longitude!;
        completer.complete((lat,lng));
     }.toJS;

     final error = (web.GeolocationPositionError err){
       completer.completeError('GeoLocation error: ${err.message}');
     }.toJS;

     //Request Location from browser
    web.window.navigator.geolocation.getCurrentPosition(success,error);
    return completer.future;
  }
}

