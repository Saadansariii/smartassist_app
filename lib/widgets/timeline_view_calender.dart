import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/widgets/calender/calender.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarWithTimeline extends StatefulWidget {
  // final String leadId;
  final String leadName;

  const CalendarWithTimeline({
    Key? key,
    // required this.leadId,
    required this.leadName,
  }) : super(key: key);

  @override
  State<CalendarWithTimeline> createState() => _CalendarWithTimelineState();
}

class _CalendarWithTimelineState extends State<CalendarWithTimeline> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isMonthView = false;
  List<dynamic> appointments = [];
  List<dynamic> tasks = [];
  DateTime? _selectedDay;
  bool _isLoading = false;
  ScrollController _timelineScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchInitialData();

    // Scroll to current time when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    // Calculate position to scroll to (current hour * 60 pixels)
    final scrollPosition = (now.hour * 60) +
        (now.minute * 60 / 60) -
        120; // -120 to center the current time

    if (scrollPosition > 0 && _timelineScrollController.hasClients) {
      _timelineScrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching data
    });

    await _fetchAppointments(_selectedDay ?? _focusedDay);
    await _fetchTasks(_selectedDay ?? _focusedDay);

    setState(() {
      _isLoading = false; // Set loading to false once data is fetched
    });
  }

  Future<void> _fetchAppointments(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchAppointments(selectedDate);
    if (!mounted) return;
    setState(() {
      appointments = data;
      _isLoading = false; // Update loading state
    });
    print("Appointments Fetched: $appointments");
  }

  Future<void> _fetchTasks(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchtasks(selectedDate);
    if (!mounted) return;
    setState(() {
      tasks = data;
      _isLoading = false; // Update loading state
    });
    print("Tasks Fetched: $tasks");
  }

  void _handleDateSelected(DateTime selectedDate) {
    // Set the selected date for focusedDay and selectedDay
    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = selectedDate;
      appointments = []; // Clear previous appointments
      tasks = []; // Clear previous tasks
      _isLoading = true; // Set loading to true
    });

    // Log the selected date for debugging
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    print('Selected Date State: ${_selectedDay}'); // Add this debug line
    print('Fetching data for date: $formattedDate');

    // Fetch appointments and tasks based on selected date
    _fetchAppointments(selectedDate);
    _fetchTasks(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: Text(
          'Calendar',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _calendarFormat =
                    _isMonthView ? CalendarFormat.week : CalendarFormat.month;
                _isMonthView = !_isMonthView;
              });
            },
            icon: Icon(
              _isMonthView ? Icons.calendar_view_week : Icons.calendar_month,
              color: Colors.white,
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          // Calendar at the top
          CalenderWidget(
            key: ValueKey(_calendarFormat),
            calendarFormat: _calendarFormat,
            onDateSelected: _handleDateSelected,
          ),
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            child: Text(
              DateFormat('EEEE, MMMM d').format(_selectedDay ?? _focusedDay),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Timeline view
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.blue)) // Show loading spinner
              : Expanded(
                  child:
                      _buildTimelineView()), // Show the timeline once the data is fetched
          // Show the timeline once the data is fetched
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new appointment or task logic here
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTimelineView() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: Colors.blue)); // Show loading spinner
    }

    final combinedItems = [...appointments, ...tasks];
    print(
        "Combined Items: $combinedItems"); // This should print the data of appointments and tasks

// Sort items by start time
    combinedItems.sort((a, b) {
      final aTime = _parseTimeString(a['start_time'] ?? '00:00');
      final bTime = _parseTimeString(b['start_time'] ?? '00:00');
      return aTime.compareTo(bTime);
    });

