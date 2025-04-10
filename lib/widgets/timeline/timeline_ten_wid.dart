import 'package:flutter/material.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_fonts/google_fonts.dart';
class TimelineTenWid extends StatelessWidget {
  const TimelineTenWid({super.key});

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
                      color: Colors
                          .transparent, // Transparent to ensure it's not visible
                    ),
                    endChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'History',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
;
  }
}