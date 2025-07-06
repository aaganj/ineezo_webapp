import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:typed_data';
import 'location_picker_screen.dart';

class CorporateEventForm extends StatefulWidget {
  @override
  _CorporateEventFormState createState() => _CorporateEventFormState();
}

class _CorporateEventFormState extends State<CorporateEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _hostDetailsController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  LocationResult? _pickedLocation;

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _uploadedImageUrl;

  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _imageName == null) return;

    final String userId = "ineezoadmin";

    final urlResponse = await http.get(
      Uri.parse("http://localhost:8080/api/s3/presigned-url?userId=$userId"),
    );

    if (urlResponse.statusCode != 200) return;
    final presignedUrl = json.decode(urlResponse.body)['url'];

    final uploadResponse = await http.put(
      Uri.parse(presignedUrl),
      headers: {"Content-Type": "image/jpeg"},
      body: _imageBytes,
    );

    if (uploadResponse.statusCode == 200) {
      setState(() {
        _uploadedImageUrl = presignedUrl.split("?").first;
      });
    }
  }

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      final apiUrl = Uri.parse('http://localhost:8080/api/corporate-events');

      final Map<String, dynamic> eventData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "numberOfAttendees": int.tryParse(_attendeesController.text) ?? 0,
        "imageUrl": _uploadedImageUrl,
        "hostName": _hostDetailsController.text,
        "contactNumber": _contactNumberController.text,
        "location": _pickedLocation!.name,
        "latitude": _pickedLocation!.latitude,
        "longitude":  _pickedLocation!.longitude,
        "eventStartDateTime": _startDateTime?.toIso8601String() ?? "",
        "eventEndDateTime": _endDateTime?.toIso8601String() ?? "",
      };
      try {

        final response = await http.post(
          apiUrl,
          headers: {"Content-Type": "application/json"},
          body: json.encode(eventData),
        );

        if (response.statusCode == 200) {
          // Success response
          _titleController.clear();
          _descriptionController.clear();
          _attendeesController.clear();
          _uploadedImageUrl=null;
          _hostDetailsController.clear();
          _contactNumberController.clear();
          _locationController.clear();
          _startDateTime=null;
          _endDateTime=null;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Event created successfully!")),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Failure response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: Unable to create event")),
          );
        }
      } catch (error) {
        // Network error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Corporate Event')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Event Title'),
                    validator: (value) => value!.isEmpty ? 'Enter event title' : null,
                  ),
                  ListTile(
                    title: Text("Event Location"),
                    subtitle: Text(_locationController.text.isNotEmpty
                        ? _locationController.text
                        : "Select event location"),
                    trailing: Icon(Icons.location_pin),
                    onTap: () async {

                      // 1. Type Navigator.push to expect a LocationResult
                      final LocationResult? selectedLocationResult = await Navigator.push<LocationResult>(
                        context,
                        MaterialPageRoute(builder: (context) => LocationSearchScreen()),
                      );

                      // 2. Check if a result was returned (user didn't just pop back)
                      if (selectedLocationResult != null) {
                        setState(() {
                          _pickedLocation = selectedLocationResult;
                          _locationController.text = selectedLocationResult.address;
                        });

                        // You can now access all the details from _pickedLocation
                        print('Location picked:');
                        print('  Name: ${_pickedLocation!.name}');
                        print('  Address: ${_pickedLocation!.address}');
                        print('  Latitude: ${_pickedLocation!.latitude}');
                        print('  Longitude: ${_pickedLocation!.longitude}');

                      } else {
                        print('Location selection cancelled.');
                      }
                    }
                  ),
                  _uploadedImageUrl != null
                      ? Image.network(_uploadedImageUrl!, height: 200)
                      : _imageBytes != null
                      ? Image.memory(_imageBytes!, height: 200)
                      : Text("No image selected"),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _pickAndUploadImage,
                    child: Text("Upload Image"),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _attendeesController,
                    decoration: InputDecoration(labelText: 'Number of Attendees'),
                    validator: (value) => value!.isEmpty ? 'Enter number of attendees' : null,
                  ),
                  TextFormField(
                    controller: _hostDetailsController,
                    decoration: InputDecoration(labelText: 'Host Details'),
                    validator: (value) => value!.isEmpty ? 'Enter host details' : null,
                  ),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration: InputDecoration(labelText: 'Contact Number'),
                    validator: (value) => value!.isEmpty ? 'Enter contact number' : null,
                  ),
                  SizedBox(height: 20),
                  // Start Date & Time Picker
                  ListTile(
                    title: Text("Start Date & Time"),
                    subtitle: Text(_startDateTime != null
                        ? _startDateTime.toString()
                        : "Select start date & time"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _startDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),

                  // End Date & Time Picker
                  ListTile(
                    title: Text("End Date & Time"),
                    subtitle: Text(_endDateTime != null
                        ? _endDateTime.toString()
                        : "Select end date & time"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime ?? DateTime.now(),
                        firstDate: _startDateTime ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _endDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(), // Adds a border for better UI
                      alignLabelWithHint: true, // Aligns label properly for multiline
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5, // Allows users to write a bigger paragraph
                    validator: (value) => value!.isEmpty ? "Enter event description" : null,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Create Event'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
