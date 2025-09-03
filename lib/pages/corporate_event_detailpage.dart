import 'package:flutter/material.dart';

import '../model/corporate_event.dart';

class CorporateEventDetailPage extends StatefulWidget {
  final CorporateEvent event;
  const CorporateEventDetailPage({super.key, required this.event});

  @override
  State<CorporateEventDetailPage> createState() =>
      _CorporateEventDetailPageState();
}

class _CorporateEventDetailPageState extends State<CorporateEventDetailPage> {
  bool _isDeleting = false;

  void _deleteEvent() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // TODO: Call your API to delete the event
      await Future.delayed(Duration(seconds: 1)); // simulate API call

      // Go back after deletion
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final screenWidth = MediaQuery.of(context).size.width;

    // For Web, center content with max width
    final contentWidth = screenWidth > 800 ? 600.0 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: contentWidth,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional: Event Image
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              if (event.imageUrl != null) SizedBox(height: 20),

              // Event Title
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Date & Time
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text(
                    '${event.eventStartDateTime.toLocal()}'.split(' ')[0] +
                        ' • ' +
                        '${event.eventStartDateTime.hour.toString().padLeft(2, '0')}:${event.eventStartDateTime.minute.toString().padLeft(2, '0')} - ' +
                        '${event.eventEndDateTime.hour.toString().padLeft(2, '0')}:${event.eventEndDateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Delete Button
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isDeleting ? null : _deleteEvent,
                    child: _isDeleting
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'Delete Event',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100, // subtle web background
    );
  }
}