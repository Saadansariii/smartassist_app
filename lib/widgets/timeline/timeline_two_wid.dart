import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineTwoWid extends StatelessWidget {
  final String time;
  final String date;
  final String title;
  final List<Map<String, String>> detailRows;
  final List<Map<String, String>> testDriveDetails;
  final List<Map<String, String>> feedbackDetails;
  final bool isFirst;
  final bool isLast;
  final Color backgroundColor;

  const TimelineTwoWid({
    Key? key,
    this.time = '10:15Am',
    this.date = 'October 22, 2024',
    this.title = 'Land Rover Defender 110 (2024)',
    this.detailRows = const [
      {'label': 'From', 'value': 'Kanchpada Mumbai'},
      {'label': 'To', 'value': 'Marine lines'},
      {'label': 'Start time', 'value': '11 : 55'},
      {'label': 'End time', 'value': '00 : 00'},
      {'label': 'Total time', 'value': '30 min'},
    ],
    this.testDriveDetails = const [
      {'label': 'Car Model', 'value': '[Make, Model, Year]'},
      {
        'label': 'Dealership Location',
        'value': '[Dealership name and address]'
      },
    ],
    this.feedbackDetails = const [
      {
        'label': 'Pros',
        'value':
            'The customer was highly impressed by the sleek and elegant design of the Velar.'
      },
      {
        'label': 'Cons',
        'value':
            'They expressed concern that the low roofline might compromise headroom.'
      },
    ],
    this.isFirst = false,
    this.isLast = false,
    this.backgroundColor = const Color(0xffB2EF89),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(
        color: Color.fromARGB(255, 149, 143, 143),
        thickness: 1,
      ),
      indicatorStyle: IndicatorStyle(
          width: 30,
          height: 30,
          padding: EdgeInsets.only(left: 5),
          color: Colors.blue,
          iconStyle:
              IconStyle(iconData: Icons.directions_car, color: Colors.white)),
      startChild: _buildStartChild(),
      endChild: _buildEndChild(),
    );
  }

  Widget _buildStartChild() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEndChild() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 5),
                _buildDetailsContainer(),
                const SizedBox(height: 5),
                _buildTestDriveSection(),
                _buildFeedbackSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      '$date \n$title',
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDetailsContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: detailRows.map((detail) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Row(
              children: [
                Text(
                  '${detail['label']}:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  detail['value'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTestDriveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Drive 1:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 94, 94, 94),
          ),
        ),
        const SizedBox(height: 5),
        ...testDriveDetails.map((detail) => _buildRichTextDetail(
              detail['label'] ?? '',
              detail['value'] ?? '',
            )),
      ],
    );
  }

  Widget _buildRichTextDetail(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color.fromARGB(255, 94, 94, 94),
        ),
        children: [
          TextSpan(
            text: '• ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback:',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 94, 94, 94),
          ),
        ),
        ...feedbackDetails.map((feedback) => Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: _buildRichTextDetail(
                feedback['label'] ?? '',
                feedback['value'] ?? '',
              ),
            )),
        const SizedBox(height: 4),
        Text(
          'Decision: [interested/Not interested/Considering]',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
