import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          /// Logout Button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              /// Navigate back to LoginScreen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-event');
              },
              child: Text('Create Public Event'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/event-listing');
              },
              child: Text('View Created Events'),
            ),
          ],
        ),
      ),
    );
  }
}
