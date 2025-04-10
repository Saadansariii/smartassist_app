import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineTheeWid extends StatelessWidget {
  const TimelineTheeWid({super.key});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25, // Adjust the line position
      isFirst: false,
      isLast: true,
      beforeLineStyle: LineStyle(
        color: const Color.fromARGB(255, 102, 102, 102), // Line color
        thickness: 1, // Line thickness
      ),
      indicatorStyle: IndicatorStyle(
        padding: EdgeInsets.only(left: 5),
        width: 30,
        height: 30,
        color: Colors.blue, // Indicator color
        iconStyle: IconStyle(
          iconData: Icons.mail,
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
          '10:15Am',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0), // Add padding for the gap
        child: Column(
          children: [
            SizedBox(
                height:
                    10), // This adds vertical space between startChild and endChild
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
                      text: 'Emails ', // Make "Emails" bold
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600, // Bold weight
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          'sent, including content, attachments.', // Keep the rest normal
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400, // Normal weight
                        color: Colors.grey,
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
  }
}