// Group overlapping appointments
    final groupedItems = _groupOverlappingItems(combinedItems);
    print("Grouped Items: $groupedItems"); // This should print the grouped data

    return SingleChildScrollView(
      child: Row(
        children: [
          // Left time column
          _buildTimeColumn(),
          // Divider line
          Container(width: 1, color: Colors.grey.shade300),
          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Time grid lines
                _buildTimeGridLines(),
                // Current time indicator
                _buildCurrentTimeIndicator(),
                // Render tasks
                ...tasks.map((task) => _buildTaskItem(task)).toList(),
                // Render appointments
                ...appointments
                    .map((appointment) => _buildAppointmentItem(appointment))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(dynamic item,
      {double widthFactor = 1.0, double leftOffset = 0.0}) {
    final startTime = _parseTimeString(item['start_time'] ?? '00:00');
    final endTime = _parseTimeString(item['end_time'] ?? '00:00');

    // Calculate position and height
    final startPosition = _calculateTimePosition(startTime);
    final endPosition = _calculateTimePosition(endTime);
    final height = endPosition - startPosition;

    // Ensure minimum height for items
    final double finalHeight = height < 40 ? 40 : height.toDouble();

    // Determine color and title for appointment
    Color cardColor = _getAppointmentColor(item);

    // Get the lead_id from the item - ensure proper access
    String leadId = item['lead_id']?.toString() ?? '';

    // Debug the leadId value
    print('Appointment leadId: $leadId');

    String title = 'Appointment: ${item['name'] ?? 'No Name'}';
    String time =
        '${item['start_time'] ?? '00:00'} - ${item['end_time'] ?? '00:00'}';

    return Positioned(
      top: startPosition,
      left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
      width: (MediaQuery.of(context).size.width - 59) * widthFactor - 16,
      height: finalHeight, // Use the calculated height instead of fixed 70
      child: Card(
        margin: EdgeInsets.only(bottom: 4, right: 4),
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            print('Navigating with leadId: $leadId'); // Debug navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowupsDetails(
                  leadId: leadId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                if (finalHeight >= 50)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(dynamic item,
      {double widthFactor = 1.0, double leftOffset = 0.0}) {
    // Parse due_date properly - note that your data appears to have only the date, not time
    String dueDate = item['due_date'] ?? '00:00';

    final defaultHour = 9; // Default to 9 AM for tasks without specific time

    // Create a proper DateTime object to calculate position
    DateTime taskTime;
    if (dueDate.contains(':')) {
      // If it has time component already
      taskTime = _parseTimeString(dueDate);
    } else {
      // If it's just a date, add the default time
      taskTime = DateTime(2022, 1, 1, defaultHour, 0);
    }

    // Calculate position
    final taskPosition = _calculateTimePosition(taskTime);

    // Set a fixed height for tasks
    final double taskHeight = 80.0;

    // Get the lead_id from the item - ensure proper access
    String leadId = item['lead_id']?.toString() ?? '';

    // Debug the leadId value
    print('Task leadId: $leadId');

    // Determine color and title for task
    Color cardColor = _getTaskColor(item);
    String title = 'Task: ${item['subject'] ?? 'No Subject'}';
    String status = item['status'] ?? 'Unknown';
    String priority = item['priority'] ?? 'Normal';

    return Positioned(
      top: taskPosition,
      left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
      width: (MediaQuery.of(context).size.width - 59) * widthFactor - 16,
      height: taskHeight, // Use fixed height for tasks
      child: Card(
        margin: const EdgeInsets.only(bottom: 4, right: 4),
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            // Navigate with lead ID to task details
            print('Navigating with task leadId: $leadId');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowupsDetails(
                  leadId: leadId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 12,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 4),
                    Text(
                      priority, // Show priority
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 4),
                    Text(
                      status, // Show status
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Due: ${item['due_date'] ?? 'No date'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildTaskItem(dynamic item,
  //     {double widthFactor = 1.0, double leftOffset = 0.0}) {
  //   // Check for a valid 'due_date', otherwise default to '00:00' for parsing
  //   // final dueDate = item['due_date'] ?? '00:00';
  //   final startTime = _parseTimeString(item['due_date'] ?? '00:00');
  //   final endTime = _parseTimeString(item['due_date'] ?? '00:00');

  //   // Calculate position and height
  //   final startPosition = _calculateTimePosition(startTime);
  //   final endPosition = _calculateTimePosition(endTime);
  //   final height = endPosition - startPosition;

  //   // Ensure minimum height for items
  //   final finalHeight = height < 40 ? 40 : height;

  //   // Get the lead_id from the item - ensure proper access
  //   String leadId = item['lead_id']?.toString() ?? '';

  //   // Determine color and title for task
  //   Color cardColor = _getTaskColor(item);
  //   String title = 'Task: ${item['subject'] ?? 'No Subject'}';
  //   // String time =
  //   //     DateFormat('hh:mm a').format(startTime); // Format due_date as time
  //   String time =
  //       '${item['due_date'] ?? '00:00'} - ${item['due_date'] ?? '00:00'}';

  //   return Positioned(
  //     top: startPosition,
  //     left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
  //     width: (MediaQuery.of(context).size.width - 59) * widthFactor -
  //         16, // Account for padding
  //     height: 70, // Ensure minimum height
  //     child: Card(
  //       margin: const EdgeInsets.only(bottom: 4, right: 4),
  //       color: cardColor,
  //       elevation: 2,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: InkWell(
  //         onTap: () {
  //           print('Navigating with leadId: $leadId'); // Debug navigation
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => FollowupsDetails(
  //                 leadId: leadId,
  //               ),
  //             ),
  //           );
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   Icon(
  //                     Icons.task, // Task icon for tasks
  //                     size: 14,
  //                     color: Colors.white,
  //                   ),
  //                   SizedBox(width: 4),
  //                   Expanded(
  //                     child: Text(
  //                       title,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                         fontSize: 13,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 2),
  //               if (finalHeight >= 50)
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.access_time,
  //                       size: 12,
  //                       color: Colors.white70,
  //                     ),
  //                     SizedBox(width: 4),
  //                     Text(
  //                       time, // Display formatted time
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.white70,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTimeColumn() {
    return Container(
      width: 50,
      child: Column(
        children: List.generate(24, (index) {
          return Container(
            height: 60,
            padding: EdgeInsets.only(right: 8),
            alignment: Alignment.topRight,
            child: Text(
              '${index.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }),
      ),
    );
  }

  // Color _getAppointmentColor(dynamic appointment) {
  //   final type = appointment['type']?.toString().toLowerCase() ?? '';
  //   if (type == 'meeting') {
  //     return Colors.blue;
  //   } else if (type == 'call') {
  //     return Colors.purple;
  //   } else if (type == 'urgent') {
  //     return Colors.red;
  //   } else {
  //     return Colors.teal;
  //   }
  // }

  Widget _buildAppointmentGroup(List<dynamic> group) {
    if (group.length == 1) {
      return _buildAppointmentItem(group[0]);
    }

    return Stack(
      children: List.generate(group.length, (index) {
        final width = 1.0 / group.length;
        final leftPosition = index * width;

        return _buildAppointmentItem(group[index],
            widthFactor: width, leftOffset: leftPosition);
      }),
    );
  }

  Widget _buildTimeGridLines() {
    return Container(
      height: 24 * 60, // 24 hours * 60 pixels per hour
      child: Column(
        children: List.generate(24, (index) {
          return Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getTaskColor(dynamic task) {
    final type = task['taskType']?.toString().toLowerCase() ?? '';
    if (type == 'follow-up' || type == 'followup') {
      return Colors.orange; // Orange for follow-up tasks
    } else if (type == 'urgent') {
      return Colors.red; // Red for urgent tasks
    } else if (type == 'reminder') {
      return Colors.green; // Green for reminders
    } else {
      return Colors.amber.shade700; // Default color for tasks
    }
  }

  Color _getAppointmentColor(dynamic appointment) {
    final type = appointment['type']?.toString().toLowerCase() ?? '';
    if (type == 'meeting') {
      return Colors.blue; // Blue for meetings
    } else if (type == 'call') {
      return Colors.purple; // Purple for calls
    } else if (type == 'urgent') {
      return Colors.red; // Red for urgent appointments
    } else {
      return Colors.teal; // Teal for default appointments
    }
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final isToday = (_selectedDay ?? _focusedDay).year == now.year &&
        (_selectedDay ?? _focusedDay).month == now.month &&
        (_selectedDay ?? _focusedDay).day == now.day;

    if (!isToday) return SizedBox.shrink();

    final position = _calculateTimePosition(now);

    return Positioned(
      top: position,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  List<List<dynamic>> _groupOverlappingItems(List<dynamic> items) {
    if (items.isEmpty) return [];

    List<List<dynamic>> groups = [];
    List<dynamic> currentGroup = [items[0]];

    // Ensure the 'start_time' is not null, default to '00:00' if null
    DateTime currentEndTime =
        _parseTimeString(items[0]['start_time'] ?? '00:00');

    for (int i = 1; i < items.length; i++) {
      // Ensure 'start_time' is not null, default to '00:00' if null
      DateTime itemStartTime =
          _parseTimeString(items[i]['start_time'] ?? '00:00');

      // If this item starts before the current group ends, add to current group
      if (itemStartTime.isBefore(currentEndTime)) {
        currentGroup.add(items[i]);

        // Update end time if this item ends later
        DateTime itemEndTime =
            _parseTimeString(items[i]['end_time'] ?? '00:00');
        if (itemEndTime.isAfter(currentEndTime)) {
          currentEndTime = itemEndTime;
        }
      } else {
        // Start a new group
        groups.add(currentGroup);
        currentGroup = [items[i]];

        // Update currentEndTime to this item's end time
        currentEndTime = _parseTimeString(items[i]['end_time'] ?? '00:00');
      }
    }

    // Add the last group
    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }

  double _calculateTimePosition(DateTime time) {
    final hours = time.hour + (time.minute / 60);
    return hours * 60; // Each hour is 60 pixels
  }

  DateTime _parseTimeString(String timeStr) {
    // If timeStr is null or empty, return a default time
    if (timeStr.isEmpty) {
      return DateTime(2022, 1, 1, 0, 0); // Default time (midnight)
    }

    final parts = timeStr.split(':');
    if (parts.length < 2)
      return DateTime(2022, 1, 1, 0, 0); // Invalid time format fallback

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      // Ignore seconds if present
      return DateTime(2022, 1, 1, hour, minute);
    } catch (e) {
      print("Error parsing time: $timeStr - $e");
      return DateTime(2022, 1, 1, 0, 0); // Default to midnight if parsing fails
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:smart_assist/services/leads_srv.dart';
// import 'package:smart_assist/widgets/calender/calender.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CalendarWithTimeline extends StatefulWidget {
//   final String leadId;
//   final String leadName;

//   const CalendarWithTimeline({
//     Key? key,
//     required this.leadId,
//     required this.leadName,
//   }) : super(key: key);

//   @override
//   State<CalendarWithTimeline> createState() => _CalendarWithTimelineState();
// }

// class _CalendarWithTimelineState extends State<CalendarWithTimeline> {
//   DateTime _focusedDay = DateTime.now();
//   CalendarFormat _calendarFormat = CalendarFormat.week;
//   bool _isMonthView = false;
//   List<dynamic> appointments = [];
//   List<dynamic> tasks = [];
//   DateTime? _selectedDay;
//   ScrollController _timelineScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = _focusedDay;
//     _fetchInitialData();

//     // Scroll to current time when view loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToCurrentTime();
//     });
//   }

//   @override
//   void dispose() {
//     _timelineScrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToCurrentTime() {
//     final now = DateTime.now();
//     // Calculate position to scroll to (current hour * 60 pixels)
//     final scrollPosition = (now.hour * 60) +
//         (now.minute * 60 / 60) -
//         120; // -120 to center the current time

//     if (scrollPosition > 0 && _timelineScrollController.hasClients) {
//       _timelineScrollController.animateTo(
//         scrollPosition,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Future<void> _fetchInitialData() async {
//     await _fetchAppointments(_selectedDay ?? _focusedDay);
//     await _fetchTasks(_selectedDay ?? _focusedDay);
//   }

//   Future<void> _fetchAppointments(DateTime selectedDate) async {
//     final data = await LeadsSrv.fetchAppointments(selectedDate);
//     if (!mounted) return;
//     setState(() {
//       appointments = data;
//     });
//   }

//   Future<void> _fetchTasks(DateTime? selectedDate) async {
//     final DateTime finalDate = selectedDate ?? DateTime.now();
//     final data = await LeadsSrv.fetchtasks(finalDate);
//     if (!mounted) return;
//     setState(() {
//       tasks = data;
//     });
//   }

//   // Handle date selection
//   void _handleDateSelected(DateTime selectedDate) {
//     setState(() {
//       _selectedDay = selectedDate;
//       _focusedDay = selectedDate;
//     });

//     _fetchAppointments(selectedDate);
//     _fetchTasks(selectedDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Calendar',
//           style: GoogleFonts.poppins(
//               fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 _calendarFormat =
//                     _isMonthView ? CalendarFormat.week : CalendarFormat.month;
//                 _isMonthView = !_isMonthView;
//               });
//             },
//             icon: Icon(
//               _isMonthView ? Icons.calendar_view_week : Icons.calendar_month,
//               color: Colors.white,
//             ),
//           ),
//           IconButton(
//               onPressed: () {},
//               icon: const Icon(Icons.search, color: Colors.white)),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Calendar at the top
//           CalenderWidget(
//             key: ValueKey(_calendarFormat),
//             calendarFormat: _calendarFormat,
//             onDateSelected: _handleDateSelected,
//           ),

//           // Date header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             width: double.infinity,
//             child: Text(
//               DateFormat('EEEE, MMMM d').format(_selectedDay ?? _focusedDay),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // Timeline view
//           Expanded(
//             child: _buildTimelineView(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Add new appointment or task logic here
//         },
//         child: const Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   Widget _buildTimelineView() {
//     // Combine appointments and tasks for the timeline
//     final combinedItems = [...appointments, ...tasks];

//     // Process items to ensure they have correct time format (keep your existing code)
//     // ...

//     // Sort items by start time
//     combinedItems.sort((a, b) {
//       final aTime = _parseTimeString(a['start_time']);
//       final bTime = _parseTimeString(b['start_time']);
//       return aTime.compareTo(bTime);
//     });

//     // Group overlapping appointments
//     final groupedItems = _groupOverlappingItems(combinedItems);

//     return Row(
//       children: [
//         // Left time column
//         _buildTimeColumn(),

//         // Divider line
//         Container(
//           width: 1,
//           color: Colors.grey.shade300,
//         ),

//         // Main content area
//         Expanded(
//           child: SingleChildScrollView(
//             controller: _timelineScrollController,
//             physics: ClampingScrollPhysics(), // Better scroll physics
//             child: Stack(
//               children: [
//                 // Time grid lines
//                 _buildTimeGridLines(),

//                 // Current time indicator
//                 _buildCurrentTimeIndicator(),

//                 // Render grouped appointments
//                 ...groupedItems
//                     .map((group) => _buildAppointmentGroup(group))
//                     .toList(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

// // Group overlapping items
//   List<List<dynamic>> _groupOverlappingItems(List<dynamic> items) {
//     if (items.isEmpty) return [];

//     List<List<dynamic>> groups = [];
//     List<dynamic> currentGroup = [items[0]];
//     DateTime currentEndTime = _parseTimeString(items[0]['start_time']);

//     for (int i = 1; i < items.length; i++) {
//       DateTime itemStartTime = _parseTimeString(items[i]['start_time']);

//       // If this item starts before the current group ends, add to current group
//       if (itemStartTime.isBefore(currentEndTime)) {
//         currentGroup.add(items[i]);
//         // Update end time if this item ends later
//         DateTime itemEndTime = _parseTimeString(items[i]['start_time']);
//         if (itemEndTime.isAfter(currentEndTime)) {
//           currentEndTime = itemEndTime;
//         }
//       } else {
//         // Start a new group
//         groups.add(currentGroup);
//         currentGroup = [items[i]];
//         currentEndTime = _parseTimeString(items[i]['start_time']);
//       }
//     }

//     // Add the last group
//     if (currentGroup.isNotEmpty) {
//       groups.add(currentGroup);
//     }

//     return groups;
//   }

// // Build a group of potentially overlapping appointments
//   Widget _buildAppointmentGroup(List<dynamic> group) {
//     // For a single item, just use the existing method
//     if (group.length == 1) {
//       return _buildAppointmentItem(group[0]);
//     }

//     // For multiple items, distribute them horizontally
//     return Stack(
//       children: List.generate(group.length, (index) {
//         // Calculate width and position for each item
//         final width = 1.0 / group.length;
//         final leftPosition = index * width;

//         return _buildAppointmentItem(group[index],
//             widthFactor: width, leftOffset: leftPosition);
//       }),
//     );
//   }

// // Modified appointment item builder to handle width constraints
//   Widget _buildAppointmentItem(dynamic item,
//       {double widthFactor = 1.0, double leftOffset = 0.0}) {
//     final startTime = _parseTimeString(item['start_time']);
//     final endTime = _parseTimeString(item['end_time']);

//     // Calculate position and height
//     final startPosition = _calculateTimePosition(startTime);
//     final endPosition = _calculateTimePosition(endTime);
//     final height = endPosition - startPosition;

//     // Check for minimum height (avoid very small events)
//     final finalHeight = height < 40 ? 40 : height;

//     // Check if it's an appointment or task
//     final isTask = item.containsKey('taskType') ||
//         (item.containsKey('subject') && !item.containsKey('type'));

//     // Determine color based on type
//     Color cardColor = isTask ? _getTaskColor(item) : _getAppointmentColor(item);

//     return Positioned(
//       top: startPosition,
//       left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
//       width: (MediaQuery.of(context).size.width - 59) * widthFactor -
//           16, // Account for padding
//       height: 60, // Ensure minimum height
//       child: Card(
//         margin: EdgeInsets.only(bottom: 4, right: 4),
//         color: cardColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: InkWell(
//           onTap: () {
//             // Handle item tap
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       isTask ? Icons.task : Icons.event,
//                       size: 14,
//                       color: Colors.white,
//                     ),
//                     SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         item['name'] ??
//                             item['title'] ??
//                             (isTask ? 'Task' : 'Appointment'),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontSize: 13,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 2),
//                 if (finalHeight >= 50)
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.access_time,
//                         size: 12,
//                         color: Colors.white70,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         '${item['start_time']} - ${item['end_time']}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 if (finalHeight >= 70 && item['subject'] != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2.0),
//                     child: Text(
//                       item['subject'],
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildTimelineView() {
//   //   // Combine appointments and tasks for the timeline
//   //   final combinedItems = [...appointments, ...tasks];

//   //   // Process items to ensure they have the correct time format
//   //   for (var item in combinedItems) {
//   //     if (item.containsKey('start_time') && !item.containsKey('startTime')) {
//   //       // Convert from API format to display format if needed
//   //       try {
//   //         final startDateTime = DateTime.parse(item['start_time']);
//   //         item['startTime'] = DateFormat('HH:mm').format(startDateTime);
//   //       } catch (e) {
//   //         item['startTime'] = '00:00';
//   //       }
//   //     }

//   //     if (item.containsKey('end_date') && !item.containsKey('endTime')) {
//   //       try {
//   //         final endDateTime = DateTime.parse(item['end_date']);
//   //         item['endTime'] = DateFormat('HH:mm').format(endDateTime);
//   //       } catch (e) {
//   //         item['endTime'] = '01:00';
//   //       }
//   //     }

//   //     // Default values if still missing
//   //     item['startTime'] ??= '00:00';
//   //     item['endTime'] ??= '01:00';
//   //   }

//   //   // Sort items by start time
//   //   combinedItems.sort((a, b) {
//   //     final aTime = _parseTimeString(a['startTime']);
//   //     final bTime = _parseTimeString(b['startTime']);
//   //     return aTime.compareTo(bTime);
//   //   });

//   //   return Row(
//   //     children: [
//   //       // Left time column
//   //       _buildTimeColumn(),

//   //       // Divider line
//   //       Container(
//   //         width: 1,
//   //         color: Colors.grey.shade300,
//   //       ),

//   //       // Main content area
//   //       Expanded(
//   //         child: SingleChildScrollView(
//   //           controller: _timelineScrollController,
//   //           child: Stack(
//   //             children: [
//   //               // Time grid lines
//   //               _buildTimeGridLines(),

//   //               // Current time indicator
//   //               _buildCurrentTimeIndicator(),

//   //               // Appointments and tasks
//   //               ...combinedItems
//   //                   .map((item) => _buildAppointmentItem(item))
//   //                   .toList(),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // Widget _buildTimeColumn() {
//   //   return Container(
//   //     width: 50,
//   //     child: SingleChildScrollView(
//   //       controller: _timelineScrollController,
//   //       child: Column(
//   //         children: List.generate(24, (index) {
//   //           return Container(
//   //             height: 60,
//   //             padding: EdgeInsets.only(right: 8),
//   //             alignment: Alignment.topRight,
//   //             child: Text(
//   //               '${index.toString().padLeft(2, '0')}:00',
//   //               style: TextStyle(
//   //                 fontSize: 12,
//   //                 color: Colors.grey.shade600,
//   //               ),
//   //             ),
//   //           );
//   //         }),
//   //       ),
//   //     ),
//   //   );
//   // }

// // In the _buildTimeColumn method:
//   Widget _buildTimeColumn() {
//     return Container(
//       width: 50,
//       child: SingleChildScrollView(
//         controller:
//             _timelineScrollController, // Same controller as main content
//         physics:
//             ClampingScrollPhysics(), // Add this for better scroll experience
//         child: Column(
//           children: List.generate(24, (index) {
//             return Container(
//               height: 60,
//               padding: EdgeInsets.only(right: 8),
//               alignment: Alignment.topRight,
//               child: Text(
//                 '${index.toString().padLeft(2, '0')}:00',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeGridLines() {
//     return Container(
//       height: 24 * 60, // 24 hours * 60 pixels per hour
//       child: Column(
//         children: List.generate(24, (index) {
//           return Container(
//             height: 60,
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey.shade200,
//                   width: 1,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildCurrentTimeIndicator() {
//     // Only show indicator if selected date is today
//     final now = DateTime.now();
//     final isToday = (_selectedDay ?? _focusedDay).year == now.year &&
//         (_selectedDay ?? _focusedDay).month == now.month &&
//         (_selectedDay ?? _focusedDay).day == now.day;

//     if (!isToday) return SizedBox.shrink();

//     final position = _calculateTimePosition(now);

//     return Positioned(
//       top: position,
//       left: 0,
//       right: 0,
//       child: Container(
//         height: 2,
//         color: Colors.red,
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.red,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildAppointmentItem(dynamic item) {
//   //   final startTime = _parseTimeString(item['startTime']);
//   //   final endTime = _parseTimeString(item['endTime']);

//   //   // Calculate position and height
//   //   final startPosition = _calculateTimePosition(startTime);
//   //   final endPosition = _calculateTimePosition(endTime);
//   //   final height = endPosition - startPosition;

//   //   // Check if it's an appointment or task
//   //   final isTask = item.containsKey('taskType') ||
//   //       (item.containsKey('subject') && !item.containsKey('type'));

//   //   // Determine color based on type
//   //   Color cardColor = isTask ? _getTaskColor(item) : _getAppointmentColor(item);

//   //   return Positioned(
//   //     top: startPosition,
//   //     left: 8,
//   //     right: 8,
//   //     height: height < 40 ? 40 : height, // Minimum height
//   //     child: Card(
//   //       margin: EdgeInsets.only(bottom: 4),
//   //       color: cardColor,
//   //       elevation: 2,
//   //       shape: RoundedRectangleBorder(
//   //         borderRadius: BorderRadius.circular(8),
//   //       ),
//   //       child: InkWell(
//   //         onTap: () {
//   //           // Handle item tap
//   //         },
//   //         child: Padding(
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Row(
//   //                 children: [
//   //                   Icon(
//   //                     isTask ? Icons.task : Icons.event,
//   //                     size: 14,
//   //                     color: Colors.white,
//   //                   ),
//   //                   SizedBox(width: 4),
//   //                   Expanded(
//   //                     child: Text(
//   //                       item['name'] ??
//   //                           item['title'] ??
//   //                           (isTask ? 'Task' : 'Appointment'),
//   //                       style: TextStyle(
//   //                         fontWeight: FontWeight.bold,
//   //                         color: Colors.white,
//   //                         fontSize: 13,
//   //                       ),
//   //                       maxLines: 1,
//   //                       overflow: TextOverflow.ellipsis,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               SizedBox(height: 2),
//   //               if (height >= 50)
//   //                 Row(
//   //                   children: [
//   //                     Icon(
//   //                       Icons.access_time,
//   //                       size: 12,
//   //                       color: Colors.white70,
//   //                     ),
//   //                     SizedBox(width: 4),
//   //                     Text(
//   //                       '${item['startTime']} - ${item['endTime']}',
//   //                       style: TextStyle(
//   //                         fontSize: 12,
//   //                         color: Colors.white70,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               if (height >= 70 && item['subject'] != null)
//   //                 Padding(
//   //                   padding: const EdgeInsets.only(top: 2.0),
//   //                   child: Text(
//   //                     item['subject'],
//   //                     style: TextStyle(
//   //                       fontSize: 12,
//   //                       color: Colors.white70,
//   //                     ),
//   //                     maxLines: 1,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                 ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Get color for appointments
//   Color _getAppointmentColor(dynamic appointment) {
//     final type = appointment['type']?.toString().toLowerCase() ?? '';

//     if (type == 'meeting') {
//       return Colors.blue;
//     } else if (type == 'call') {
//       return Colors.purple;
//     } else if (type == 'urgent') {
//       return Colors.red;
//     } else {
//       return Colors.teal;
//     }
//   }

//   // Get color for tasks
//   Color _getTaskColor(dynamic task) {
//     final type = task['taskType']?.toString().toLowerCase() ?? '';

//     if (type == 'follow-up' || type == 'followup') {
//       return Colors.orange;
//     } else if (type == 'urgent') {
//       return Colors.red;
//     } else if (type == 'reminder') {
//       return Colors.green;
//     } else {
//       return Colors.amber.shade700;
//     }
//   }

//   // Parse time string (HH:MM) to DateTime
//   DateTime _parseTimeString(String timeStr) {
//     final parts = timeStr.split(':');
//     if (parts.length < 2) return DateTime(2022, 1, 1, 0, 0);

//     try {
//       final hour = int.parse(parts[0]);
//       final minute = int.parse(parts[1]);
//       return DateTime(2022, 1, 1, hour, minute);
//     } catch (e) {
//       return DateTime(2022, 1, 1, 0, 0);
//     }
//   }

//   // Calculate vertical position based on time
//   double _calculateTimePosition(DateTime time) {
//     final hours = time.hour + (time.minute / 60);
//     return hours * 60; // Each hour is 60 pixels
//   }
// }
