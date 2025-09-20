import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/corporate_event.dart';
import '../provider/event_list_provider.dart';
import '../share/share_event_page.dart';

class EventCard extends StatefulWidget {
  final CorporateEvent event;
  final int count;
  final EventListProvider provider;

  const EventCard({
    Key? key,
    required this.event,
    required this.count,
    required this.provider,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String? branchLink;
  bool isLoading = false;

  Future<void> _generateLink() async {
    setState(() => isLoading = true);

    final link = await widget.provider.generateBranchLink(
      widget.event.id.toString(),
      widget.event.title,
    );

    setState(() {
      branchLink = link;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Row(
          children: [
            // ✅ Event Image + Details (same as your code)...
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.event.imageUrl,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.008 + 14,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: screenWidth * 0.008 + 12,
                        color: Colors.redAccent, // location icon color
                      ),
                      SizedBox(width: 4),
                       Flexible(
                         child: Text(
                           widget.event.venue.name,
                           style: TextStyle(
                             fontSize: screenWidth * 0.008 + 8,
                             fontWeight: FontWeight.w500,
                             color: Colors.grey[700],
                           ),
                           overflow: TextOverflow.ellipsis, // prevents overflow
                         ),
                       ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Start Time
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        size: screenWidth * 0.02, // responsive size
                        color: Color(0xFFFF6F61), // Coral accent
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${widget.count} attending",
                        style: TextStyle(
                          fontSize: screenWidth * 0.004 + 14, // adaptive but still readable
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF10265A),
                          // keeps it readable on white
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // 👇 Button OR Link
                  if (branchLink != null)
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            branchLink!,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Color(0xFFFF6F61)), // 👈 Copy icon
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: branchLink!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Link copied to clipboard ✅"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        ShareEventPage(
                          title: "Board Game Night 🎲",
                          description: "Join us for fun games & new friends!",
                          host: "Buddies & Boards",
                          dateTime: "Saturday, Sept 13, 5:00 PM",
                          location: "Indiranagar",
                          imageUrl: "https://yourcdn.com/event_image.jpg",
                          eventLink: branchLink!,
                        ),
                      ],
                    )
                  else if (isLoading)
                    CircularProgressIndicator()
                  else
                    OutlinedButton.icon(
                      onPressed: _generateLink,
                      icon: Icon(Icons.link, color: Color(0xFFFF6F61), size: 18),
                      label: Text(
                        "Generate Link",
                        style: TextStyle(
                          color: Color(0xFFFF6F61),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFFF6F61), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    )
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(onPressed: ()async{
                  final confirm = await showDialog(
                      context: context,
                      builder: (context)=>AlertDialog(
                        title: Text('Delete Event'),
                        content: Text("Are you sure you want to delete this event? This action cannot be undone."),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(context,false),
                              child: Text("Cancel")),
                          TextButton(onPressed: ()=>Navigator.pop(context,true),
                              child: Text("Delete",style: TextStyle(color: Colors.red),)),
                        ],
                      ));

                  if(confirm == true){
                    await widget.provider.deleteEventById(widget.event.id!);
                    if(mounted){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Event deleted successfully")),
                      );
                    }
                  }
                },
                  icon: Icon(Icons.delete),
                  color: const Color(0xFFFF6F61),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeUntilStart(DateTime startDateTime) {
    final now = DateTime.now();
    final difference = startDateTime.difference(now);

    if (difference.inSeconds <= 0) {
      return "Started";
    } else if (difference.inMinutes < 60) {
      return "Starts in ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "Starts in ${difference.inHours} hr";
    } else {
      return "Starts in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}";
    }
  }
}
