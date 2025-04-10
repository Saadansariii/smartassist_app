import 'package:flutter/material.dart'; 
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Calendar/tasks/addTask.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/widgets/calender/appointment.dart';
import 'package:smart_assist/widgets/calender/calender.dart';
import 'package:smart_assist/widgets/calender/calender_task.dart';
import 'package:smart_assist/widgets/calender/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Calender extends StatefulWidget {
  final String leadId;
  final String leadName;
  const Calender({super.key, required this.leadId, required this.leadName});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isMonthView = false;
  List<dynamic> appointments = [];
  List<dynamic> tasks = [];
  DateTime? _selectedDay;
  int upcomingFollowupsCount = 0;
  int overdueFollowupsCount = 0;
  int overdueAppointmentsCount = 0;
  int upcomingAppointmentsCount = 0;
  // bool _showSecondIcon = false;

  @override
  void initState() {
    super.initState();

    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _fetchAppointments(_selectedDay ?? _focusedDay);
    _fetchCount(_selectedDay ?? _focusedDay);
    _fetchTasks(_selectedDay ?? _focusedDay);
  }

  Future<void> _fetchAppointments(DateTime selectedDate) async {
    final data = await LeadsSrv.fetchAppointments(selectedDate);
    if (!mounted) return;
    setState(() {
      appointments = data;
    });
  }

  Future<void> _fetchTasks(DateTime? selectedDate) async {
    final DateTime finalDate = selectedDate ?? DateTime.now();
    final data = await LeadsSrv.fetchtasks(finalDate);
    if (!mounted) return;
    setState(() {
      tasks = data;
    });
  }

  Future<void> _fetchCount(DateTime selectedDate) async {
    // Check if the widget is still mounted before proceeding
    if (!mounted) return;

    String formattedDate =
        DateFormat('dd-MM-yyyy').format(selectedDate); // Ensure correct format
    final data = await LeadsSrv.fetchCount(selectedDate);

    // Check again after the async operation completes
    if (!mounted) return;

    if (data.isNotEmpty) {
      setState(() {
        upcomingFollowupsCount = data['upcomingFollowupsCount'] ?? 0;
        overdueFollowupsCount = data['overdueFollowupsCount'] ?? 0;
        upcomingAppointmentsCount = data['upcomingAppointmentsCount'] ?? 0;
        overdueAppointmentsCount = data['overdueAppointmentsCount'] ?? 0;
      });
    } else {
      // print("No data returned for $formattedDate");
    }
  }

  void _handleDateSelection(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });

    print(
        'Fetching data for date is tthe ajdfoadjfadjf: ${DateFormat('dd-MM-yyyy').format(selectedDay)}');

    _fetchAppointments(selectedDay);
    _fetchCount(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        // title: Text(
        //   DateFormat('MMMM yyyy').format(_focusedDay),
        //   style: GoogleFonts.poppins(
        //       fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        // ),
        title: Text(
          'Calendar',
          style: AppFont.appbarfontWhite(context),
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
          IconButton(
            onPressed: () {
              // ✅ Always update `_createTask` with the latest selected date
              Widget createTask = AddTaskPopup(
                selectedDate: _selectedDay ?? _focusedDay, // ✅ Latest date used
                leadId: widget.leadId,
                leadName: widget.leadName,
                selectedLeadId: '',
              );

              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.white,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: createTask, // ✅ Always latest date
                  );
                },
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderWidget(
              key: ValueKey(_calendarFormat),
              calendarFormat: _calendarFormat,
              onDateSelected: (selectedDate) {
                setState(() {
                  _focusedDay = selectedDate;
                  _selectedDay = selectedDate;
                });
                _fetchAppointments(selectedDate);
                _fetchTasks(selectedDate);
              },
            ),
            AppointmentWidget(
              appointments: appointments,
              onDateSelected: _fetchAppointments,
              selectedDate: _selectedDay ?? _focusedDay,
            ),
            CalenderTask(
                tasks: tasks,
                selectedDate: _selectedDay ?? _focusedDay,
                onDateSelected: _fetchTasks),
            EventWidget(
              // selectedDate: _focusedDay,
              selectedDate: _selectedDay ?? _focusedDay,
              upcomingFollowupsCount: upcomingFollowupsCount,
              overdueFollowupsCount: overdueFollowupsCount,
              upcomingAppointmentsCount: upcomingAppointmentsCount,
              overdueAppointmentsCount: overdueAppointmentsCount,
            ),
          ],
        ),
      ),
    );
  }
}
