import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/provider/event_list_provider.dart';
import 'package:provider/provider.dart';
import 'event_card.dart';

class CorporateEventList extends StatefulWidget {
  @override
  State<CorporateEventList> createState() => _CorporateEventListState();
}

class _CorporateEventListState extends State<CorporateEventList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
       final provider = context.read<EventListProvider>();
       provider.getCorporateEventsById();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6F61),
          title: Text('My Events',
            style: TextStyle(color: Colors.white),),
         leading: IconButton(
             onPressed: (){
               Navigator.pop(context);
             },
             icon: Icon(Icons.arrow_back,color: Colors.white,)),
      ),
      body: Consumer<EventListProvider>(
          builder: (context, eventListProvider, child) {
              final events = eventListProvider.events;

              if(eventListProvider.isLoading){
                return Center(child: CircularProgressIndicator());
              } else if(eventListProvider.errorMessage != null){
                return Center(child: Text(eventListProvider.errorMessage!));
              } else if(events.isEmpty){
                return Center(child: Text("No events found"));
              } else {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final count = eventListProvider.attendeeCounts[event.id.toString()] ?? 0;

                    return EventCard(
                      event: event,
                      count: count,
                      provider: eventListProvider,
                    );
                  },
                );
              }
          })
    );
  }
}
