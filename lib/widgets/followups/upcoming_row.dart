import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowupsUpcoming extends StatefulWidget {
  final List<dynamic> upcomingFollowups;
  final bool isNested;
  final Function(String, bool)? onFavoriteToggle;

  const FollowupsUpcoming({
    super.key,
    required this.upcomingFollowups,
    required this.isNested,
    this.onFavoriteToggle,
  });

  @override
  State<FollowupsUpcoming> createState() => _FollowupsUpcomingState();
}

class _FollowupsUpcomingState extends State<FollowupsUpcoming> {
  final Map<String, double> _swipeOffsets = {};
  late bool isFav;

  void _onHorizontalDragUpdate(DragUpdateDetails details, String taskId) {
    setState(() {
      _swipeOffsets[taskId] =
          (_swipeOffsets[taskId] ?? 0) + (details.primaryDelta ?? 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, dynamic item, int index) {
    String taskId = item['task_id'];
    double swipeOffset = _swipeOffsets[taskId] ?? 0;

    if (swipeOffset > 100) {
      // Right Swipe (Favorite)
      _toggleFavorite(taskId, index);
    } else if (swipeOffset < -100) {
      // Left Swipe (Call)
      _handleCall(item);
    }

    // Reset animation
    setState(() {
      _swipeOffsets[taskId] = 0.0;
    });
  }

  Future<void> _toggleFavorite(String taskId, int index) async {
    final token = await Storage.getToken();
    try {
      // Get the current favorite status before toggling
      bool currentStatus =
          widget.upcomingFollowups[index]['favourite'] ?? false;
      bool newFavoriteStatus = !currentStatus;

      final response = await http.put(
        Uri.parse(
          'https://api.smartassistapp.in/api/favourites/mark-fav/task/$taskId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        // No need to send in body since taskId is already in the URL
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.upcomingFollowups[index]['favourite'] = newFavoriteStatus;
        });

        // Notify the parent if the callback is provided
        if (widget.onFavoriteToggle != null) {
          widget.onFavoriteToggle!(taskId, newFavoriteStatus);
        }
      } else {
        print('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  void _handleCall(dynamic item) {
    print("Call action triggered for ${item['name']}");

    String mobile = item['mobile'] ?? '';

    if (mobile.isNotEmpty) {
      try {
        // Simple approach without canLaunchUrl check
        final phoneNumber = 'tel:$mobile';
        launchUrl(Uri.parse(phoneNumber),
            mode: LaunchMode.externalNonBrowserApplication);
      } catch (e) {
        print('Error launching phone app: $e');
        // Show error message to user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No phone number available')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.upcomingFollowups.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: Text(
            'No upcoming followups available ',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: widget.isNested
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: widget.upcomingFollowups.length,
      itemBuilder: (context, index) {
        var item = widget.upcomingFollowups[index];

        if (!(item.containsKey('name') &&
            item.containsKey('due_date') &&
            item.containsKey('lead_id') &&
            item.containsKey('task_id'))) {
          return ListTile(title: Text('Invalid data at index $index'));
        }

        String taskId = item['task_id'];
        double swipeOffset = _swipeOffsets[taskId] ?? 0;

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, taskId),
          onHorizontalDragEnd: (details) =>
              _onHorizontalDragEnd(details, item, index),
          child: UpcomingFollowupItem(
            key: ValueKey(item['task_id']),
            name: item['name'],
            date: item['due_date'],
            mobile: item['mobile'],
            subject: item['subject'] ?? '',
            vehicle: item['PMI'] ?? 'Range Rover Velar',
            leadId: item['lead_id'],
            taskId: taskId,
            isFavorite: item['favourite'] ?? false,
            swipeOffset: swipeOffset,
            fetchDashboardData:
                () {}, // Placeholder, replace with actual method
          ),
        );
      },
    );
  }
}

class UpcomingFollowupItem extends StatelessWidget {
  final String name, date, vehicle, leadId, taskId, subject, mobile;
  final bool isFavorite;
  final double swipeOffset;
  final VoidCallback fetchDashboardData;

  const UpcomingFollowupItem({
    super.key,
    required this.name,
    required this.date,
    required this.vehicle,
    required this.leadId,
    required this.taskId,
    required this.isFavorite,
    required this.swipeOffset,
    required this.fetchDashboardData,
    required this.subject,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: _buildFollowupCard(context),
    );
  }

  Widget _buildFollowupCard(BuildContext context) {
    bool isFavoriteSwipe = swipeOffset > 50;
    bool isCallSwipe = swipeOffset < -50;

    // Gradient background for swipe
    LinearGradient _buildSwipeGradient() {
      if (isFavoriteSwipe) {
        return const LinearGradient(
          colors: [
            Color.fromRGBO(239, 206, 29, 0.67),
            // Colors.yellow.withOpacity(0.2),
            // Colors.yellow.withOpacity(0.8)
            Color.fromRGBO(239, 206, 29, 0.67)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      } else if (isCallSwipe) {
        return LinearGradient(
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.green.withOpacity(0.8)
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        );
      }
      return const LinearGradient(
        colors: [AppColors.containerBg, AppColors.containerBg],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }

    return Stack(
      children: [
        // Favorite Swipe Overlay
        if (isFavoriteSwipe)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.withOpacity(0.2),
                    Colors.yellow.withOpacity(0.8)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 15),
                    Icon(
                        isFavorite
                            ? Icons.star_outline_rounded
                            : Icons.star_rounded,
                        color: Color.fromRGBO(226, 195, 34, 1),
                        size: 40),
                    const SizedBox(width: 10),
                    Text(isFavorite ? 'Unfavorite' : 'Favorite',
                        style: GoogleFonts.poppins(
                            color: Color.fromRGBO(187, 158, 0, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

        // Call Swipe Overlay
        if (isCallSwipe)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.8)
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.phone_in_talk,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Text('Call',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ),

        // Main Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            gradient: _buildSwipeGradient(),
            borderRadius: BorderRadius.circular(7),
            border: Border(
              left: BorderSide(
                width: 8.0,
                color: isFavorite
                    ? (isCallSwipe
                        ? Colors.green
                            .withOpacity(0.9) // Green when swiping for a call
                        : Colors.yellow.withOpacity(isFavoriteSwipe
                            ? 0.1
                            : 0.9)) // Keep yellow when favorite
                    : (isFavoriteSwipe
                        ? Colors.yellow.withOpacity(0.1)
                        : (isCallSwipe
                            ? Colors.green.withOpacity(0.1)
                            : AppColors.sideGreen)),
              ),
            ),
          ),
          child: Opacity(
            opacity: (isFavoriteSwipe || isCallSwipe) ? 0 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Conditional favorite star
                    // if (isFavorite || isFavoriteSwipe)
                    //   Icon(
                    //     Icons.star_rounded,
                    //     color: isFavoriteSwipe
                    //         ? Colors.white
                    //         : AppColors.starColorsYellow,
                    //     size: 40,
                    //   ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildUserDetails(context),
                            _buildVerticalDivider(15),
                            _buildCarModel(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildSubjectDetails(context),
                            _date(context),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                _buildNavigationButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    // ✅ Accept context
    return GestureDetector(
      onTap: () {
        if (leadId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowupsDetails(leadId: leadId)),
          );
        } else {
          print("Invalid leadId");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: AppColors.arrowContainerColor,
            borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.arrow_forward_ios_rounded,
            size: 25, color: Colors.white),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    return Text(name,
        textAlign: TextAlign.end, style: AppFont.dashboardName(context));
  }

  Widget _buildSubjectDetails(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.phone_in_talk, color: Colors.blue, size: 18),
        const SizedBox(width: 5),
        Text('$subject,', style: AppFont.smallText(context)),
      ],
    );
  }

  Widget _date(BuildContext context) {
    String formattedDate = '';

    try {
      DateTime parseDate = DateTime.parse(date);

      // Check if the date is today
      if (parseDate.year == DateTime.now().year &&
          parseDate.month == DateTime.now().month &&
          parseDate.day == DateTime.now().day) {
        formattedDate = 'Today';
      } else {
        // If not today, format it as "26th March"
        int day = parseDate.day;
        String suffix = _getDaySuffix(day);
        String month = DateFormat('MMM').format(parseDate); // Full month name
        formattedDate = '${day}$suffix $month';
      }
    } catch (e) {
      formattedDate = date; // Fallback if date parsing fails
    }

    return Row(
      children: [
        const SizedBox(width: 5),
        Text(formattedDate, style: AppFont.smallText(context)),
      ],
    );
  }

// Helper method to get the suffix for the day (e.g., "st", "nd", "rd", "th")
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildVerticalDivider(double height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
      height: height,
      width: 0.1,
      decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.fontColor))),
    );
  }

  Widget _buildCarModel(BuildContext context) {
    return Text(
      vehicle,
      textAlign: TextAlign.start,
      style: AppFont.dashboardCarName(context),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}


 
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import 'package:intl/intl.dart';
// import 'package:smart_assist/config/component/color/colors.dart'; 
// import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';

// class FollowupsUpcoming extends StatefulWidget {
//   final List<dynamic> upcomingFollowups;
//   final bool isNested;
//   const FollowupsUpcoming({
//     super.key,
//     required this.upcomingFollowups,
//     required this.isNested,

//   });

//   @override
//   State<FollowupsUpcoming> createState() => _FollowupsUpcomingState();
// }

// class _FollowupsUpcomingState extends State<FollowupsUpcoming> {
//   double _swipeOffset = 0.0;

//   void _onHorizontalDragUpdate(DragUpdateDetails details) {
//     setState(() {
//       _swipeOffset += details.primaryDelta ?? 0;
//     });
//   }

//   void _onHorizontalDragEnd(DragEndDetails details, String taskId, int index) {
//     if (_swipeOffset > 100) {
//       // Right Swipe (Favorite)
//       _toggleFavorite(taskId, index);
//     } else if (_swipeOffset < -100) {
//       // Left Swipe (Call)
//       print(
//           "Call action triggered for ${widget.upcomingFollowups[index]['name']}");
//     }

//     // Reset animation
//     setState(() {
//       _swipeOffset = 0.0;
//     });
//   }

//   Future<void> _toggleFavorite(String taskId, int index) async {
//     setState(() {
//       widget.upcomingFollowups[index]['favourite'] =
//           !(widget.upcomingFollowups[index]['favourite'] ?? false);
//     });

//     // Simulating API Call (Replace with actual API request)
//     await Future.delayed(Duration(milliseconds: 500));

//     print("Favorite toggled for Task ID: $taskId");
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.upcomingFollowups.isEmpty) {
//       return const SizedBox(
//         height: 240,
//         child: Center(child: Text('No upcoming followups available')),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: widget.isNested
//           ? const NeverScrollableScrollPhysics()
//           : const AlwaysScrollableScrollPhysics(),
//       itemCount: widget.upcomingFollowups.length,
//       itemBuilder: (context, index) {
//         var item = widget.upcomingFollowups[index];

//         if (!(item.containsKey('name') &&
//             item.containsKey('due_date') &&
//             item.containsKey('lead_id') &&
//             item.containsKey('task_id'))) {
//           return ListTile(title: Text('Invalid data at index $index'));
//         }

//         return GestureDetector(
//           onHorizontalDragUpdate: _onHorizontalDragUpdate,
//           onHorizontalDragEnd: (details) =>
//               _onHorizontalDragEnd(details, item['task_id'], index),
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _swipeOffset > 50
//                   ? Colors.yellow // Right Swipe (Favorite)
//                   : _swipeOffset < -50
//                       ? Colors.blue // Left Swipe (Call)
//                       : Colors.white, // Default
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 5,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Left Side (Favorite)
//                 if (_swipeOffset > 50)
//                   Row(
//                     children: [
//                       Icon(Icons.star_rounded, color: Colors.white, size: 30),
//                       SizedBox(width: 10),
//                       Text("Prime",
//                           style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600)),
//                     ],
//                   ),

//                 // Middle (Task Info)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item['name'],
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 5),
//                       Text(item['due_date'],
//                           style: TextStyle(fontSize: 14, color: Colors.grey)),
//                     ],
//                   ),
//                 ),

//                 // Right Side (Call)
//                 if (_swipeOffset < -50)
//                   Row(
//                     children: [
//                       Text("Call",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(width: 10),
//                       Icon(Icons.phone, color: Colors.white, size: 28),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class UpcomingFollowupItem extends StatelessWidget {
//   final String name, date, vehicle, leadId, taskId;
//   final bool isFavorite;
//   final VoidCallback fetchDashboardData;

//   const UpcomingFollowupItem({
//     super.key,
//     required this.name,
//     required this.date,
//     required this.vehicle,
//     required this.leadId,
//     required this.taskId,
//     required this.isFavorite,
//     required this.fetchDashboardData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
//       child: _buildFollowupCard(context), // ✅ Pass context here
//     );
//   }

//   Widget _buildFollowupCard(BuildContext context) {
//     // ✅ Accept context
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: AppColors.containerBg,
//         borderRadius: BorderRadius.circular(10),
//         border: const Border(
//           left: BorderSide(width: 8.0, color: AppColors.sideGreen),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               if (isFavorite)
//                 const Icon(
//                   Icons.star_rounded,
//                   color: AppColors.starColorsYellow,
//                   size: 40,
//                 ),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildUserDetails(),
//                   const SizedBox(
//                       height: 4), // Spacing between user details and date-car
//                   Row(
//                     children: [
//                       _date(),
//                       _buildVerticalDivider(20),
//                       _buildCarModel(),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           _buildNavigationButton(context), // ✅ Pass context here
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationButton(BuildContext context) {
//     // ✅ Accept context
//     return GestureDetector(
//       onTap: () {
//         if (leadId.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => FollowupsDetails(leadId: leadId)),
//           );
//         } else {
//           print("Invalid leadId");
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(3),
//         decoration: BoxDecoration(
//             color: AppColors.arrowContainerColor,
//             borderRadius: BorderRadius.circular(30)),
//         child: const Icon(Icons.arrow_forward_ios_rounded,
//             size: 25, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildUserDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(name,
//             style: GoogleFonts.poppins(
//                 color: AppColors.fontColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14)),
//         const SizedBox(height: 5),
//       ],
//     );
//   }

//   Widget _date() {
//     String formattedDate = '';
//     try {
//       DateTime parseDate = DateTime.parse(date);
//       formattedDate = DateFormat('dd MMM').format(parseDate);
//     } catch (e) {
//       formattedDate = date;
//     }
//     return Row(
//       children: [
//         const Icon(Icons.phone_in_talk, color: Colors.blue, size: 14),
//         const SizedBox(width: 5),
//         Text(formattedDate,
//             style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }

//   Widget _buildVerticalDivider(double height) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       height: height,
//       width: 1,
//       decoration: const BoxDecoration(
//           border: Border(right: BorderSide(color: AppColors.fontColor))),
//     );
//   }

//   Widget _buildCarModel() {
//     return Text(
//       vehicle,
//       textAlign: TextAlign.start,
//       style: GoogleFonts.poppins(fontSize: 10, color: AppColors.fontColor),
//       softWrap: true,
//       overflow: TextOverflow.visible,
//     );
//   }
// }
