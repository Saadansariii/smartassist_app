import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineFourWid extends StatelessWidget {
  const TimelineFourWid({super.key});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25, // Adjust alignment of the timeline line
      isFirst: true,
      isLast: false,
      beforeLineStyle: const LineStyle(
        color: Color.fromARGB(255, 149, 143, 143), // Customize line color
        thickness: 1, // Line thickness
      ),
      indicatorStyle: IndicatorStyle(
          padding: EdgeInsets.only(left: 5),
          // drawGap: true,
          width: 30,
          height: 30,
          color: Colors.blue,
          iconStyle: IconStyle(iconData: Icons.mail, color: Colors.white)),
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
            horizontal: 10.0), // Horizontal padding for gap
        child: Column(
          children: [
            SizedBox(
                height:
                    10), // Adds vertical space between startChild and endChild
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffE7F2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tira.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 109, 108, 108),
                      ),
                    ),
                    Text(
                      'By Lili.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Email Delivered: Proposal Sent.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
