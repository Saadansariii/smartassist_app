import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineFiveWid extends StatelessWidget {
  const TimelineFiveWid({super.key});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      beforeLineStyle: const LineStyle(
        color: Colors.transparent, // Remove the line
        thickness: 0, // No thickness
      ),
      afterLineStyle: const LineStyle(
        color: Colors.transparent, // Remove the line
        thickness: 0, // No thickness
      ),
      indicatorStyle: const IndicatorStyle(
        width: 0, // No indicator
        height: 0, // No indicator
        color: Colors.transparent, // Transparent to ensure it's not visible
      ),
      endChild: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '22',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            Text(
              'nd',
              style: TextStyle(
                fontSize: 14,
                height: 0.5,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'OCT',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue), // Regular size for 13
            ),
          ],
        ),
      ),
    );
  }
}
