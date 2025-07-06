import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/pages/corporate_event_form_screen.dart';
import 'package:inyzo_admin_web/pages/corporate_event_list.dart';
import 'package:inyzo_admin_web/pages/dashboard_screen.dart';
import 'package:inyzo_admin_web/pages/login_screen.dart';
import 'package:inyzo_admin_web/pages/register_screen.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFF6F61),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home:LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardPage(),
        '/create-event': (context) => CorporateEventForm(),
        '/event-listing': (context) => CorporateEventList(),
      },
    );
  }
}


