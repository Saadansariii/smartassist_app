import 'package:flutter/material.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineSixWid extends StatelessWidget {
  const TimelineSixWid({super.key});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25, // Adjust the line position
      isFirst: false,
      isLast: true,
      beforeLineStyle: LineStyle(
        color: const Color.fromARGB(255, 102, 102, 102), // Line color
        thickness: 2, // Line thickness
      ),
      indicatorStyle: IndicatorStyle(
        padding: EdgeInsets.only(left: 5),
        width: 30,
        height: 30,
        color: Colors.lightGreen, // Indicator color
        iconStyle: IconStyle(
          iconData: Icons.phone,
          color: Colors.white,
        ),
      ),
      startChild: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF4FDEE),
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffF4FDEE),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Updated  the quote over call', // Make "Emails" bold
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600, // Bold weight
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', including content, attachments, and whether they were opened or clicked.', // Keep the rest normal
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
