import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/provider/auth_provider.dart';
import '../model/corporate_user.dart';



class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

     _nameController = TextEditingController(text: currentUser?.companyName ?? "");
     _emailController = TextEditingController(text: currentUser?.companyEmail ?? "");
     _phoneController = TextEditingController(text: currentUser?.contactNumber ?? "");
     _addressController = TextEditingController(text: currentUser?.address ?? "");
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.uploadedImageUrl == null &&
          authProvider.currentUser?.profileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload a logo/profile image")),
        );
        return;
      }

      CorporateUser updatedUser = CorporateUser(
          companyName: _nameController.text,
          companyEmail: _emailController.text,
          password: authProvider.currentUser?.password ?? "", // unchanged
          profileUrl: authProvider.uploadedImageUrl ?? authProvider.currentUser!.profileUrl!,
          contactNumber: _phoneController.text,
          address: _addressController.text,
          role: "user"
      );

      final success = await authProvider.updateProfile(updatedUser);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile update failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F61),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back),color: Colors.white,),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double formWidth;
          EdgeInsetsGeometry padding;

          if (constraints.maxWidth > 1000) {
            formWidth = 500; // Desktop
            padding = const EdgeInsets.symmetric(vertical: 40);
          } else if (constraints.maxWidth > 600) {
            formWidth = 450; // Tablet
            padding = const EdgeInsets.symmetric(vertical: 30);
          } else {
            formWidth = constraints.maxWidth * 0.9; // Mobile
            padding = const EdgeInsets.symmetric(vertical: 20);
          }

          return Center(
            child: SingleChildScrollView(
              padding: padding,
              child: Container(
                width: formWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Host Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Host Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter the Host Name" : null,
                      ),
                      const SizedBox(height: 15),

                      /// Email
                      TextFormField(
                        controller: _emailController,
                        enabled: false, // email usually not editable
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// Contact Number
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Contact Number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your contact number";
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return "Enter a valid 10-digit number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      /// Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 15),

                      /// Upload / Show Profile Image
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: authProvider.pickAndUploadImage,
                              icon: const Icon(Icons.upload_file),
                              label: const Text("Upload Logo/Profile Image"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (auth.isUploading) {
                                return const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              } else if (authProvider.uploadedImageUrl != null) {
                                return CircleAvatar(
                                  backgroundImage: MemoryImage(authProvider.imageBytes!),
                                  radius: 30,
                                );
                              } else if (authProvider.currentUser?.profileUrl != null) {
                                   return CircleAvatar(
                                    backgroundImage:
                                   NetworkImage(authProvider.currentUser!.profileUrl!),
                                   radius: 30,
                                 );
                               }
                              else {
                                return const CircleAvatar(
                                  child: Icon(Icons.person),
                                  radius: 30,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      /// Update Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: auth.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "Update Profile",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
