import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/pages/Leads/All_field_bottomArrow/all_appointment.dart'; 

class EventWidget extends StatelessWidget {
  final DateTime selectedDate;
  final int overdueFollowupsCount;
  final int upcomingFollowupsCount;
  final int upcomingAppointmentsCount;
  final int overdueAppointmentsCount;

  const EventWidget({
    super.key,
    required this.selectedDate,
    required this.overdueFollowupsCount,
    required this.upcomingFollowupsCount,
    required this.upcomingAppointmentsCount,
    required this.overdueAppointmentsCount,
  });

  /// ✅ Returns day with proper suffix (st, nd, rd, th)
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ✅ Date Display Widget
                  _DateDisplay(
                      selectedDate: selectedDate,
                      getDayWithSuffix: getDayWithSuffix),
                  const SizedBox(width: 10),

                  /// ✅ Event Info Widget
                  Expanded(
                    child: _EventInfo(
                      screenWidth: screenWidth,
                      upcomingFollowupsCount: upcomingFollowupsCount,
                      upcomingAppointmentsCount: upcomingAppointmentsCount,
                      overdueFollowupsCount: overdueFollowupsCount,
                      overdueAppointmentsCount: overdueAppointmentsCount,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ✅ Reusable Widget for Date Display
class _DateDisplay extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(int) getDayWithSuffix;

  const _DateDisplay({
    required this.selectedDate,
    required this.getDayWithSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff7FAEE5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedDate.day}',
                style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
              ),
              Text(
                getDayWithSuffix(selectedDate.day)
                    .substring(selectedDate.day.toString().length),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 0.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Text(
            DateFormat('MMM').format(selectedDate),
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// ✅ Reusable Widget for Event Info
class _EventInfo extends StatelessWidget {
  final double screenWidth;
  final int upcomingFollowupsCount;
  final int upcomingAppointmentsCount;
  final int overdueFollowupsCount;
  final int overdueAppointmentsCount;

  const _EventInfo({
    required this.screenWidth,
    required this.upcomingFollowupsCount,
    required this.upcomingAppointmentsCount,
    required this.overdueFollowupsCount,
    required this.overdueAppointmentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EventRow(
          icon: Icons.circle,
          iconColor: AppColors.sideGreen,
          label: 'Upcoming Follow-Ups',
          count: upcomingFollowupsCount,
        ),
        _EventRow(
          icon: Icons.circle,
          iconColor: AppColors.sideGreen,
          label: 'Upcoming Appointment',
          count: upcomingAppointmentsCount,
        ),
        _EventRow(
          icon: Icons.circle,
          iconColor: AppColors.sideRed,
          label: 'Overdue Follow-Ups',
          count: overdueFollowupsCount,
        ),
        _EventRow(
          icon: Icons.circle,
          iconColor: AppColors.sideRed,
          label: 'Overdue Appointment',
          count: overdueAppointmentsCount,
        ),
      ],
    );
  }
}

/// ✅ Reusable Widget for Each Event Row
class _EventRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int count;

  const _EventRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 12),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          // Row(
          //   children: [
          //     Text(
          //       '$count',
          //       style: GoogleFonts.poppins(fontSize: 16, color: iconColor),
          //     ),
          //     const SizedBox(width: 10),
          //     const Icon(Icons.arrow_forward_ios_rounded,
          //         size: 20, color: Colors.grey),
          //   ],
          // ),

          Row(
            children: [
              Text(
                '$count',
                style: GoogleFonts.poppins(fontSize: 16, color: iconColor),
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to your target screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllAppointment(), // Replace with your screen
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:smart_assist/config/component/color/colors.dart';

// class EventWidget extends StatefulWidget {
//   final DateTime selectedDate;
//   final int overdueFollowupsCount;
//   final int upcomingFollowupsCount;
//   final int upcomingAppointmentsCount;
//   final int overdueAppointmentsCount;

//   const EventWidget({
//     super.key,
//     required this.overdueFollowupsCount,
//     required this.upcomingFollowupsCount,
//     required this.upcomingAppointmentsCount,
//     required this.overdueAppointmentsCount,
//     required this.selectedDate,
//   });

//   @override
//   State<EventWidget> createState() => _EventWidgetState();
// }

// class _EventWidgetState extends State<EventWidget> {
//   String getDayWithSuffix(int day) {
//     if (day >= 11 && day <= 13) {
//       return '${day}th';
//     }
//     switch (day % 10) {
//       case 1:
//         return '${day}st';
//       case 2:
//         return '${day}nd';
//       case 3:
//         return '${day}rd';
//       default:
//         return '${day}th';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // Get the screen width
//           double screenWidth = constraints.maxWidth;

//           // Adjust layout based on screen size
//           return Column(
//             children: [
//               // if (widget.upcomingFollowupsCount == 0 &&
//               //     widget.overdueFollowupsCount == 0)
//               //   const Center(child: Text('No follow-ups available.')),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Date and Time Section (left-aligned)
//                   Row(
//                     children: [
//                       Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: const Color(0xff7FAEE5),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${widget.selectedDate.day}', // Day number (e.g., 13)
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 24,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     // '${getDayWithSuffix(DateTime.now().day).substring(DateTime.now().day.toString().length)}', // Suffix part (e.g., 'th', 'st', etc.)
//                                     getDayWithSuffix(widget.selectedDate.day)
//                                         .substring(widget.selectedDate.day
//                                             .toString()
//                                             .length),
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14,
//                                       height: 0.5,
//                                       fontWeight: FontWeight.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                   width: 5), // Space between day and month
//                               Text(
//                                 DateFormat('MMM').format(widget.selectedDate),
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
                             
//                             ],
//                           )),
//                     ],
//                   ),

//                   const SizedBox(
//                     width: 10,
//                   ),

//                   // Add some space between rows
//                   if (screenWidth > 600)
//                     const SizedBox(width: 20), // Add space for larger screens

//                   // Name Section (right-aligned)
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(Icons.person_2_outlined),
//                             Text(
//                               'Event',
//                               style: TextStyle(
//                                   fontSize: screenWidth > 600 ? 18 : 16,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.circle,
//                                   color: AppColors.sideGreen,
//                                   size: 12,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text('Upcoming Follow-Ups ',
//                                     style: GoogleFonts.poppins(fontSize: 16)),
//                               ],
//                             ),
//                             // const SizedBox(width: 2),
//                             // const SizedBox(width: 2),
//                             Row(
//                               children: [
//                                 Text('${widget.upcomingFollowupsCount}',
//                                     style: TextStyle(
//                                         fontSize: screenWidth > 600 ? 20 : 16,
//                                         color: AppColors.sideGreen)),
//                               ],
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.circle,
//                                   color: AppColors.sideGreen,
//                                   size: 12,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text('Upcoming Appointment ',
//                                     style: GoogleFonts.poppins(fontSize: 16)),
//                               ],
//                             ),
//                             // const SizedBox(width: 2),
//                             // const SizedBox(width: 2),
//                             Row(
//                               children: [
//                                 Text('${widget.upcomingAppointmentsCount}',
//                                     style: TextStyle(
//                                         fontSize: screenWidth > 600 ? 20 : 16,
//                                         color: AppColors.sideGreen)),
//                               ],
//                             )
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.circle,
//                                   color: AppColors.sideRed,
//                                   size: 12,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text('Overdue Follow-Ups ',
//                                     style: GoogleFonts.poppins(fontSize: 16)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text('${widget.overdueFollowupsCount}',
//                                     style: TextStyle(
//                                         fontSize: screenWidth > 600 ? 20 : 16,
//                                         color: AppColors.sideRed)),
//                               ],
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.circle,
//                                   color: AppColors.sideRed,
//                                   size: 12,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text('Overdue Appointment ',
//                                     style: GoogleFonts.poppins(fontSize: 16)),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text('${widget.overdueAppointmentsCount}',
//                                     style: GoogleFonts.poppins(
//                                         fontSize: screenWidth > 600 ? 20 : 16,
//                                         color: AppColors.sideRed)),
//                               ],
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 5),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
