import 'dart:convert';
import 'package:http/http.dart' as http;

class BranchLinkService {

  Future<String?> getBranchLink(String eventId, String title) async {
    final response = await http.post(
      Uri.parse("https://api.ineezo.com/api/branch/create-link"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "event_id": eventId,
        "title": title,
        "event_type": "corporate"
      }),
    );

    print("response ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['url']; // Branch returns "url" as short link
    }
    return null;
  }
}