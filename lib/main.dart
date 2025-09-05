import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/location/location_provider.dart';
import 'package:inyzo_admin_web/pages/host_profile.dart';
import 'package:inyzo_admin_web/pages/public_event_form_screen.dart';
import 'package:inyzo_admin_web/pages/corporate_event_list.dart';
import 'package:inyzo_admin_web/pages/dashboard_screen.dart';
import 'package:inyzo_admin_web/provider/event_list_provider.dart';
import 'package:inyzo_admin_web/provider/event_provider.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'auth/provider/auth_provider.dart';
import 'auth/register_screen.dart';


void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>AuthProvider()),
          ChangeNotifierProvider(create: (_)=>LocationProvider()),
          ChangeNotifierProvider(create: (_)=>EventProvider()),
          ChangeNotifierProvider(create: (_)=>EventListProvider()),
        ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ineezo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFF6F61),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardPage(),
        '/create-event': (context) => PublicEventForm(),
        '/event-listing': (context) => CorporateEventList(),
        '/profile': (context) => UpdateProfileScreen(),
      },
    );
  }
}


