import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/corporate_event.dart';

class CorporateEventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Corporate Events')),
      body: FutureBuilder<List<CorporateEvent>>(
        future: fetchCorporateEvents(), // API call to fetch events
        builder: (context, snapshot) {
          print("snapshot data : ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text(event.location),
                onTap: () {
                  // Navigate to event details page
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<CorporateEvent>> fetchCorporateEvents() async {
    final url = Uri.parse('http://13.219.188.62:8080/api/corporate-events');  // Your API URL

    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON data
      final List<dynamic> data = json.decode(response.body);

      return data.map((eventJson) => CorporateEvent.fromJson(eventJson)).toList();
    } else {
      // If the response is not successful, throw an error
      throw Exception('Failed to load corporate events');
    }
  }
}
