import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/corporate_event.dart';

class FormService{


  Future<String?> getSignedImageUrl(String adminId) async{
    final urlResponse = await http.get(
      //  Uri.parse("http://13.219.188.62:8080/api/s3/presigned-url?userId=$userId"),
      Uri.parse("https://api.ineezo.com/api/s3/presigned-url?userId=$adminId"),
    );

    if(urlResponse.statusCode == 200){
      final presignedUrl = json.decode(urlResponse.body)['url'];
      return presignedUrl;
    }else {
      return null;
    }

  }


  Future<String?> uploadImage(String presignedUrl, List<int> imageBytes) async{
    final uploadResponse = await http.put(
      Uri.parse(presignedUrl),
      headers: {"Content-Type": "image/jpeg"},
      body: imageBytes,
    );

    print("Upload Response Status: ${uploadResponse.statusCode}");

    if (uploadResponse.statusCode == 200) {
      return presignedUrl.split("?").first;
    } else {
      return null;
    }
  }


  Future<Map<String, dynamic>> submitForm(CorporateEvent corporateEvent) async{
    final apiUrl = Uri.parse('https://api.ineezo.com/api/corporate-events');

    final response = await http.post(
      apiUrl,
      headers: {"Content-Type": "application/json"},
      body: json.encode(corporateEvent.toJson()),
    );

    if (response.statusCode == 200) {
      print("Event created successfully");
      return{
        "success": true,
       "statusCode": response.statusCode,
       "body": json.decode(response.body)
      };
    } else {
      print("Failed to create event: ${response.body}");
      return{
        "success": false,
        "statusCode": response.statusCode,
        "body": response.body
      };
    }
  }

  Future<Map<String,dynamic>> fetchCorporateEvents(double adminId) async{
    final apiUrl = Uri.parse('https://api.ineezo.com/api/corporate-events/public/$adminId');
    final response = await http.get(apiUrl, headers: {'Content-Type': 'application/json'});
    Map<String,int> attendeesCount = {};

    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      List<CorporateEvent> events = data.map((eventJson) => CorporateEvent.fromJson(eventJson)).toList();
      final eventIds = events
          .where((e) => e.id != null)
          .map((e) => e.id!.toDouble())
          .toList();

      if(eventIds.isNotEmpty){
        attendeesCount = await getAttendeesCount(eventIds);
      }

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': events,
        'attendeesCount': attendeesCount
      };
    }else{
      return {
        'success': false,
        'statusCode': response.statusCode,
        'data': [],
        'attendeesCount': []
      };
    }
  }

  Future<Map<String,int>> getAttendeesCount(List<double> eventIds) async{
     final idsQuery = eventIds.join(',');
     final response = await http.get(
       Uri.parse('https://api.ineezo.com/api/corporate-events/attendeesCounts?ids=$idsQuery')
     );

     if(response.statusCode == 200){
       final Map<String,dynamic> data = jsonDecode(response.body);
       return data.map((key, value) => MapEntry(key, value as int));
     }else{
       throw Exception("Failed to fetch attendee counts");
     }
  }

  Future<Map<String, dynamic>> deleteEvent(double eventID) async {
    final apiUrl = Uri.parse('https://api.ineezo.com/api/corporate-events/$eventID');
    final response =  await http.delete(apiUrl, headers: {'Content-Type': 'application/json'});
    print('resposne : ${response.statusCode}');
    if(response.statusCode == 200){
      return {
        'success': true,
        'statusCode': response.statusCode,
      };
    }else {
      return {
        'success': false,
        'statusCode': response.statusCode,
      };
    }
  }
}