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

  // Track all hours (0-23) for a complete timeline
  List<int> _allHours = List.generate(24, (index) => index);
  
  // Track active hours (hours with data)
  Set<int> _activeHours = {};
  
  // Map to track expanded hour slots
  Map<int, int> _expandedHours = {};
  
  // Map to track items by exact time (hour:minute)
  Map<String, List<dynamic>> _timeSlotItems = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchInitialData();

    // Scroll to current hour when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentHour() {
    if (!_timelineScrollController.hasClients) return;

    // Get current hour
    final currentHour = DateTime.now().hour;
    
    // Calculate scroll position - 60 pixels per hour
    double scrollPosition = currentHour * 60.0;
    
    // Subtract a small offset for better visibility
    scrollPosition = scrollPosition > 60 ? scrollPosition - 60 : 0;

    _timelineScrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
      _processTimeSlots();
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

  // New method to process all items into time slots
  void _processTimeSlots() {
    _activeHours.clear();
    _expandedHours.clear();
    _timeSlotItems.clear();
    
    // Process appointments
    for (var appointment in appointments) {
      final startTime = _parseTimeString(appointment['start_time'] ?? '00:00');
      final endTime = _parseTimeString(appointment['end_time'] ?? '00:00');
      
      // Mark all hours covered by this appointment as active
      for (int hour = startTime.hour; hour <= endTime.hour; hour++) {
        _activeHours.add(hour);
      }
      
      // Add to time slot map
      final timeKey = '${startTime.hour}:${startTime.minute}';
      if (!_timeSlotItems.containsKey(timeKey)) {
        _timeSlotItems[timeKey] = [];
      }
      _timeSlotItems[timeKey]!.add({
        'item': appointment,
        'type': 'appointment',
        'startTime': startTime,
        'endTime': endTime
      });
    }
    
    // Process tasks
    for (var task in tasks) {
      String dueDate = task['due_date'] ?? '00:00';
      DateTime taskTime;

      if (dueDate.contains(':')) {
        taskTime = _parseTimeString(dueDate);
      } else {
        taskTime = DateTime(2022, 1, 1, 9, 0); // Default to 9 AM
      }
      
      _activeHours.add(taskTime.hour);
      
      // Add to time slot map
      final timeKey = '${taskTime.hour}:${taskTime.minute}';
      if (!_timeSlotItems.containsKey(timeKey)) {
        _timeSlotItems[timeKey] = [];
      }
      _timeSlotItems[timeKey]!.add({
        'item': task,
        'type': 'task',
        'startTime': taskTime,
        'endTime': taskTime.add(Duration(minutes: 30)) // Default task duration
      });
    }
    
    // Only add current hour if no active hours AND we're on today's date
    if (_activeHours.isEmpty) {
      // Only add current hour if we're viewing today
      if (_isSameDay(_selectedDay ?? _focusedDay, DateTime.now())) {
        _activeHours.add(DateTime.now().hour);
      } else {
        // For empty days not today, add a default business hour (9 AM)
        _activeHours.add(9);
      }
    }
    
    // Calculate expanded hours
    _calculateExpandedHours();
    
    print("Active hours: $_activeHours");
    print("Time slots: ${_timeSlotItems.keys.length}");
  }
  
  // Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  void _calculateExpandedHours() {
    _expandedHours.clear();
    
    // Count items per hour
    Map<int, int> itemsPerHour = {};
    
    _timeSlotItems.forEach((timeKey, items) {
      final hour = int.parse(timeKey.split(':')[0]);
      itemsPerHour[hour] = (itemsPerHour[hour] ?? 0) + items.length;
    });
    
    // Calculate expanded height for each hour
    itemsPerHour.forEach((hour, count) {
      if (count > 1) {
        // Each hour gets height based on number of items (with some minimum)
        _expandedHours[hour] = count;
      }
    });
  }

  // Get the appropriate height for an hour based on whether it's expanded
  double _getHourHeight(int hour) {
    // Default height is 60
    return _expandedHours.containsKey(hour) 
        ? 60.0 * (_expandedHours[hour] ?? 1) // Expanded height based on number of items
        : 60.0; // Default height
  }

  Future<void> _fetchAppointments(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchAppointments(selectedDate);
    if (!mounted) return;
    setState(() {
      appointments = data;
      _isLoading = false;
    });
    print("Appointments Fetched: $appointments");
    _processTimeSlots();
  }

  Future<void> _fetchTasks(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchtasks(selectedDate);
    if (!mounted) return;
    setState(() {
      tasks = data;
      _isLoading = false;
    });
    print("Tasks Fetched: $tasks");
    _processTimeSlots();
  }

  void _handleDateSelected(DateTime selectedDate) {
    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = selectedDate;
      appointments = [];
      tasks = [];
      _activeHours.clear();
      _expandedHours.clear();
      _timeSlotItems.clear();
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
                : Expanded(child: _buildImprovedTimelineView()),
          ],
        ),
      ]),
    );
  }

  Widget _buildImprovedTimelineView() {
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

    // Only show hours with actual appointments/tasks
    final List<int> displayHours = _getDisplayHours();

    return SingleChildScrollView(
      controller: _timelineScrollController,
      child: Row(
        children: [
          // Left time column
          _buildTimeColumn(displayHours),

          // Divider line
          Container(width: 1, color: Colors.grey.shade300),

          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Time grid lines
                _buildTimeGridLines(displayHours),

                // Build all items from time slots
                ..._buildAllTimeSlotItems(displayHours),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Modified to only return hours with actual content
  List<int> _getDisplayHours() {
    // Start with active hours that have content
    Set<int> hours = Set<int>.from(_activeHours);
    
    // If we have appointments or tasks spanning several hours, add buffer hours
    if (hours.isNotEmpty) {
      int minHour = hours.reduce((a, b) => a < b ? a : b);
      int maxHour = hours.reduce((a, b) => a > b ? a : b);
      
      // Add one hour before and after for context, but only if they exist
      if (minHour > 0) hours.add(minHour - 1);
      if (maxHour < 23) hours.add(maxHour + 1);
    }
    
    // Sort hours
    List<int> sortedHours = hours.toList()..sort();
    return sortedHours.isEmpty ? [DateTime.now().hour] : sortedHours;
  }

  Widget _buildTimeColumn(List<int> displayHours) {
    return Container(
      width: 50,
      child: Column(
        children: displayHours.map((hour) {
          // Get appropriate height for this hour slot
          final hourHeight = _getHourHeight(hour);
          
          return Container(
            height: hourHeight,
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

  Widget _buildTimeGridLines(List<int> displayHours) {
    return Column(
      children: displayHours.map((hour) {
        // Get appropriate height for this hour slot
        final hourHeight = _getHourHeight(hour);
        
        return Container(
          height: hourHeight,
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

  List<Widget> _buildAllTimeSlotItems(List<int> displayHours) {
    List<Widget> allWidgets = [];
    
    // Calculate hour positions first
    Map<int, double> hourPositions = {};
    double currentPosition = 0.0;
    
    for (int hour in displayHours) {
      hourPositions[hour] = currentPosition;
      currentPosition += _getHourHeight(hour);
    }
    
    // Sort time slots by time for consistent processing
    List<String> sortedTimeKeys = _timeSlotItems.keys.toList()..sort();
    
    // Process each time slot
    for (String timeKey in sortedTimeKeys) {
      final items = _timeSlotItems[timeKey]!;
      final parts = timeKey.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Skip if hour isn't in display hours
      if (!hourPositions.containsKey(hour)) continue;
      
      // Base position for this time slot
      final basePosition = hourPositions[hour]! + (minute / 60.0) * _getHourHeight(hour);
      
      // Process items in this time slot
      for (int i = 0; i < items.length; i++) {
        final itemData = items[i];
        final itemType = itemData['type'];
        final item = itemData['item'];
        
        // Position vertically to avoid overlaps
        double verticalOffset = 0.0;
        if (items.length > 1) {
          // If multiple items at same time, stack them with vertical offset
          verticalOffset = i * 60.0;
        }
        
        final itemPosition = basePosition + verticalOffset;
        
        // Add widget based on type
        if (itemType == 'appointment') {
          allWidgets.add(_buildAppointmentItem(
            item,
            basePosition: itemPosition,
            width: MediaQuery.of(context).size.width - 67,
            height: 60.0,
            widthFactor: 1.0,
            leftOffset: 0.0,
          ));
        } else if (itemType == 'task') {
          allWidgets.add(_buildTaskItem(
            item,
            basePosition: itemPosition,
            width: MediaQuery.of(context).size.width - 67,
            height: 60.0,
            widthFactor: 1.0,
            leftOffset: 0.0,
          ));
        }
      }
    }
    
    return allWidgets;
  }

  Widget _buildAppointmentItem(
    dynamic item, {
    double basePosition = 0.0,
    double width = 200.0,
    double height = 60.0,
    double widthFactor = 1.0,
    double leftOffset = 0.0,
  }) {
    // Determine color and title for appointment
    Color cardColor = _getAppointmentColor(item);

    // Get the lead_id from the item
    String leadId = item['lead_id']?.toString() ?? '';

    // Format the time in 12-hour format with AM/PM
    String formattedStartTime = _formatTimeFor12Hour(item['start_time'] ?? '00:00');
    String formattedEndTime = _formatTimeFor12Hour(item['end_time'] ?? '00:00');
    
    String title = 'Appointment: ${item['name'] ?? 'No Name'}';
    String time = '$formattedStartTime - $formattedEndTime';

    return Positioned(
      top: basePosition,
      left: 8 + (width * leftOffset),
      width: (width * widthFactor) - 8, // Account for right margin
      height: height,
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
                if (height >= 55)
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
  
  Widget _buildTaskItem(
    dynamic item, {
    double basePosition = 0.0,
    double width = 200.0,
    double height = 60.0,
    double widthFactor = 1.0,
    double leftOffset = 0.0,
  }) {
    // Get the lead_id from the item
    String leadId = item['lead_id']?.toString() ?? '';

    // Format the time in 12-hour format with AM/PM
    String formattedDueTime = _formatTimeFor12Hour(item['due_date'] ?? '00:00');

    // Determine color and title for task
    Color cardColor = _getTaskColor(item);
    String title = 'Task: ${item['subject'] ?? 'No Subject'}';
    String status = item['status'] ?? 'Unknown';
    String priority = item['priority'] ?? 'Normal';
    
    // Add due time to status display if available
    String timeInfo = formattedDueTime.isNotEmpty ? ' • $formattedDueTime' : '';

    return Positioned(
      top: basePosition,
      left: 8 + (width * leftOffset),
      width: (width * widthFactor) - 8, // Account for right margin
      height: height,
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
                      '$status$timeInfo',
                      style:const TextStyle(
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

  DateTime _parseTimeString(String timeStr) {
    // If timeStr is null or empty, return a default time
    if (timeStr.isEmpty) {
      return DateTime(2022, 1, 1, 0, 0); // Default time (midnight)
    }

    // Handle both 12-hour and 24-hour time formats
    bool isPM = timeStr.toLowerCase().contains('pm');
    bool isAM = timeStr.toLowerCase().contains('am');
    
    // Remove AM/PM indicator for parsing
    String cleanTime = timeStr
        .toLowerCase()
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll(' ', '')
        .trim();

    final parts = cleanTime.split(':');
    if (parts.length < 2)
      return DateTime(2022, 1, 1, 0, 0); // Invalid time format fallback

    try {
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Convert 12-hour format to 24-hour if needed
      if (isPM && hour < 12) {
        hour += 12; // Add 12 to PM hours except 12 PM
      } else if (isAM && hour == 12) {
        hour = 0; // 12 AM is 0 in 24-hour format
      }
      
      return DateTime(2022, 1, 1, hour, minute);
    } catch (e) {
      print("Error parsing time: $timeStr - $e");
      return DateTime(2022, 1, 1, 0, 0); // Default to midnight if parsing fails
    }
  }

  // Format time to 12-hour format with AM/PM for display consistency
  String _formatTimeFor12Hour(String timeStr) {
    if (timeStr.isEmpty || !timeStr.contains(':')) {
      return timeStr; // Return unchanged if not in time format
    }
    
    // Parse the time first to normalize it
    DateTime parsedTime = _parseTimeString(timeStr);
    
    // Format to 12-hour time
    String period = parsedTime.hour >= 12 ? 'PM' : 'AM';
    int hour12 = parsedTime.hour > 12 ? parsedTime.hour - 12 : (parsedTime.hour == 0 ? 12 : parsedTime.hour);
    
    return '${hour12}:${parsedTime.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getTaskColor(dynamic task) {
    final type = task['taskType']?.toString().toLowerCase() ?? '';
    if (type == 'follow-up' || type == 'followup') {
      return AppColors.colorsBlue; // Blue for follow-up tasks
    } else if (type == 'urgent') {
      return Colors.red; // Red for urgent tasks
    } else if (type == 'reminder') {
      return Colors.green; // Green for reminders
    } else {
      return AppColors.colorsBlue; // Default color for tasks
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
}