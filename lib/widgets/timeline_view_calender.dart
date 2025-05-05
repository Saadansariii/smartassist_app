import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/widgets/calender/calender.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarWithTimeline extends StatefulWidget {
  final String leadName;

  const CalendarWithTimeline({
    Key? key,
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

  // Track active hours (hours with data)
  Set<int> _activeHours = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchInitialData();

    // Scroll to first active hour when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstActiveHour();
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstActiveHour() {
    if (_activeHours.isEmpty || !_timelineScrollController.hasClients) return;

    // Find the earliest active hour
    final earliestHour = _activeHours.reduce((a, b) => a < b ? a : b);

    // Scroll to that hour position (with a small offset for better visibility)
    final scrollPosition =
        earliestHour * 60 - 30; // 30px offset for better visibility

    if (scrollPosition >= 0) {
      _timelineScrollController.animateTo(
        scrollPosition as double,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchInitialData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _fetchAppointments(_selectedDay ?? _focusedDay);
      await _fetchTasks(_selectedDay ?? _focusedDay);
      _updateActiveHours();
    } catch (e) {
      print("Error fetching initial data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateActiveHours() {
    _activeHours.clear();

    // Add hours from appointments
    for (var appointment in appointments) {
      final startTime = _parseTimeString(appointment['start_time'] ?? '00:00');
      final endTime = _parseTimeString(appointment['end_time'] ?? '00:00');

      // Add all hours covered by this appointment
      for (int hour = startTime.hour; hour <= endTime.hour; hour++) {
        _activeHours.add(hour);
      }
    }

    // Add hours from tasks
    for (var task in tasks) {
      String dueDate = task['due_date'] ?? '00:00';
      DateTime taskTime;

      if (dueDate.contains(':')) {
        taskTime = _parseTimeString(dueDate);
      } else {
        taskTime = DateTime(2022, 1, 1, 9, 0); // Default to 9 AM
      }

      _activeHours.add(taskTime.hour);
    }

    // If no active hours are found, add current hour as default
    if (_activeHours.isEmpty) {
      _activeHours.add(DateTime.now().hour);
    }

    print("Active hours: $_activeHours");
  }

  Future<void> _fetchAppointments(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchAppointments(selectedDate);
    if (!mounted) return;
    setState(() {
      appointments = data;
      _isLoading = false;
    });
    print("Appointments Fetched: $appointments");
    _updateActiveHours();
  }

  Future<void> _fetchTasks(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchtasks(selectedDate);
    if (!mounted) return;
    setState(() {
      tasks = data;
      _isLoading = false;
    });
    print("Tasks Fetched: $tasks");
    _updateActiveHours();
  }

  void _handleDateSelected(DateTime selectedDate) {
    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = selectedDate;
      appointments = [];
      tasks = [];
      _activeHours.clear();
      _isLoading = true;
    });

    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    print('Selected Date State: ${_selectedDay}');
    print('Fetching data for date: $formattedDate');

    _fetchAppointments(selectedDate);
    _fetchTasks(selectedDate);
  }

  // Initialize the controller
  final FabController fabController = Get.put(FabController());

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
        ],
      ),
      body: Stack(children: [
        Column(
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Timeline view
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue))
                : Expanded(child: _buildCompactTimelineView()),
          ],
        ),
      ]),
    );
  }

  Widget _buildCompactTimelineView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    final combinedItems = [...appointments, ...tasks];
    if (combinedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No activities scheduled for this day',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort items by start time
    combinedItems.sort((a, b) {
      final aTime = _parseTimeString(a['start_time'] ?? '00:00');
      final bTime = _parseTimeString(b['start_time'] ?? '00:00');
      return aTime.compareTo(bTime);
    });

    // Group overlapping appointments
    final groupedItems = _groupOverlappingItems(combinedItems);

    // Get sorted list of active hours for timeline
    final sortedHours = _activeHours.toList()..sort();

    return SingleChildScrollView(
      controller: _timelineScrollController,
      child: Row(
        children: [
          // Left time column - only shows active hours
          _buildCompactTimeColumn(sortedHours),

          // Divider line
          Container(width: 1, color: Colors.grey.shade300),

          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Time grid lines for active hours only
                _buildCompactTimeGridLines(sortedHours),

                // Render tasks
                // ...tasks.map((task) => _buildTaskItem(task)).toList(),
                ..._buildPositionedTaskItems(tasks),

                // Render appointments
                ..._buildPositionedAppointments(appointments),
                // ...appointments
                //     .map((appointment) => _buildAppointmentItem(appointment))
                //     .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimeColumn(List<int> activeHours) {
    return Container(
      width: 50,
      child: Column(
        children: activeHours.map((hour) {
          return Container(
            height: 60,
            padding: EdgeInsets.only(right: 8),
            alignment: Alignment.topRight,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactTimeGridLines(List<int> activeHours) {
    return Column(
      children: activeHours.map((hour) {
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
      }).toList(),
    );
  }

  List<Widget> _buildPositionedAppointments(List<dynamic> appointments) {
    // Group appointments by their start_time
    Map<String, List<dynamic>> groupedAppointments = {};

    for (var appointment in appointments) {
      final key = appointment['start_time'] ?? '00:00';
      groupedAppointments.putIfAbsent(key, () => []).add(appointment);
    }

    List<Widget> widgets = [];
    const double verticalSpacing = 62;

    for (var group in groupedAppointments.entries) {
      final groupList = group.value;
      final count = groupList.length;

      for (int i = 0; i < count; i++) {
        final appointment = groupList[i];

        widgets.add(_buildAppointmentItem(
          appointment,
          verticalOffset: i * verticalSpacing,
        ));
      }
    }

    return widgets;
  }

  Widget _buildAppointmentItem(
    dynamic item, {
    double widthFactor = 1.0,
    double leftOffset = 0.0,
    double verticalOffset = 0.0,
  }) {
    final startTime = _parseTimeString(item['start_time'] ?? '00:00');
    final endTime = _parseTimeString(item['end_time'] ?? '00:00');

    // For compact timeline, we need to position relative to the active hours
    List<int> sortedHours = _activeHours.toList()..sort();
    final startHourIndex = sortedHours.indexOf(startTime.hour);

    if (startHourIndex < 0)
      return SizedBox.shrink(); // Skip if hour isn't in active list

    // Calculate position and height
    final startPosition = startHourIndex * 60 + (startTime.minute / 60) * 60;

    // Calculate end position based on end hour position in active hours
    double endPosition;
    final endHourIndex = sortedHours.indexOf(endTime.hour);

    if (endHourIndex >= 0) {
      // If end hour is in active hours
      endPosition = endHourIndex * 60 + (endTime.minute / 60) * 60;
    } else {
      // If end hour isn't in active hours, find the next active hour after this one
      int nextActiveHourIndex =
          sortedHours.indexWhere((h) => h > startTime.hour);
      if (nextActiveHourIndex >= 0) {
        endPosition = nextActiveHourIndex * 60;
      } else {
        // Default to 1 hour if no next active hour
        endPosition = startPosition + 60;
      }
    }

    final height = endPosition - startPosition;

    // Ensure minimum height for items
    final double finalHeight = height < 40 ? 40 : height.toDouble();

    // Determine color and title for appointment
    Color cardColor = _getAppointmentColor(item);

    // Get the lead_id from the item - ensure proper access
    String leadId = item['lead_id']?.toString() ?? '';

    String title = 'Appointment: ${item['name'] ?? 'No Name'}';
    String time =
        '${item['start_time'] ?? '00:00'} - ${item['end_time'] ?? '00:00'}';

    return Positioned(
      top: startPosition + verticalOffset,
      left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
      width: (MediaQuery.of(context).size.width - 59) * widthFactor - 16,
      height: finalHeight,
      child: Card(
        margin: EdgeInsets.only(bottom: 4, right: 4),
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            print('Navigating with leadId: $leadId');
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
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
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
                const SizedBox(height: 2),
                if (finalHeight >= 50)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
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



  List<Widget> _buildPositionedTaskItems(List<dynamic> tasks) {
    // Group tasks by their due date string
    Map<String, List<dynamic>> groupedTasks = {};

    for (var task in tasks) {
      final key = task['due_date'] ?? '00:00';
      groupedTasks.putIfAbsent(key, () => []).add(task);
    }

    List<Widget> widgets = [];

    const double verticalSpacing = 62;

    for (var group in groupedTasks.entries) {
      final groupTasks = group.value;
      final count = groupTasks.length;

      for (int i = 0; i < count; i++) {
        final task = groupTasks[i];

        // Calculate how much width each should take
        final widthFactor = 1.0 / count;
        final leftOffset = i * widthFactor;

        widgets.add(_buildTaskItem(
          task,
          verticalOffset: i * verticalSpacing,
          // widthFactor: widthFactor,
          // leftOffset: leftOffset,
        ));
      }
    }

    return widgets;
  }

  Widget _buildTaskItem(

    dynamic item, {
    double widthFactor = 1.0,
    double leftOffset = 0.0,
    double verticalOffset = 0.0,
  }) {
    // Parse due_date properly
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

    // For compact timeline, position based on the active hours list
    List<int> sortedHours = _activeHours.toList()..sort();
    final hourIndex = sortedHours.indexOf(taskTime.hour);

    if (hourIndex < 0)
      return SizedBox.shrink(); // Skip if hour isn't in active list

    // Calculate position based on hour index in active hours
    final taskPosition = hourIndex * 60 + (taskTime.minute / 60) * 60;

    // Set a fixed height for tasks
    final double taskHeight = 60.0;

    // Get the lead_id from the item - ensure proper access
    String leadId = item['lead_id']?.toString() ?? '';

    // Determine color and title for task
    Color cardColor = _getTaskColor(item);
    String title = 'Task: ${item['subject'] ?? 'No Subject'}';
    String status = item['status'] ?? 'Unknown';
    String priority = item['priority'] ?? 'Normal';

    return Positioned(
      top: taskPosition + verticalOffset,
      left: 8 + (MediaQuery.of(context).size.width - 59) * leftOffset,
      width: (MediaQuery.of(context).size.width - 59) * widthFactor - 16,
      height: taskHeight,
      child: Card(
        margin: const EdgeInsets.only(bottom: 4, right: 4),
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
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
               const SizedBox(height: 2),
                Row(
                  children: [
                  const  Icon(
                      Icons.flag,
                      size: 12,
                      color: Colors.white70,
                    ),
                  const  SizedBox(width: 4),
                    Text(
                      priority,
                      style:const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  const  SizedBox(width: 8),
                  const  Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.white70,
                    ),
                   const SizedBox(width: 4),
                    Text(
                      status,
                      style:const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 2),
                // Text(
                //   'Due: ${item['due_date'] ?? 'No date'}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.white70,
                //   ),
                // ),
              ],
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

  Color _getTaskColor(dynamic task) {
    final type = task['taskType']?.toString().toLowerCase() ?? '';
    if (type == 'follow-up' || type == 'followup') {
      return AppColors.colorsBlue; // Orange for follow-up tasks
    } else if (type == 'urgent') {
      return Colors.red; // Red for urgent tasks
    } else if (type == 'reminder') {
      return Colors.green; // Green for reminders
    } else {
      return AppColors.colorsBlueButton; // Default color for tasks
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

  List<Widget> _buildTimelineItems(List<dynamic> appointmentsAndTasks) {
    final groupedItems = _groupOverlappingItems(appointmentsAndTasks);

    List<Widget> positionedItems = [];

    for (var group in groupedItems) {
      final count = group.length;
      for (int i = 0; i < count; i++) {
        var item = group[i];

        double widthFactor = 1.0 / count;
        double leftOffset = i * widthFactor;

        // Determine if it's an appointment or task
        if (item.containsKey('start_time')) {
          positionedItems.add(
            _buildAppointmentItem(item,
                widthFactor: widthFactor, leftOffset: leftOffset),
          );
        } else {
          positionedItems.add(
            _buildTaskItem(item,
                widthFactor: widthFactor, leftOffset: leftOffset),
          );
        }
      }
    }

    return positionedItems;
  }

  // Widget _buildCurrentTimeIndicator() {
  //   final now = DateTime.now();
  //   final isToday = (_selectedDay ?? _focusedDay).year == now.year &&
  //       (_selectedDay ?? _focusedDay).month == now.month &&
  //       (_selectedDay ?? _focusedDay).day == now.day;

  //   if (!isToday) return SizedBox.shrink();

  //   final position = _calculateTimePosition(now);

  //   return Positioned(
  //     top: position,
  //     left: 0,
  //     right: 0,
  //     child: Container(
  //       height: 2,
  //       color: Colors.red,
  //       child: Align(
  //         alignment: Alignment.centerLeft,
  //         child: Container(
  //           width: 8,
  //           height: 8,
  //           decoration: BoxDecoration(
  //             color: Colors.red,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // List<List<dynamic>> _groupOverlappingItems(List<dynamic> items) {
  //   if (items.isEmpty) return [];

  //   List<List<dynamic>> groups = [];
  //   List<dynamic> currentGroup = [items[0]];

  //   // Ensure the 'start_time' is not null, default to '00:00' if null
  //   DateTime currentEndTime =
  //       _parseTimeString(items[0]['start_time'] ?? '00:00');

  //   for (int i = 1; i < items.length; i++) {
  //     // Ensure 'start_time' is not null, default to '00:00' if null
  //     DateTime itemStartTime =
  //         _parseTimeString(items[i]['start_time'] ?? '00:00');

  //     // If this item starts before the current group ends, add to current group
  //     if (itemStartTime.isBefore(currentEndTime)) {
  //       currentGroup.add(items[i]);

  //       // Update end time if this item ends later
  //       DateTime itemEndTime =
  //           _parseTimeString(items[i]['end_time'] ?? '00:00');
  //       if (itemEndTime.isAfter(currentEndTime)) {
  //         currentEndTime = itemEndTime;
  //       }
  //     } else {
  //       // Start a new group
  //       groups.add(currentGroup);
  //       currentGroup = [items[i]];

  //       // Update currentEndTime to this item's end time
  //       currentEndTime = _parseTimeString(items[i]['end_time'] ?? '00:00');
  //     }
  //   }

  //   // Add the last group
  //   if (currentGroup.isNotEmpty) {
  //     groups.add(currentGroup);
  //   }

  //   return groups;
  // }

  // double _calculateTimePosition(DateTime time) {
  //   final hours = time.hour + (time.minute / 60);
  //   return hours * 60; // Each hour is 60 pixels
  // }

  // DateTime _parseTimeString(String timeStr) {
  //   // If timeStr is null or empty, return a default time
  //   if (timeStr.isEmpty) {
  //     return DateTime(2022, 1, 1, 0, 0); // Default time (midnight)
  //   }

  //   final parts = timeStr.split(':');
  //   if (parts.length < 2)
  //     return DateTime(2022, 1, 1, 0, 0); // Invalid time format fallback

  //   try {
  //     final hour = int.parse(parts[0]);
  //     final minute = int.parse(parts[1]);
  //     // Ignore seconds if present
  //     return DateTime(2022, 1, 1, hour, minute);
  //   } catch (e) {
  //     print("Error parsing time: $timeStr - $e");
  //     return DateTime(2022, 1, 1, 0, 0); // Default to midnight if parsing fails
  //   }
  // }
}
