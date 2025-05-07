import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/pages/Calendar/tasks/addTask.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/widgets/calender/appointment.dart';
import 'package:smart_assist/widgets/calender/calender.dart';
import 'package:smart_assist/widgets/calender/calender_task.dart';
import 'package:smart_assist/widgets/calender/event.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/appointment_popup.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_Followups_popups.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_leads.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_testDrive.dart';
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

  // Initialize the controller
  final FabController fabController = Get.put(FabController());

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

  // void _handleDateSelection(DateTime selectedDay) {
  //   setState(() {
  //     _selectedDay = selectedDay;
  //     _focusedDay = selectedDay;
  //   });

  //   print(
  //       'Fetching data for date is tthe ajdfoadjfadjf: ${DateFormat('dd-MM-yyyy').format(selectedDay)}');

  //   _fetchAppointments(selectedDay);
  //   _fetchCount(selectedDay);
  // }

  void _showAppointmentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // Remove default padding
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppointmentPopup(
              onFormSubmit: () {},
            ), // Appointment modal
          ),
        );
      },
    );
  }

  void _showTestdrivePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // Remove default padding
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateTestdrive(
              onFormSubmit: () {},
            ), // Appointment modal
          ),
        );
      },
    );
  }

  void _showLeadPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add some margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateLeads(
              onFormSubmit: () {},
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xffF2F2F2),
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
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
              ],
            ),
          ),

          Positioned(
            bottom: 26,
            right: 18,
            child: _buildFloatingActionButton(context),
          ),

          // Popup Menu (Conditionally Rendered)
          Obx(() => fabController.isFabExpanded.value
              ? _buildPopupMenu(context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // FAB Builder
  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: fabController.toggleFab,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * .15,
          height: MediaQuery.of(context).size.height * .08,
          decoration: BoxDecoration(
            color: fabController.isFabExpanded.value
                ? Colors.red
                : AppColors.colorsBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedRotation(
              turns: fabController.isFabExpanded.value ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                fabController.isFabExpanded.value ? Icons.close : Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return GestureDetector(
      onTap: fabController.closeFab,
      child: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Popup Items Container aligned bottom right
          Positioned(
            bottom: 90,
            right: 20,
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPopupItem(
                      Icons.calendar_month_outlined, "Appointment", -80,
                      onTap: () {
                    fabController.closeFab();
                    _showAppointmentPopup(context);
                  }),
                  _buildPopupItem(Icons.people_alt_rounded, "Enquiry", -60,
                      onTap: () {
                    fabController.closeFab();
                    _showLeadPopup(context);
                  }),
                  _buildPopupItem(Icons.call, "Followup", -40, onTap: () {
                    fabController.closeFab();
                    _showFollowupPopup(context);
                  }),
                  _buildPopupItem(Icons.directions_car, "Test Drive", -20,
                      onTap: () {
                    fabController.closeFab();
                    _showTestdrivePopup(context);
                  }),
                ],
              ),
            ),
          ),

          // ✅ FAB positioned above the overlay
          Positioned(
            bottom: 26,
            right: 18,
            child: _buildFloatingActionButton(context),
          ),
        ],
      ),
    );
  }

  // Popup Item Builder
  Widget _buildPopupItem(IconData icon, String label, double offsetY,
      {required Function() onTap}) {
    return Obx(() => TweenAnimationBuilder(
          tween: Tween<double>(
              begin: 0, end: fabController.isFabExpanded.value ? 1 : 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, offsetY * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.colorsBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  void _showFollowupPopup(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateFollowupsPopups(
              onFormSubmit: () {}, // Pass the function here
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:smart_assist/pages/Calendar/tasks/addTask.dart';
// import 'package:smart_assist/services/leads_srv.dart';
// import 'package:smart_assist/widgets/calender/appointment.dart';
// import 'package:smart_assist/widgets/calender/calender.dart';
// import 'package:smart_assist/widgets/calender/calender_task.dart';
// import 'package:smart_assist/widgets/calender/event.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';

// class Calender extends StatefulWidget {
//   final String leadId;
//   final String leadName;
//   const Calender({super.key, required this.leadId, required this.leadName});

//   @override
//   State<Calender> createState() => _CalenderState();
// }

// class _CalenderState extends State<Calender> {
//   DateTime _focusedDay = DateTime.now();
//   CalendarFormat _calendarFormat = CalendarFormat.week;
//   bool _isMonthView = false;
//   List<dynamic> appointments = [];
//   List<dynamic> tasks = [];
//   DateTime? _selectedDay;
//   int upcomingFollowupsCount = 0;
//   int overdueFollowupsCount = 0;
//   int overdueAppointmentsCount = 0;
//   int upcomingAppointmentsCount = 0;
//   // bool _showSecondIcon = false;

//   @override
//   void initState() {
//     super.initState();

//     _fetchInitialData();
//   }

//   Future<void> _fetchInitialData() async {
//     _fetchAppointments(_selectedDay ?? _focusedDay);
//     _fetchCount(_selectedDay ?? _focusedDay);
//     _fetchTasks(_selectedDay ?? _focusedDay);
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

//   Future<void> _fetchCount(DateTime selectedDate) async {
//     // Check if the widget is still mounted before proceeding
//     if (!mounted) return;

//     String formattedDate =
//         DateFormat('dd-MM-yyyy').format(selectedDate); // Ensure correct format
//     final data = await LeadsSrv.fetchCount(selectedDate);

//     // Check again after the async operation completes
//     if (!mounted) return;

//     if (data.isNotEmpty) {
//       setState(() {
//         upcomingFollowupsCount = data['upcomingFollowupsCount'] ?? 0;
//         overdueFollowupsCount = data['overdueFollowupsCount'] ?? 0;
//         upcomingAppointmentsCount = data['upcomingAppointmentsCount'] ?? 0;
//         overdueAppointmentsCount = data['overdueAppointmentsCount'] ?? 0;
//       });
//     } else {
//       // print("No data returned for $formattedDate");
//     }
//   }

//   void _handleDateSelection(DateTime selectedDay) {
//     setState(() {
//       _selectedDay = selectedDay;
//       _focusedDay = selectedDay;
//     });

//     print(
//         'Fetching data for date is tthe ajdfoadjfadjf: ${DateFormat('dd-MM-yyyy').format(selectedDay)}');

//     _fetchAppointments(selectedDay);
//     _fetchCount(selectedDay);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: const Color(0xffF2F2F2),
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//         // title: Text(
//         //   DateFormat('MMMM yyyy').format(_focusedDay),
//         //   style: GoogleFonts.poppins(
//         //       fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
//         // ),
//         title: Text(
//           'Calendar',
//           style: AppFont.appbarfontWhite(context),
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
//           // IconButton(
//           //   onPressed: () {
//           // ✅ Always update `_createTask` with the latest selected date
//           // Widget createTask = AddTaskPopup(
//           //   selectedDate: _selectedDay ?? _focusedDay, // ✅ Latest date used
//           //   leadId: widget.leadId,
//           //   leadName: widget.leadName,
//           //   selectedLeadId: '',
//           // );

//           // showDialog(
//           //   context: context,
//           //   builder: (context) {
//           //     return Dialog(
//           //       backgroundColor: Colors.white,
//           //       insetPadding: const EdgeInsets.symmetric(horizontal: 10),
//           //       shape: RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.circular(10),
//           //       ),
//           //       child: createTask, // ✅ Always latest date
//           //     );
//           //   },
//           // );
//           //   },
//           //   icon: const Icon(Icons.add, color: Colors.white),
//           // ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CalenderWidget(
//               key: ValueKey(_calendarFormat),
//               calendarFormat: _calendarFormat,
//               onDateSelected: (selectedDate) {
//                 setState(() {
//                   _focusedDay = selectedDate;
//                   _selectedDay = selectedDate;
//                 });
//                 _fetchAppointments(selectedDate);
//                 _fetchTasks(selectedDate);
//               },
//             ),
//             AppointmentWidget(
//               appointments: appointments,
//               onDateSelected: _fetchAppointments,
//               selectedDate: _selectedDay ?? _focusedDay,
//             ),

//             CalenderTask(
//                 tasks: tasks,
//                 selectedDate: _selectedDay ?? _focusedDay,
//                 onDateSelected: _fetchTasks),

//             EventWidget(
//               // selectedDate: _focusedDay,
//               selectedDate: _selectedDay ?? _focusedDay,
//               upcomingFollowupsCount: upcomingFollowupsCount,
//               overdueFollowupsCount: overdueFollowupsCount,
//               upcomingAppointmentsCount: upcomingAppointmentsCount,
//               overdueAppointmentsCount: overdueAppointmentsCount,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
