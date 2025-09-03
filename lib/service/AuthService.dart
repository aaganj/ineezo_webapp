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

}