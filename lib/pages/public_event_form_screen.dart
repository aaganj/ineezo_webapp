import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/auth/provider/auth_provider.dart';
import 'package:inyzo_admin_web/model/corporate_event.dart';
import 'package:inyzo_admin_web/model/location_api_response.dart';
import 'package:inyzo_admin_web/provider/event_provider.dart';
import 'package:provider/provider.dart';

import 'location_picker_screen.dart';

class PublicEventForm extends StatefulWidget {
  @override
  _PublicEventFormState createState() => _PublicEventFormState();
}

class _PublicEventFormState extends State<PublicEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();
  late  TextEditingController _hostDetailsController = TextEditingController();
  late  TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  LocationAPIResponse? _pickedLocation;

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  @override
  void initState() {
    // TODO: implement initState
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    _hostDetailsController = TextEditingController(text: currentUser?.companyName ?? '');
    _contactNumberController = TextEditingController(text: currentUser?.contactNumber ?? '');
    super.initState();
  }


  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<EventProvider>(context,listen: false);

      CorporateEvent corporateEvent = CorporateEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          numberOfAttendees: int.tryParse(_attendeesController.text) ?? 0,
          imageUrl: provider.uploadedImageUrl ?? '',
          hostname: _hostDetailsController.text,
          contactNumber: _contactNumberController.text,
          location: _pickedLocation!.selectedLocationName ?? '',
          latitude: _pickedLocation!.latitude,
          longitude:  _pickedLocation!.longitude,
          eventStartDateTime: provider.startDateTime ?? DateTime.now(),
          eventEndDateTime: provider.endDateTime ?? DateTime.now(),
          hostID: await provider.getHostID() ?? 0.0
      );


      try {

        bool success = await provider.createEvent(corporateEvent);

     //   if (response.statusCode == 200) {
          // Success response
        if(success){
          _titleController.clear();
          _descriptionController.clear();
          _attendeesController.clear();
          _hostDetailsController.clear();
          _contactNumberController.clear();
          _locationController.clear();
          _startDateTime=null;
          _endDateTime=null;
          provider.clear();

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
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final provider = Provider.of<EventProvider>(context,listen: false);
    return Scaffold(
      appBar:AppBar(
        backgroundColor: const Color(0xFFFF6F61),
        title: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back),color: Colors.white,),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(child: Column(
                    children: [
                      _buildInputField(
                        controller: _titleController,
                        label: "Event Title",
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
                  /// Card 2 - Location
                  _buildCard(
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFFFF6F61)),
                      title: const Text("Event Location"),
                      subtitle: Text(
                        _locationController.text.isNotEmpty
                            ? _locationController.text
                            : "Tap to select event location",
                        style: TextStyle(
                          color: _locationController.text.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      onTap: () async {
                        final LocationAPIResponse? locationApiResponse =
                        await Navigator.push<LocationAPIResponse>(
                          context,
                          MaterialPageRoute(builder: (context) => LocationSearchScreen()),
                        );

                        if (locationApiResponse != null) {
                          setState(() {
                            _pickedLocation = locationApiResponse;
                            _locationController.text =
                            locationApiResponse.selectedFormattedAddress!;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Card 3 - Media Upload
                  _buildCard(
                    child: Column(
                      children: [
                        Consumer<EventProvider>(
                          builder: (context, auth, _) {
                            if (auth.uploadedImageUrl != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  auth.uploadedImageUrl!,
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else if (auth.imageBytes != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  auth.imageBytes!,
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: const Center(
                                child: Text("No image selected"),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: provider.pickAndUploadImage,
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildCard(
                    child: isWideScreen
                        ? Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _attendeesController,
                            label: "Attendees",
                            icon: Icons.group,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _hostDetailsController,
                            label: "Host Details",
                            icon: Icons.person,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _contactNumberController,
                            label: "Contact Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        _buildInputField(
                          controller: _attendeesController,
                          label: "Attendees",
                          icon: Icons.group,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _hostDetailsController,
                          label: "Host Details",
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _contactNumberController,
                          label: "Contact Number",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Start Date & Time Picker
                  /// Card 5 - Schedule
                  Consumer<EventProvider>(
                    builder: (context, provider, _) {
                      return _buildCard(
                        child: Column(
                          children: [
                            _buildDateTile(
                              "Start Date & Time",
                              provider.startDateTime,
                                  () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    _startDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    provider.setStartDate(_startDateTime);

                                  }
                                }
                              },
                            ),
                            const Divider(),
                            _buildDateTile(
                              "End Date & Time",
                              provider.endDateTime,
                                  () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _startDateTime ?? DateTime.now(),
                                  firstDate: _startDateTime ?? DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    _endDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    provider.setEndDate(_endDateTime);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Event Description",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 18, // allows long text
                          minLines: 8,
                          decoration: InputDecoration(
                            hintText: "About the event...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Please enter event description" : null,
                          onChanged: (value) {
                            setState(() {}); // to update word count
                          },
                        ),
                        const SizedBox(height: 6),

                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style:  ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F61),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 60 : 40,
                          vertical: isWideScreen ? 20 : 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: Text('Create Event',
                        style:TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),),
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

  /// Helper: Card Wrapper
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF6F61)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  /// Helper: Date Tile
  Widget _buildDateTile(String title, DateTime? date, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Color(0xFFFF6F61)),
      title: Text(title),
      subtitle: Text(
        date != null ? date.toString() : "Select $title",
        style: TextStyle(color: date != null ? Colors.black : Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
