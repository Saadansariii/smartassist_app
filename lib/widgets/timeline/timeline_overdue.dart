import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class timelineOverdue extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> overdueEvents;
  const timelineOverdue(
      {super.key, required this.tasks, required this.overdueEvents});

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(date);
      return DateFormat("d MMM").format(parsedDate); // Outputs "22 May"
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reverse the tasks list to show from bottom to top
    final reversedTasks = tasks.reversed.toList();

    // Reverse the upcomingEvents list to show from bottom to top
    final reversedUpcomingEvents = overdueEvents.reversed.toList();

    if (reversedTasks.isEmpty && reversedUpcomingEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("No Overdue task available"),
        ),
      );
    }

    return Column(
      children: [
        // Loop through tasks and display them
        ...List.generate(reversedTasks.length, (index) {
          final task = reversedTasks[index];
          String remarks = task['remarks'] ?? 'No Subject';
          String dueDate = _formatDate(task['due_date'] ?? 'N/A');
          String subject = task['subject'] ?? 'No Subject';

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.25,
            isFirst: index == (reversedTasks.length - 1),
            isLast: index == 0,
            beforeLineStyle: const LineStyle(color: Colors.transparent),
            afterLineStyle: const LineStyle(color: Colors.transparent),
            indicatorStyle: IndicatorStyle(
              padding: const EdgeInsets.only(left: 5),
              width: 30,
              height: 30,
              color: AppColors.sideRed,
              iconStyle: IconStyle(
                iconData: Icons.call,
                color: Colors.white,
              ),
            ),
            startChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xffE7F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                dueDate, // Show the due date
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
            endChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffE7F2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 10),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Action : ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: '$subject\n',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Remarks : ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: remarks,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fontColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Loop through upcomingEvents and display them
        ...List.generate(reversedUpcomingEvents.length, (index) {
          final event = reversedUpcomingEvents[index];
          String remarks = event['remarks'] ?? 'No Remarks';
          String eventDate = _formatDate(event['start_date'] ?? 'N/A');
          String eventSubject = event['subject'] ?? 'No Subject';

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.25,
            isFirst: index == (reversedUpcomingEvents.length - 1),
            isLast: index == 0,
            beforeLineStyle: const LineStyle(
              color: Colors.transparent,
            ),
            afterLineStyle: const LineStyle(
              color: Colors.transparent,
            ),
            indicatorStyle: IndicatorStyle(
              padding: const EdgeInsets.only(left: 5),
              width: 30,
              height: 30,
              color: AppColors.sideRed, // Green for upcoming events
              iconStyle: IconStyle(
                iconData: Icons.event_available,
                color: Colors.white,
              ),
            ),
            startChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xffE7F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                eventDate, // Show the event date
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
            endChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffE7F2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 10),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Action : ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: '$eventSubject\n',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Remarks : ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fontColor,
                            ),
                          ),
                          TextSpan(
                            text: remarks,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fontColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
