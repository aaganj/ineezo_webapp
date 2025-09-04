import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  // final String baseUrl = 'http://13.219.188.62:8080/api/corporate';
  final String baseUrl = 'https://api.ineezo.com/api/corporate';


   Future<Map<String,dynamic>> login(String email,String password) async{
     final url = Uri.parse('$baseUrl/login');

     final response = await http.post(
       url,
       headers: {'Content-Type': 'application/json'},
       body: jsonEncode({'email':email, 'password':password}),
     );

     final responseBody = jsonDecode(response.body);

     if(response.statusCode ==200){
       return {
         'success':true,
         'data': responseBody,
         'statusCode':response.statusCode
       };
     }else{
       return  {
         'success':false,
         'data': responseBody,
         'statusCode':response.statusCode
       };;
     }
   }

   Future<Map<String,dynamic>> register({
     required String companyName,
     required String email,
     required String password,
     required String profileUrl,
     required String contactNumber,
     String? address,
   }) async{

    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'companyName' : companyName,
        'email' : email,
        'password' : password,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to register: ${response.body}');
    }

    return {
      'success':response.statusCode ==200,
      'data': response.body,
      'statusCode':response.statusCode
    };
   }

  Future<String?> getSignedImageUrlForHostProfile(String adminId) async{
    final urlResponse = await http.get(
      //  Uri.parse("http://13.219.188.62:8080/api/s3/presigned-url?userId=$userId"),
      Uri.parse("https://api.ineezo.com/api/s3/hostprofile/presigned-url?userId=$adminId"),
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


}