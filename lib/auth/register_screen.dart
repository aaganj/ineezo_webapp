import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import '../model/corporate_user.dart';
import '../service/AuthService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  AuthService authService = AuthService();

  Uint8List? _profileImageBytes;


  void _register() async{
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();


      if(authProvider.uploadedImageUrl==null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please upload a logo/profile image")),
        );
        return;
      }


      CorporateUser corporateUser = CorporateUser(
        companyName: _nameController.text,
        companyEmail: _emailController.text,
        password: _passwordController.text,
        profileUrl: authProvider.uploadedImageUrl!, // This will be set after uploading the image
        contactNumber: _phoneController.text,
        address: "",
      );

      final success = await authProvider.register(
          corporateUser
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("registration succeed, please login to continue")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("registeration failed")),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context,listen: false);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double formWidth;
          EdgeInsetsGeometry padding;

          if (constraints.maxWidth > 1000) {
            // Desktop
            formWidth = 500;
            padding = const EdgeInsets.symmetric(vertical: 40);
          } else if (constraints.maxWidth > 600) {
            // Tablet
            formWidth = 450;
            padding = const EdgeInsets.symmetric(vertical: 30);
          } else {
            // Mobile
            formWidth = constraints.maxWidth * 0.9;
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
                      /// App Logo
                      Image.asset(
                        'assets/logo.webp',
                        height: 80,
                      ),
                      const SizedBox(height: 10),

                      /// App Name
                      Text(
                        "Ineezo",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Register Heading
                      Text(
                        "Register",
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                      /// Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Host Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter the Host Name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      /// Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your email";
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      /// Phone Number Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Contact Number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
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
                          SizedBox(width: 5,),
                          Consumer<AuthProvider>(
                              builder: (context,auth,_){

                                if (auth.isUploading) {
                                  return const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                }else if(authProvider.uploadedImageUrl!=null){
                                  return CircleAvatar(
                                    backgroundImage: MemoryImage(authProvider.imageBytes!),
                                    radius: 30,
                                  );
                                }else{
                                  return const CircleAvatar(
                                    child: Icon(Icons.person),
                                    radius: 30,
                                  );
                                }

                              }),
                        ],
                      ),
                      const SizedBox(height: 15),
                      /// Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      /// Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      /// Register Button
                      Consumer<AuthProvider>(
                        builder: (context,auth,_){
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: auth.isLoading ?
                              const CircularProgressIndicator(color: Colors.white,)
                                  :const Text(
                                "Register",
                                style: TextStyle(fontSize: 16),
                              )
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<AuthProvider>(
                          builder: (context,auth,_){
                            if(auth.errorMessage != null){
                               return Text(
                                'Registration failed',
                                 style: const TextStyle(color: Colors.red),
                               );
                            }
                            return const SizedBox.shrink();
                          }),

                      /// Already Have Account
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().clearData();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
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
  @override
  void dispose() {
    super.dispose();
  }
}
