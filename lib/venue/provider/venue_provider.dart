import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class VenueProvider extends ChangeNotifier{
  List<dynamic> _venues = [];
  bool _isLoading = false;
  bool _isUploading = false;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _errorMessage;
  String? _uploadedImageUrl;

  bool get isLoading => _isLoading;
  List<dynamic> get venues => _venues;
  bool get isUploading => _isUploading;
  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  String? get errorMessage => _errorMessage;
  String? get uploadedImageUrl => _uploadedImageUrl;

  final String baseUrl = "http://13.219.188.62:8080/api/venues";

  Future<void> searchVenues(String query) async{
     if(query.isEmpty) return;
     _isLoading=true;
     _errorMessage=null;
     notifyListeners();

     try{
       final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));

       if(response.statusCode ==200){
         _venues = jsonDecode(response.body);
       }else{
         _errorMessage = "Failed to search venues";
       }

       _isLoading = false;
       notifyListeners();

     }catch(e){
       _errorMessage = "Error: $e";
     }

     _isLoading = false;
     notifyListeners();
  }

  Future<void> pickAndUploadImage(String venueId) async {
    setUploading(true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
        await uploadImage(_imageBytes,imageName,venueId);
      }
    }catch(e){
      _errorMessage = "Image pick failed: $e";
    }
    setUploading(false);
    notifyListeners();
  }

  Future<void> uploadImage(Uint8List? _imageBytes, String? _imageName,String venueId) async {
    try {
      if (_imageBytes == null || _imageName == null) return;
      final compressedBytes = await FlutterImageCompress.compressWithList(
        _imageBytes,
        minWidth: 1080,   // resize to max 1080px width
        minHeight: 1080,  // resize to max 1080px height
        quality: 75,      // 0-100 (balance between size & quality)
        format: CompressFormat.jpeg,
      );

      final presignedUrl = await getSignedImageUrl(venueId);
      if (presignedUrl == null || presignedUrl == '') return;

      final uploadImageUrl = await uploadImageToDB(
          presignedUrl, compressedBytes);
      setUploadedImageUrl(uploadImageUrl!);
      print("Uploaded Image URL: $uploadImageUrl");
      setUploading(false);

    }catch(e){
      print("Error uploading image: $e");
      setUploading(false);
    }finally{
      setUploading(false);
    }
  }


  Future<String?> uploadImageToDB(String presignedUrl, List<int> imageBytes) async{
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

  Future<String?> getSignedImageUrl(String venueId) async {
    try {
      final url = await getSignedImageUrlForVenueImage(venueId);
      if (url == null || url.isEmpty) {
        return null;
      }
      return url;
    }catch(e){
      print("Error getting signed URL: $e");
      return null;
    }

  }



  Future<String?> getSignedImageUrlForVenueImage (String venueId) async{
    final urlResponse = await http.get(
      //  Uri.parse("http://13.219.188.62:8080/api/s3/presigned-url?userId=$userId"),
      Uri.parse("https://api.ineezo.com/api/s3/venue/presigned-url?userId=$venueId"),
    );

    if(urlResponse.statusCode == 200){
      final presignedUrl = json.decode(urlResponse.body)['url'];
      return presignedUrl;
    }else {
      return null;
    }

  }

  Future<Map<String,dynamic>> updateVenue(int id,String theme,BuildContext context) async {
    String imageUrl = _uploadedImageUrl ?? '';
    if(imageUrl.isEmpty) {
      return{
      'success':false,
      'data': 'No image uploaded',
      'statusCode':400
    };
    }

    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "imageUrl": imageUrl,
        "theme": theme,
      }),
    );

    if(response.statusCode == 200){
      return {
        'success':true,
        'data': jsonDecode(response.body),
        'statusCode':response.statusCode
      };
    }else {
      return {
        'success':false,
        'data': jsonDecode(response.body),
        'statusCode':response.statusCode
      };
    }
  }

  void setUploadedImageUrl(String url) {
    _uploadedImageUrl = url;
    notifyListeners();
  }

  void setUploading(bool value){
    _isUploading = value;
    notifyListeners();
  }
}