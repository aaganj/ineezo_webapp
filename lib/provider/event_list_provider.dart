import 'package:flutter/cupertino.dart';
import 'package:inyzo_admin_web/model/corporate_event.dart';
import 'package:inyzo_admin_web/service/branchlink_service.dart';

import '../service/event_form_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventListProvider extends ChangeNotifier{
  bool isLoading = false;
  FormService formService = FormService();
  BranchLinkService branchLinkService = BranchLinkService();
  List<CorporateEvent> events = [];
  Map<String, int> attendeeCounts = {};
  String? errorMessage;


  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }


  Future<double?> getHostID() async {
    final prefs = await SharedPreferences.getInstance();
    final value =  prefs.getDouble('adminId');
    if(value == null) {
      throw Exception("Admin ID not found in SharedPreferences");
    }
    return value;
  }

  Future<void> getCorporateEventsById() async{
    try{
      isLoading = true;
      notifyListeners();

      double? adminId =await  getHostID();
      final result = await formService.fetchCorporateEvents(adminId!);

      if(result['success']==true) {
        events = result['data'];
        attendeeCounts = result['attendeesCount'];
        errorMessage = null;
      }else if(result['statusCode'] == 404){
        print("No events found for the given admin ID.");
        events =[];
        attendeeCounts = [] as Map<String, int>;
        errorMessage =null;
      }else{
        events= [];
        errorMessage = "Failed to load events. Status code: ${result['statusCode']}";
      }

    }catch(e){
      print("Error fetching events by ID: $e");
      events=[];
      errorMessage = "An error occurred: $e";
    }finally{
      isLoading = false;
      notifyListeners();
    }

  }

  Future<void> deleteEventById(double eventId) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await formService.deleteEvent(eventId);
      if (result['success'] == true) {
        events.removeWhere((event) => event.id.toString() == eventId);
        errorMessage = null;
      } else {
        errorMessage = "Failed to delete event. Status code: ${result['statusCode']}";
      }
    } catch (e) {
      print("Error deleting event: $e");
      errorMessage = "An error occurred: $e";
    } finally {
      print("came here");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateBranchLink(String eventId, String title) async {
    try {
      final link = await branchLinkService.getBranchLink(eventId, title);
      if (link != null) {
        return link;
      } else {
        throw Exception("Failed to generate Branch link");
      }
    } catch (e) {
      print("Error generating Branch link: $e");
      throw Exception("Error generating Branch link: $e");
    }
  }

}