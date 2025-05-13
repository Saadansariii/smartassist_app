import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/home/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/utils/storage.dart';

class FAppointment extends StatefulWidget {
  const FAppointment({super.key});

  @override
  State<FAppointment> createState() => _FAppointmentState();
}

class _FAppointmentState extends State<FAppointment> {
  bool isLoading = true;
  final Map<String, double> _swipeOffsets = {};
  List<dynamic> upcomingTasks = [];
  List<dynamic> overdueTasks = [];

  void _onHorizontalDragUpdate(DragUpdateDetails details, String eventId) {
    setState(() {
      _swipeOffsets[eventId] =
          (_swipeOffsets[eventId] ?? 0) + (details.primaryDelta ?? 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, dynamic item, int index) {
    String eventId = item['event_id'];
    double swipeOffset = _swipeOffsets[eventId] ?? 0;

    if (swipeOffset > 100) {
      // Right Swipe (Favorite)
      _toggleFavorite(eventId, index);
    } else if (swipeOffset < -100) {
      // Left Swipe (Call)
      _handleCall(item);
    }

    // Reset animation
    setState(() {
      _swipeOffsets[eventId] = 0.0;
    });
  }

  Future<void> _toggleFavorite(String eventId, int index) async {
    final token = await Storage.getToken();
    try {
      // Get the current favorite status before toggling
      bool currentStatus = upcomingTasks[index]['favourite'] ?? false;
      bool newFavoriteStatus = !currentStatus;

      final response = await http.put(
        Uri.parse(
          'https://dev.smartassistapp.in/api/favourites/mark-fav/event/$eventId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response to get the updated favorite status
        final responseData = json.decode(response.body);

        // Update only the specific item in the list
        setState(() {
          upcomingTasks[index]['favourite'] = newFavoriteStatus;
          overdueTasks[index]['favourite'] = newFavoriteStatus;
        });
      } else {
        print('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  void _handleCall(dynamic item) {
    print("Call action triggered for ${item['name']}");
    // Implement actual call functionality here
  }

  @override
  void initState() {
    super.initState();
    fetchTasksData();
  }

  Future<void> fetchTasksData() async {
    final token = await Storage.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/favourites/events/appointments/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          upcomingTasks = data['data']['upcomingAppointments']['rows'] ?? [];
          overdueTasks = data['data']['overdueAppointments']['rows'] ?? [];
          isLoading = false;
          print('this is from FOppointment ${Uri.parse}');
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
        print('this is the api appoinment${Uri}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingTasks.isEmpty && overdueTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Center(child: Text('No data found')),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTasksList(upcomingTasks, isUpcoming: true),
          _buildTasksList(overdueTasks, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<dynamic> tasks, {required bool isUpcoming}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        var item = tasks[index];

        if (!(item.containsKey('assigned_to') &&
            item.containsKey('start_date') &&
            item.containsKey('lead_id') &&
            item.containsKey('event_id'))) {
          return ListTile(title: Text('Invalid data at index $index'));
        }

        String eventId = item['event_id'];
        double swipeOffset = _swipeOffsets[eventId] ?? 0;

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, eventId),
          onHorizontalDragEnd: (details) =>
              _onHorizontalDragEnd(details, item, index),
          child: TaskItem(
            key: ValueKey(item['event_id']),
            name: item['name'],
            subject: item['subject'] ?? 'Meeting',
            date: item['start_date'],
            vehicle: item['PMI'] ?? 'Discovery Sport',
            leadId: item['lead_id'],
            time: item['start_time'],
            eventId: item['event_id'],
            isFavorite: item['favourite'] ?? false,
            swipeOffset: swipeOffset,
            fetchDashboardData: () {},
            onFavoriteToggled: () {},
            isUpcoming: isUpcoming, // Placeholder, replace with actual method
          ),
        );
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  final String name, subject;
  final String date;
  final String vehicle;
  final String leadId;
  final String eventId;
  final bool isFavorite;
  final bool isUpcoming;
  final String time;
  final VoidCallback onFavoriteToggled;
  final double swipeOffset;
  final VoidCallback fetchDashboardData;

  const TaskItem({
    super.key,
    required this.name,
    required this.date,
    required this.vehicle,
    required this.leadId,
    required this.eventId,
    required this.isFavorite,
    required this.isUpcoming,
    required this.onFavoriteToggled,
    required this.time,
    required this.swipeOffset,
    required this.fetchDashboardData,
    required this.subject,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavorite;
  }

  // Future<void> _toggleFavorite() async {
  //   final token = await Storage.getToken();
  //   try {
  //     final response = await http.put(
  //       Uri.parse(
  //         'https://dev.smartassistapp.in/api/favourites/mark-fav/event/${widget.eventId}',
  //       ),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({'eventId': widget.eventId, 'favourite': !isFav}),
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() => isFav = !isFav);
  //       widget.onFavoriteToggled();
  //     }
  //   } catch (e) {
  //     print('Error updating favorite status: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: _buildFollowupCard(context),
    );
  }

  Widget _buildFollowupCard(BuildContext context) {
    bool isFavoriteSwipe = widget.swipeOffset > 50;
    bool isCallSwipe = widget.swipeOffset < -50;
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
                        widget.isFavorite
                            ? Icons.star_outline_rounded
                            : Icons.star_rounded,
                        color: const Color.fromRGBO(226, 195, 34, 1),
                        size: 40),
                    const SizedBox(width: 10),
                    Text(widget.isFavorite ? 'Unfavorite' : 'Favorite',
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
            borderRadius: BorderRadius.circular(5),
            border: Border(
              left: BorderSide(
                width: 8.0,
                color: widget.isFavorite
                    ? (isCallSwipe
                        ? Colors.green
                            .withOpacity(0.9) // Green when swiping for a call
                        : Colors.yellow.withOpacity(isFavoriteSwipe
                            ? 0.1
                            : 0.9)) // Keep yellow when favorite
                    : (isFavoriteSwipe
                        ? Colors.yellow.withOpacity(0.1)
                        : (isCallSwipe
                            ? AppColors.sideGreen.withOpacity(0.5)
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
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            _time(),
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

  Widget _buildUserDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.name, style: AppFont.dashboardName(context)),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildSubjectDetails(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.people_alt_rounded, color: Colors.blue, size: 18),
        const SizedBox(width: 5),
        Text('${widget.subject},', style: AppFont.smallText(context)),
      ],
    );
  }

  Widget _time() {
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(widget.time);
    String formattedTime = DateFormat("ha").format(parsedTime);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Text(formattedTime,
            style: GoogleFonts.poppins(
                color: AppColors.fontColor,
                fontWeight: FontWeight.w400,
                fontSize: 12)),
      ],
    );
  }

  Widget _date(BuildContext context) {
    String formattedDate = '';
    try {
      DateTime parseDate = DateTime.parse(widget.date);
      // formattedDate = DateFormat('dd MMM').format(parseDate);
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
      formattedDate = widget.date;
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
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: height,
      width: 0.1,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.fontColor)),
      ),
    );
  }

  Widget _buildCarModel(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxWidth: 100), // Adjust width as needed
      child: Text(
        widget.vehicle,
        style: AppFont.dashboardCarName(context),
        overflow: TextOverflow.visible, // Allow text wrapping
        softWrap: true, // Enable wrapping
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    // ✅ Accept context
    return GestureDetector(
      onTap: () {
        if (widget.leadId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowupsDetails(leadId: widget.leadId)),
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
}

// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
// import 'package:smart_assist/utils/storage.dart';

// class FAppointment extends StatefulWidget {
//   const FAppointment({super.key});

//   @override
//   State<FAppointment> createState() => _FAppointmentState();
// }

// class _FAppointmentState extends State<FAppointment> {
//   bool isLoading = true;
//   List<dynamic> upcomingTasks = [];
//   List<dynamic> overdueTasks = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchTasksData();
//   }

//   Future<void> fetchTasksData() async {
//     final token = await Storage.getToken();
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://dev.smartassistapp.in/api/favourites/events/appointments/all'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json'
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           upcomingTasks = data['data']['upcomingAppointments']['rows'] ?? [];
//           overdueTasks = data['data']['overdueAppointments']['rows'] ?? [];
//           isLoading = false;
//           print('this is from FOppointment ${Uri.parse}');
//         });
//       } else {
//         print("Failed to load data: ${response.statusCode}");
//         print('this is the api appoinment${Uri}');
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTasksList(upcomingTasks, isUpcoming: true),
//           _buildTasksList(overdueTasks, isUpcoming: false),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(
//     String title,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasksList(List<dynamic> tasks, {required bool isUpcoming}) {
//     if (tasks.isEmpty) {
//       return Center(
//         child: Text(
//             'No ${isUpcoming ? "upcoming" : "overdue"} appointment available'),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {
//         var task = tasks[index];
//         return TaskItem(
//           key: ValueKey(task['event_id']),
//           name: task['name'] ?? 'No Name',
//           date: task['start_date'] ?? 'No Date',
//           vehicle: task['end_date'] ?? 'Discovery Sport',
//           time: task['start_time'] ?? '',
//           leadId: task['lead_id'] ?? '',
//           eventId: task['event_id'] ?? '',
//           isFavorite: task['favourite'] ?? false,
//           isUpcoming: isUpcoming,
//           onFavoriteToggled: fetchTasksData,
//         );
//       },
//     );
//   }
// }

// class TaskItem extends StatefulWidget {
//   final String name;
//   final String date;
//   final String vehicle;
//   final String leadId;
//   final String eventId;
//   final bool isFavorite;
//   final bool isUpcoming;
//   final String time;
//   final VoidCallback onFavoriteToggled;

//   const TaskItem({
//     super.key,
//     required this.name,
//     required this.date,
//     required this.vehicle,
//     required this.leadId,
//     required this.eventId,
//     required this.isFavorite,
//     required this.isUpcoming,
//     required this.onFavoriteToggled,
//     required this.time,
//   });

//   @override
//   State<TaskItem> createState() => _TaskItemState();
// }

// class _TaskItemState extends State<TaskItem> {
//   late bool isFav;

//   @override
//   void initState() {
//     super.initState();
//     isFav = widget.isFavorite;
//   }

//   Future<void> _toggleFavorite() async {
//     final token = await Storage.getToken();
//     try {
//       final response = await http.put(
//         Uri.parse(
//           'https://dev.smartassistapp.in/api/favourites/mark-fav/event/${widget.eventId}',
//         ),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'eventId': widget.eventId, 'favourite': !isFav}),
//       );

//       if (response.statusCode == 200) {
//         setState(() => isFav = !isFav);
//         widget.onFavoriteToggled();
//       }
//     } catch (e) {
//       print('Error updating favorite status: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: AppColors.containerBg,
//           borderRadius: BorderRadius.circular(10),
//           border: Border(
//             left: BorderSide(
//               width: 8.0,
//               color:
//                   widget.isUpcoming ? AppColors.sideGreen : AppColors.sideRed,
//             ),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(
//                 isFav ? Icons.star_rounded : Icons.star_border_rounded,
//                 color: isFav
//                     ? AppColors.starColorsYellow
//                     : AppColors.starBorderColor,
//                 size: 40,
//               ),
//               onPressed: _toggleFavorite,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       _buildUserDetails(),
//                       const SizedBox(width: 8),
//                       _buildVerticalDivider(20),
//                       const SizedBox(width: 8),
//                       _buildCarModel(),
//                     ],
//                   ),
//                   const SizedBox(
//                       height: 4), // Spacing between user details and date-car
//                   Row(
//                     children: [
//                       _date(),
//                       const SizedBox(width: 8),
//                       _time(),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             _buildNavigationButton(context, widget.leadId),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUserDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.name,
//           style: GoogleFonts.poppins(
//               color: AppColors.fontColor,
//               fontWeight: FontWeight.bold,
//               fontSize: 14),
//         ),
//       ],
//     );
//   }

//   Widget _time() {
//     DateTime parsedTime = DateFormat("HH:mm:ss").parse(widget.time);
//     String formattedTime = DateFormat("h:mm a").format(parsedTime);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Icon(Icons.access_time, color: Colors.grey, size: 14),
//         const SizedBox(width: 4),
//         Text(formattedTime,
//             style: GoogleFonts.poppins(
//                 color: AppColors.fontColor,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 12)),
//       ],
//     );
//   }

//   Widget _date() {
//     String formattedDate = '';
//     try {
//       DateTime parseDate = DateTime.parse(widget.date);
//       formattedDate = DateFormat('dd/MM/yyyy').format(parseDate);
//     } catch (e) {
//       formattedDate = widget.date;
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
//       // margin: const EdgeInsets.only(top: 20),
//       height: height,
//       width: 1.5,
//       decoration: const BoxDecoration(
//           border: Border(right: BorderSide(color: AppColors.fontColor))),
//     );
//   }

//   Widget _buildCarModel() {
//     return ConstrainedBox(
//       constraints:
//           const BoxConstraints(maxWidth: 100), // Adjust width as needed
//       child: Text(
//         widget.vehicle,
//         style: GoogleFonts.poppins(fontSize: 10, color: AppColors.fontColor),
//         overflow: TextOverflow.visible, // Allow text wrapping
//         softWrap: true, // Enable wrapping
//       ),
//     );
//   }

//   Widget _buildNavigationButton(BuildContext context, String leadId) {
//     return GestureDetector(
//       onTap: () {
//         if (leadId.isNotEmpty) {
//           print("Navigating with leadId: $leadId");
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FollowupsDetails(leadId: leadId),
//             ),
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
//         child: const Icon(Icons.arrow_forward_ios_sharp,
//             size: 25, color: Colors.white),
//       ),
//     );
//   }
// }
