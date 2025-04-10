import 'package:flutter/material.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineOneWidget extends StatelessWidget {
  const TimelineOneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25,
      isFirst: false,
      isLast: false,
      beforeLineStyle: const LineStyle(
        color: Color.fromARGB(255, 149, 143, 143),
        thickness: 1,
      ),
      indicatorStyle: IndicatorStyle(
        padding: EdgeInsets.only(left: 5),
        width: 30,
        height: 30,
        color: Colors.blue,
        iconStyle:
            IconStyle(iconData: Icons.directions_car, color: Colors.white),
      ),
      startChild: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF8F5F2),
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
              decoration: BoxDecoration(
                color: const Color(0xffF8F5F2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'October 22, 2024 \nLand Rover Defender 110 (2024).',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text('from:',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    const SizedBox(height: 3),
                                    SizedBox(width: 10),
                                    Text(
                                      'Kanchpada Mumbai',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: 1),
                                    const Divider(
                                        color: Colors.black, thickness: 1),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text('To:',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black)),
                                    const SizedBox(height: 3),
                                    SizedBox(width: 10),
                                    Text(
                                      'Marine lines',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(height: 1),
                                    const Divider(
                                        color: Colors.black, thickness: 1),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text('Start time:',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black)),
                                    const SizedBox(height: 3),
                                    SizedBox(width: 10),
                                    Text(
                                      '11 : 55',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(height: 1),
                                    const Divider(
                                        color: Colors.grey, thickness: 1),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text('End time:',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black)),
                                    const SizedBox(height: 3),
                                    SizedBox(width: 10),
                                    Text(
                                      '00 : 00',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(height: 1),
                                    const Divider(
                                        color: Colors.grey, thickness: 1),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Text('Total time:',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black)),
                                    const SizedBox(height: 3),
                                    SizedBox(width: 10),
                                    Text(
                                      '30 min',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(height: 1),
                                    const Divider(
                                        color: Colors.grey, thickness: 1),
                                  ],
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Test Drive 2:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 94, 94, 94),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w400, // Default weight for the text
                        color: const Color.fromARGB(255, 94, 94, 94),
                      ),
                      children: [
                        TextSpan(
                          text: '• ', // Add the dot with a space
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight
                                .bold, // Ensure the dot is bold if needed
                          ),
                        ),
                        TextSpan(
                          text: 'Car Model: ', // Bold text
                          style: GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.w600, // Bold weight for "Car Model:"
                          ),
                        ),
                        TextSpan(
                          text: '[Make, Model, Year]', // Regular text
                          style: GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.w400, // Regular weight for the rest
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '• ', // Starting dot
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 94, 94, 94),
                          ),
                        ),
                        TextSpan(
                          text: 'Dealership Location: ', // Bold part
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600, // Bold weight
                            color: const Color.fromARGB(255, 94, 94, 94),
                          ),
                        ),
                        TextSpan(
                          text: '[Dealership name and addresss]', // Normal part
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(255, 94, 94, 94),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '• ', // Starting dot
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(255, 94, 94, 94),
                          ),
                        ),
                        TextSpan(
                          text: 'feedback:', // Bold text
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600, // Bold weight
                            color: const Color.fromARGB(255, 94, 94, 94),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '• ', // Starting dot
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                          TextSpan(
                            text: 'Pros: ', // Bold "Pros"
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600, // Bold weight
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                          TextSpan(
                            text:
                                'The customer was highly impressed by the sleek and elegant design of the Velar.', // Normal text
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2), // Space between Pros and Cons
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '• ', // Starting dot
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                          TextSpan(
                            text: 'Cons: ', // Bold "Cons"
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600, // Bold weight
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                          TextSpan(
                            text:
                                'They expressed concern that the low roofline might compromise headroom.', // Normal text
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 94, 94, 94),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Decision:[interested/Not interested/Considering]',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
