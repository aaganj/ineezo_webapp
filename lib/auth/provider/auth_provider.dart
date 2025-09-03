import 'package:flutter/cupertino.dart';
import 'package:inyzo_admin_web/service/AuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier{
   final AuthService _authService = AuthService();

   bool _isLoading = false;
   String? _errorMessage;
   bool _isLoggedIn = false;

   bool get isLoading => _isLoading;
   String? get errorMessage => _errorMessage;
   bool get isLoggedIn => _isLoggedIn;

   Future<bool>  login(String email,String password) async{
    _setLoading(true);
    try {
      final response = await _authService.login(email, password);
      final data = response['data'];
      final token = data != null ? data['token'] : null;
      final adminId = data != null ? data['id'] : null;
      final bool success = response['success'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setDouble('adminId', adminId);

      if (success) {
        _isLoggedIn = true;
        _errorMessage = null;
      } else {
        _isLoggedIn = false;
        _errorMessage = "Invalid email or password";
      }
      _setLoading(false);
      return success;
    }catch(e){
      _errorMessage = "Login failed: $e";
      _isLoggedIn = false;
      _setLoading(false);
      return false;
    }
   }

   Future<bool>  register(String companyName,String email, String password) async{
     _setLoading(true);

     try {
       final result = await _authService.register(
           companyName: companyName,
           email: email,
           password: password);

       print ("result from auth provider: $result");

       final bool success = result['success'];
       final int statusCode = result['statusCode'];
       final dynamic data = result['data'];

       if(success){
         _errorMessage = null;
       }else{
         _errorMessage = data['message']?? 'Registration failed (Code: $statusCode)';
       }
       _setLoading(false);
       return success;
     }catch(e){
       _errorMessage = "Registration failed: $e";
       _setLoading(false);
       return false;
     }

   }

   Future<void> logout() async{
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove("token");
     await prefs.remove('adminId');
     _isLoggedIn = false;
     notifyListeners();
   }

   void _setLoading(bool value){
     _isLoading = value;
     notifyListeners();
   }
}