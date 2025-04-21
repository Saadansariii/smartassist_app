import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class TimelineCompleted extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> completedEvents;
  const TimelineCompleted(
      {super.key, required this.events, required this.completedEvents});

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
    // Reverse the events and completedEvents list to show from bottom to top
    final reversedEvents = events.reversed.toList();
    final reversedCompletedEvents = completedEvents.reversed.toList();

    if (reversedEvents.isEmpty && reversedCompletedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Completed Task Available',
            style: AppFont.mediumText14(context),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Loop through events and display them
        ...List.generate(reversedEvents.length, (index) {
          final task = reversedEvents[index];
          String dueDate = _formatDate(task['due_date'] ?? 'N/A');
          String subject = task['subject'] ?? 'No Subject';
          String comment = task['remarks'] ?? 'No Remarks';

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.25,
            isFirst: index == (reversedEvents.length - 1),
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
              color: Colors.green,
              iconStyle: IconStyle(
                iconData: Icons.check,
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
                dueDate,
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
                    padding: const EdgeInsets.all(10.0),
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
                              fontWeight: FontWeight.w500,
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
                            text: comment,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

        // Loop through completedEvents and display them
        ...List.generate(reversedCompletedEvents.length, (index) {
          final task = reversedCompletedEvents[index];
          String remarks = _formatDate(task['remarks'] ?? 'No Remarks');
          String date = _formatDate(task['start_date'] ?? 'No Date');
          String taskSubject = task['subject'] ?? 'No Subject';

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.25,
            isFirst: index == (reversedCompletedEvents.length - 1),
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
              color: Colors.green, // Green color for completed events
              iconStyle: IconStyle(
                iconData: Icons.check,
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
                date,
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
                    padding: const EdgeInsets.all(10.0),
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
                            text: '$taskSubject\n',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
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
