import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inyzo_admin_web/auth/provider/auth_provider.dart';
import 'package:inyzo_admin_web/model/corporate_event.dart';
import 'package:inyzo_admin_web/model/location_api_response.dart';
import 'package:inyzo_admin_web/provider/event_provider.dart';
import 'package:inyzo_admin_web/provider/event_schedule_provider.dart';
import 'package:provider/provider.dart';

import '../model/venue_model.dart';
import 'event_schedule_screen.dart';
import 'location_picker_screen.dart';

class PublicEventForm extends StatefulWidget {
  @override
  _PublicEventFormState createState() => _PublicEventFormState();
}

class _PublicEventFormState extends State<PublicEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _bookingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();
  late  TextEditingController _hostDetailsController = TextEditingController();
  late  TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isFree = true;
  LocationApiResponse? _pickedLocation;


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


      if (provider.uploadedImageUrl!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at the event Image ")),
        );
        return;
      }

      final scheduleProvider = context.read<EventScheduleProvider>();
      if (scheduleProvider.schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at least one schedule")),
        );
        return;
      }

      Venue venue = Venue(
        name: _pickedLocation!.name,
        address: _pickedLocation!.address,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        placeId: _pickedLocation!.placeId,
        id: _pickedLocation!.id,
      );

      CorporateEvent corporateEvent = CorporateEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          numberOfAttendees: int.tryParse(_attendeesController.text) ?? 0,
          imageUrl: provider.uploadedImageUrl ?? '',
          hostname: _hostDetailsController.text,
          contactNumber: _contactNumberController.text,
          venue: venue,
          hostId: await provider.getHostID() ?? 0.0,
          instagramUrl: _instagramController.text,
          bookingUrl: _bookingController.text,
          eventType: _eventTypeController.text,
          isFree: _isFree,
          price: _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
          schedules: scheduleProvider.schedules,

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
          context.read<EventScheduleProvider>().clearSchedules();
          _bookingController.clear();
          _instagramController.clear();
          _eventTypeController.clear();
          _pickedLocation = null;
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
                  _buildCard(child: Column(
                    children: [
                      _buildInputField(
                        controller: _eventTypeController,
                        label: "e.g. Board Games, Music Night, Pub Meetup, Comedy",
                        icon: Icons.category,
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
                        final LocationApiResponse? locationApiResponse =
                        await Navigator.push<LocationApiResponse>(
                          context,
                          MaterialPageRoute(builder: (context) => LocationSearchScreen()),
                        );

                        if (locationApiResponse != null) {
                          setState(() {
                            _pickedLocation = locationApiResponse;
                            _locationController.text =
                            locationApiResponse.address!;
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
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Event Schedules",
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EventScheduleScreen()),
                                );
                              },
                              child: const Text("Manage"),
                            ),
                          ],
                        ),
                        Consumer<EventScheduleProvider>(
                          builder: (context, provider, _) {
                            if (provider.schedules.isEmpty) {
                              return const Text("No schedules added yet.");
                            }
                            return Column(
                              children: provider.schedules.map((s) {
                                return ListTile(
                                  leading:
                                  const Icon(Icons.calendar_today, color: Color(0xFFFF6F61)),
                                  title: Text(
                                      "${dateFormat.format(s.startDatetime)} → ${dateFormat.format(s.endDatetime)}"
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
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
                  _buildCard(child: Column(
                    children: [
                      _buildInputField(
                        controller: _instagramController,
                        label: "Add a instagram link (optional)",
                        icon: Icons.camera_alt_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Is this a Free Event?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: _isFree,
                              activeColor: Color(0xFFFF6F61), // Coral theme
                              onChanged: (value) {
                                setState(() {
                                  _isFree = value;
                                  if (_isFree) {
                                    _priceController.clear(); // reset when free
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Animated expand/collapse for price input
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isFree
                              ? SizedBox.shrink() // hides smoothly
                              : Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Price (₹)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (!_isFree && (value == null || value.isEmpty)) {
                                  return "Please enter price for the event";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  _buildCard(child: Column(
                    children: [
                      _buildInputField(
                        controller: _bookingController,
                        label: "Add a booking link (optional)",
                        icon: Icons.book_online_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                    ],
                  )),
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
    bool isRequired = true,
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
      validator: (value) {
        if (!isRequired) return null;
        value!.isEmpty ? "Enter $label" : null;
      }

    );
  }

  final dateFormat = DateFormat('dd MMM yyyy, hh:mm a'); // e.g. 20 Sep 2025, 7:30 PM
}