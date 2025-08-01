import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
   final String baseUrl = 'http://13.219.188.62:8080/api/corporate';


   Future<bool> login(String email,String password) async{
     final url = Uri.parse('$baseUrl/login');

     final response = await http.post(
       url,
       headers: {'Content-Type': 'application/json'},
       body: jsonEncode({'email':email, 'password':password}),
     );

     if(response.statusCode ==200){
       final data = jsonDecode(response.body);
       final token = data['token'];

       final prefs = await SharedPreferences.getInstance();
       await prefs.setString('token', token);

       return true;
     }else{
       return false;
     }
   }

   Future<bool> register({
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
    return response.statusCode==200;
   }

   Future<void> logout() async{
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('token');
   }

   Future<String?> getToken() async{
     final prefs = await SharedPreferences.getInstance();
     return prefs.getString('token');
   }

}