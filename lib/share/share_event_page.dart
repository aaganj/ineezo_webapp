import 'package:flutter/material.dart';
import 'dart:html' as html;


void shareOnWhatsApp(String message) {
  final encoded = Uri.encodeComponent(message);
  final url = "https://wa.me/?text=$encoded";
  html.window.open(url, "_blank");
}

void shareOnInstagram(String message) {
  html.window.navigator.clipboard?.writeText(message);
  html.window.open("https://www.instagram.com/", "_blank");
  html.window.alert("Event details copied ✅ Paste it in your Instagram post/story.");
}

void shareOnFacebook(String message) {
  final encoded = Uri.encodeComponent(message);
  final url = "https://www.facebook.com/sharer/sharer.php?u=$encoded";
  html.window.open(url, "_blank");
}

void shareOnX(String message) {
  final encoded = Uri.encodeComponent(message);
  final url = "https://twitter.com/intent/tweet?text=$encoded";
  html.window.open(url, "_blank");
}

void shareOnThreads(String message) {
  html.window.navigator.clipboard?.writeText(message);
  html.window.open("https://www.threads.net/", "_blank");
  html.window.alert("Event details copied ✅ Paste it in Threads.");
}


// ✅ Build share message
String buildEventMessage({
  required String title,
  required String description,
  required String host,
  required String dateTime,
  required String location,
  required String imageUrl,
  required String eventLink
}) {
  return '''
🎉 $title  

📅 When: $dateTime  
📍 Where: $location  
👤 Host: $host   
🔗 More Info: $eventLink
''';
}


class ShareEventPage extends StatelessWidget {
  final String title;
  final String description;
  final String host;
  final String dateTime;
  final String location;
  final String imageUrl;
  final String eventLink;

  const ShareEventPage({
    super.key,
    required this.title,
    required this.description,
    required this.host,
    required this.dateTime,
    required this.location,
    required this.imageUrl,
    required this.eventLink,
  });

  @override
  Widget build(BuildContext context) {
    return  OutlinedButton.icon(
      icon: const Icon(Icons.share, color: Color(0xFFFF6F61), size: 18),
      label: const Text(
        "Share Event",
        style: TextStyle(
          color: Color(0xFFFF6F61),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFFF6F61), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    onPressed: () {
      final message = buildEventMessage(
        title: title,
        description: description,
        host: host,
        dateTime: dateTime,
        location: location,
        imageUrl: imageUrl,
        eventLink: eventLink,
      );

      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Share Event"),
              content: const Text("Where do you want to share this event?"),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    shareOnWhatsApp(message);
                  },
                  icon: const Icon(Icons.call_end_sharp, color: Colors.green),
                  label: const Text("WhatsApp"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    shareOnFacebook(message);
                  },
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  label: const Text("Facebook"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    shareOnX(message);
                  },
                  icon: const Icon(Icons.alternate_email, color: Colors.black),
                  label: const Text("X (Twitter)"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    shareOnInstagram(message);
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.purple),
                  label: const Text("Instagram"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    shareOnThreads(message);
                  },
                  icon: const Icon(Icons.forum, color: Colors.deepPurple),
                  label: const Text("Threads"),
                ),
              ],
            ),
      );
    },
    );
  }

}
