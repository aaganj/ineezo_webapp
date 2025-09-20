import 'package:flutter/material.dart';
import 'package:inyzo_admin_web/model/event_schedule.dart';
import 'package:inyzo_admin_web/provider/event_schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventScheduleProvider>();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Event Schedules"),
        backgroundColor: const Color(0xFFFF6F61),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show current schedules
            Expanded(
              child: provider.schedules.isEmpty
                  ? const Center(
                child: Text(
                  "No schedules added yet.\nTap 'Add Schedule' to create one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: provider.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = provider.schedules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: Color(0xFFFF6F61)),
                      title: Text(
                        "StartDateTime: ${dateFormat.format(schedule.startDatetime)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        "EndDateTime: ${dateFormat.format(schedule.endDatetime)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.removeSchedule(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Add Schedule button
            ElevatedButton.icon(
              onPressed: () async {
                // --- Pick Start Date & Time ---
                final startDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (startDate == null) return;

                final startTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (startTime == null) return;

                // --- Pick End Date & Time ---
                final endDate = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: startDate,
                  lastDate: DateTime(2100),
                );
                if (endDate == null) return;

                final endTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (endTime == null) return;

                // --- Save schedule ---
                final schedule = EventSchedule(
                  startDatetime: DateTime(
                    startDate.year,
                    startDate.month,
                    startDate.day,
                    startTime.hour,
                    startTime.minute,
                  ),
                  endDatetime: DateTime(
                    endDate.year,
                    endDate.month,
                    endDate.day,
                    endTime.hour,
                    endTime.minute,
                  ),
                );

                context.read<EventScheduleProvider>().addSchedule(schedule);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Schedule"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F61),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info for organisers
            const Text(
              "💡 You can stop after adding one date, or add multiple dates "
                  "if your event happens on different days.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 16),

            // Done button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // go back to event form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
