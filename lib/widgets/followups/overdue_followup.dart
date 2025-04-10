import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/home_btn.dart/lead_old_popup/leads_third.dart';

class OverdueFollowup extends StatefulWidget {
  final bool isNested;
  final List<dynamic> overdueeFollowups;
  final Function(String, bool)? onFavoriteToggle;
  const OverdueFollowup(
      {super.key,
      required this.overdueeFollowups,
      required this.isNested,
      this.onFavoriteToggle});

  @override
  State<OverdueFollowup> createState() => _OverdueFollowupState();
}

class _OverdueFollowupState extends State<OverdueFollowup> {
  bool isLoading = false;
  final Map<String, double> _swipeOffsets = {};
  List<dynamic> overdueFollowups = [];

  @override
  void initState() {
    super.initState();
    print("widget.upcomingFollowups");
    print(widget.overdueeFollowups);
  }

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

  void _handleCall(dynamic item) {
    print("Call action triggered for ${item['name']}");
    // Implement actual call functionality here
  }

  Future<void> _toggleFavorite(String taskId, int index) async {
    final token = await Storage.getToken();
    try {
      // Get the current favorite status before toggling
      bool currentStatus =
          widget.overdueeFollowups[index]['favourite'] ?? false;
      bool newFavoriteStatus = !currentStatus;

      final response = await http.put(
        Uri.parse(
          'https://api.smartassistapp.in/api/favourites/mark-fav/task/$taskId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.overdueeFollowups[index]['favourite'] = newFavoriteStatus;
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

  @override
  Widget build(BuildContext context) {
    if (widget.overdueeFollowups.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('No overdue followups available')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: widget.isNested
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: widget.overdueeFollowups.length,
      itemBuilder: (context, index) {
        var item = widget.overdueeFollowups[index];

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
          child: overdueeFollowupsItem(
            name: item['name'],
            subject: item['subject'] ?? 'call',
            date: item['due_date'],
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

class overdueeFollowupsItem extends StatefulWidget {
  final String name, date, vehicle, leadId, taskId, subject;
  final bool isFavorite;
  final double swipeOffset;
  final VoidCallback fetchDashboardData;
  const overdueeFollowupsItem(
      {super.key,
      required this.name,
      required this.date,
      required this.vehicle,
      required this.leadId,
      required this.taskId,
      required this.isFavorite,
      required this.swipeOffset,
      required this.fetchDashboardData,
      required this.subject});

  @override
  State<overdueeFollowupsItem> createState() => _overdueeFollowupsItemState();
}

class _overdueeFollowupsItemState extends State<overdueeFollowupsItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: _buildOverdueCard(context),
    );
  }

  Widget _buildOverdueCard(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                            : 0.9))  
                    : (isFavoriteSwipe
                        ? Colors.yellow.withOpacity(0.1)
                        : (isCallSwipe
                            ? AppColors.sideRed.withOpacity(0.5)
                            : AppColors.sideRed)),
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
        // const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildSubjectDetails(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.phone_in_talk, color: Colors.blue, size: 18),
        const SizedBox(width: 5),
        Text('${widget.subject},', style: AppFont.smallText(context)),
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
          border: Border(right: BorderSide(color: AppColors.fontColor))),
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
