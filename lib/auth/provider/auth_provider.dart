import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:inyzo_admin_web/model/corporate_user.dart';
import 'package:inyzo_admin_web/service/AuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier{
   final AuthService _authService = AuthService();

   bool _isLoading = false;
   bool _isUploading = false;
   String? _errorMessage;
   bool _isLoggedIn = false;
   Uint8List? _imageBytes;
   String? _imageName;
   String? _uploadedImageUrl;
   CorporateUser? _currentUser;
   bool _isForgetLoading = false;
   bool _isResetLoading = false;
   String? resetToken=null;

   bool get isLoading => _isLoading;
   bool get isUploading => _isUploading;
   String? get errorMessage => _errorMessage;
   bool get isLoggedIn => _isLoggedIn;
   Uint8List? get imageBytes => _imageBytes;
   String? get imageName => _imageName;
   String? get uploadedImageUrl => _uploadedImageUrl;
   CorporateUser? get currentUser => _currentUser;
    bool get isForgetLoading => _isForgetLoading;
    bool get isResetLoading => _isResetLoading;

   void setUploadedImageUrl(String url) {
     _uploadedImageUrl = url;
     notifyListeners();
   }

   void setImageBytes(Uint8List? bytes) {
     _imageBytes = bytes;
     notifyListeners();
   }

   void setUploading(bool value){
     _isUploading = value;
     notifyListeners();
   }

    void setForgetLoading(bool value){
      _isForgetLoading = value;
      notifyListeners();
    }

    void setResetLoading(bool value){
      _isResetLoading = value;
      notifyListeners();
    }

   Future<bool>  login(String email,String password) async{
    _setLoading(true);
    try {
      final response = await _authService.login(email, password);
      final data = response['data'];
      final token = data != null ? data['token'] : null;
      final adminId = data != null ? data['id'] : null;
      final bool success = response['success'];
      print('corporate USer dTO value : ${data['corporateUserDto']}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setDouble('adminId', adminId);

      if (success) {
        _currentUser = CorporateUser.fromJson(data['corporateUserDto']);
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

   Future<bool>  register(CorporateUser corporateUser) async{
     _setLoading(true);

     try {
       final result = await _authService.register(
           companyName: corporateUser.companyName,
           email: corporateUser.companyEmail,
           password: corporateUser.password,
           profileUrl: corporateUser.profileUrl,
           contactNumber: corporateUser.contactNumber,
       );

       print ("result from auth provider: $result");

       final bool success = result['success'];
       final int statusCode = result['statusCode'];
       final dynamic data = result['data'];
       _currentUser = CorporateUser.fromJson(data);

       if(success){
         _errorMessage = null;
       }else{
         _errorMessage = 'Registration failed (Code: $statusCode)';
       }
       _setLoading(false);
       return success;
     }catch(e){
       _errorMessage = "Registration failed: $e";
       _setLoading(false);
       return false;
     }

   }

   Future<bool> updateProfile(CorporateUser updatedUser) async{
     _setLoading(true);
     try {
       final result = await _authService.updateProfile(
         companyName: updatedUser.companyName,
         email: updatedUser.companyEmail,
         profileUrl: updatedUser.profileUrl,
         contactNumber: updatedUser.contactNumber,
         address: updatedUser.address,
       );

       print ("result from auth provider: $result");

       final bool success = result['success'];
       final int statusCode = result['statusCode'];
       final dynamic data = result['data'];
       _currentUser = CorporateUser.fromJson(data);

       if(success){
         _errorMessage = null;
       }else{
         _errorMessage = 'Profile update failed (Code: $statusCode)';
       }
       _setLoading(false);
       return success;
     }catch(e){
       _errorMessage = "Profile update failed: $e";
       _setLoading(false);
       return false;
     }
   }

   Future<bool> updateMapLogo(String profileUrl,String email) async{
     _setLoading(true);
     try {
       final result = await _authService.updateMapLogo(
         email: email,
         profileUrl:profileUrl
       );

       print ("result from auth provider: $result");

       final bool success = result['success'];
       final int statusCode = result['statusCode'];
       final dynamic data = result['data'];
       _currentUser = CorporateUser.fromJson(data);

       if(success){
         _errorMessage = null;
       }else{
         _errorMessage = 'Profile update failed (Code: $statusCode)';
       }
       _setLoading(false);
       return success;
     }catch(e){
       _errorMessage = "Profile update failed: $e";
       _setLoading(false);
       return false;
     }
   }


   Future<void> pickAndUploadImage() async {
     setUploading(true);
     FilePickerResult? result = await FilePicker.platform.pickFiles(
       type: FileType.image,
       allowMultiple: false,
     );

     if (result != null) {
       _imageBytes = result.files.first.bytes;
       _imageName = result.files.first.name;
       await uploadImage(_imageBytes,imageName);
     }else{
        setUploading(false);
     }
   }

   Future<void> uploadImage(Uint8List? _imageBytes, String? _imageName) async {
     try {
       if (_imageBytes == null || _imageName == null) return;
       final compressedBytes = await FlutterImageCompress.compressWithList(
         _imageBytes,
         minWidth: 1080,   // resize to max 1080px width
         minHeight: 1080,  // resize to max 1080px height
         quality: 75,      // 0-100 (balance between size & quality)
         format: CompressFormat.jpeg,
       );


       final presignedUrl = await getSignedImageUrl();
       if (presignedUrl == null || presignedUrl == '') return;

       final uploadImageUrl = await _authService.uploadImage(
           presignedUrl, compressedBytes);
       print("Uploaded Image URL: $uploadImageUrl");
       setUploadedImageUrl(uploadImageUrl as String);
        setUploading(false);
     }catch(e){
       print("Error uploading image: $e");
        setUploading(false);
     }finally{
       setUploading(false);
     }

   }


   Future<String?> getSignedImageUrl() async {
     try {
       final url = await _authService.getSignedImageUrlForHostProfile("_hostprofile");
       if (url == null || url.isEmpty) {
         return null;
       }
       return url;
     }catch(e){
       print("Error getting signed URL: $e");
       return null;
     }

   }

   Future<void> forgetPassword(String email) async{
     setForgetLoading(true);
     try {
       final response = await _authService.forgetPassword(email);
       final bool success = response['success'];
       if (success) {
         _errorMessage = null;
         resetToken = response['resetToken'];
       } else {
         _errorMessage = "Failed to send reset email";
         resetToken=null;
       }
     }catch(e){
       _errorMessage = "Request failed: $e";
       resetToken=null;
     }finally{
       setForgetLoading(false);
       notifyListeners();
     }
   }

    Future<bool> resetPassword(String token, String newPassword) async{
      setResetLoading(true);

      try {
        final response = await _authService.resetPassword(token, newPassword);
        final bool success = response['success'];
        if (success) {
          _errorMessage = null;
          return true;
        } else {
          _errorMessage = "Failed to reset password";
          return false;
        }
      }catch(e){
        _errorMessage = "Request failed: $e";
        return false;
      }finally{
        setResetLoading(false);
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

   void clearData() {
     _isLoading=false;
     _isUploading=false;
     _imageBytes = null;
     _uploadedImageUrl = null;
     _errorMessage=null;
     notifyListeners();
   }
}