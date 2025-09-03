import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:inyzo_admin_web/model/corporate_event.dart';
import 'package:inyzo_admin_web/service/event_form_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class EventProvider extends ChangeNotifier{
  bool isLoading = false;
  String? _uploadedImageUrl;
  FormService formService = FormService();
  Uint8List? _imageBytes;
  String? _imageName;
  DateTime? startDateTime;
  DateTime? endDateTime;


  String? get uploadedImageUrl => _uploadedImageUrl;
  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  DateTime? get startDate => startDateTime;
  DateTime? get endDate => endDateTime;


  void setUploadedImageUrl(String url) {
    _uploadedImageUrl = url;
    notifyListeners();
  }

  void setImageBytes(Uint8List? bytes) {
    _imageBytes = bytes;
    notifyListeners();
  }

  void setImageName(String? name) {
    _imageName = name;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    startDateTime = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    endDateTime = date;
    notifyListeners();
  }

  Future<void> pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      await uploadImage(_imageBytes,imageName);
    }


  }

  Future<double?> getHostID() async {
    final prefs = await SharedPreferences.getInstance();
    final value =  prefs.getDouble('adminId');
    if(value == null) {
      throw Exception("Admin ID not found in SharedPreferences");
    }
    return value;
  }



  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> uploadImage(Uint8List? _imageBytes, String? _imageName) async {
    try {
      if (_imageBytes == null || _imageName == null) return;

        final presignedUrl = await getSignedImageUrl();
        if (presignedUrl == null || presignedUrl == '') return;

        final uploadImageUrl = await formService.uploadImage(
          presignedUrl, _imageBytes!);
        print("Uploaded Image URL: $uploadImageUrl");
        setUploadedImageUrl(uploadImageUrl as String);
    }catch(e){
      print("Error uploading image: $e");
    }

  }

  Future<String?> getSignedImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getInt('adminId').toString();
      if (userId == null) {
        return null;
      }
      final url = await formService.getSignedImageUrl(userId);
      if (url == null || url.isEmpty) {
        return null;
      }
      return url;
    }catch(e){
      print("Error getting signed URL: $e");
      return null;
  }

  }


  Future<bool> createEvent(CorporateEvent corporateEvent) async{
    try {
      final response = await formService.submitForm(corporateEvent);
        print('response: $response');
        print('response success status : ${response['success']}');

        if (response['success'] == true) {
          print("Event created successfully with status code: ${response['statusCode']}");
          return true;
        } else {
          print("Failed to create event with status code: ${response['statusCode']}, body: ${response['body']}");
          return false;
        }

    }catch(e){
      print("Error creating event: $e");
      return false;
    }
  }

  void clear(){
    _uploadedImageUrl=null;
    _imageBytes=null;
    _imageName=null;
    startDateTime=null;
    endDateTime=null;
    notifyListeners();
  }


}