
import 'package:flutter/material.dart';
import '../model/event_schedule.dart';

class EventScheduleProvider extends ChangeNotifier {
  // Existing fields...
  List<EventSchedule> _schedules = [];

  List<EventSchedule> get schedules => _schedules;

  void addSchedule(EventSchedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void removeSchedule(int index) {
    _schedules.removeAt(index);
    notifyListeners();
  }

  void clearSchedules() {
    _schedules.clear();
    notifyListeners();
  }
}
