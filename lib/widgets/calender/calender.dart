import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderWidget extends StatefulWidget {
  final CalendarFormat calendarFormat;
  final Function(DateTime)
      onDateSelected; // Callback to notify the parent widget

  const CalenderWidget({
    super.key,
    required this.calendarFormat,
    required this.onDateSelected, // Pass the callback to the parent
  });

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Function to fetch data based on the selected date
  Future<void> _fetchData(DateTime selectedDay) async {
    final formattedDate = DateFormat('dd-MM-yyyy')
        .format(selectedDay); // Format date to string (YYYY-MM-DD)
    print('Fetching data for date: $formattedDate');
    widget.onDateSelected(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay, // Ensure focusedDay is updated correctly
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day); // Check if the day is selected
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay; // Update the selected day
            _focusedDay = focusedDay; // Update the focused day
          });
          _fetchData(selectedDay); // Fetch data when a date is selected
        },

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppFont.calanderDayName(context),
          weekendStyle: AppFont.calanderDayName(context),
        ),

        calendarFormat: widget.calendarFormat,
        availableGestures: AvailableGestures.all,

// hide the month
        // headerStyle: const HeaderStyle(
        //   formatButtonVisible: false,
        //   titleCentered: false,
        //   leftChevronVisible: false,
        //   rightChevronVisible: false,
        //   headerPadding: EdgeInsets.zero,
        //   titleTextStyle: TextStyle(fontSize: 0, color: Colors.transparent),
        // ),

        headerStyle: HeaderStyle(
          headerMargin: EdgeInsets.fromLTRB(10, 0, 0, 10),
          formatButtonVisible: false,
          titleCentered: false,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.zero,
          titleTextStyle: AppFont.popupTitleBlack(context),
        ),

        calendarStyle: CalendarStyle(
          holidayDecoration: BoxDecoration(color: AppColors.sideRed),
          holidayTextStyle: TextStyle(color: AppColors.sideRed, fontSize: 20),
          isTodayHighlighted: true,
          selectedDecoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          todayTextStyle: const TextStyle(color: Colors.black),
        ),

        // ✅ Added Small Dot Below Today's Date
        calendarBuilders: CalendarBuilders(
          todayBuilder: (context, date, focusedDay) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3), // Adjust spacing
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.colorsBlue, // Color of the dot
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalenderWidget extends StatefulWidget {
//   final CalendarFormat calendarFormat;
//   final Function(DateTime)
//       onDateSelected; // Callback to notify the parent widget
//   const CalenderWidget({
//     super.key,
//     required this.calendarFormat,
//     required this.onDateSelected, // Pass the callback to the parent
//   });

//   @override
//   State<CalenderWidget> createState() => _CalenderWidgetState();
// }

// class _CalenderWidgetState extends State<CalenderWidget> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   // Function to fetch data based on the selected date
//   Future<void> _fetchData(DateTime selectedDay) async {
//     final formattedDate = DateFormat('dd-MM-yyyy')
//         .format(selectedDay); // Format date to string (YYYY-MM-DD)
//     print('Fetching data for date: $formattedDate');
//     widget.onDateSelected(selectedDay);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
//       child: TableCalendar(
//         firstDay: DateTime.utc(2000, 1, 1),
//         lastDay: DateTime.utc(2100, 12, 31),
//         focusedDay: _focusedDay, // Ensure focusedDay is updated correctly
//         selectedDayPredicate: (day) {
//           return isSameDay(_selectedDay, day); // Check if the day is selected
//         },
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay; // Update the selected day
//             _focusedDay = focusedDay; // Update the focused day
//           });
//           _fetchData(selectedDay); // Fetch data when a date is selected
//         },

//         daysOfWeekStyle: DaysOfWeekStyle(
//             // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
//             weekdayStyle: AppFont.calanderDayName(),
//             weekendStyle: AppFont.calanderDayName()),

//         calendarFormat: widget.calendarFormat,
//         availableGestures: AvailableGestures.all,
//         headerStyle: const HeaderStyle(
//           formatButtonVisible: false,
//           titleCentered: false,
//           leftChevronVisible: false,
//           rightChevronVisible: false,
//           headerPadding: EdgeInsets.zero,
//           titleTextStyle: TextStyle(fontSize: 0, color: Colors.transparent),
//         ),
//         calendarStyle: CalendarStyle(
//             isTodayHighlighted: true,
//             selectedDecoration: const BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             todayDecoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black, width: 2),
//             ),
//             todayTextStyle: TextStyle(color: Colors.black)),
            
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalenderWidget extends StatefulWidget {
//   final CalendarFormat calendarFormat;
//   final Function(DateTime) onDateSelected;

//   const CalenderWidget({
//     super.key,
//     required this.calendarFormat,
//     required this.onDateSelected,
//   });

//   @override
//   State<CalenderWidget> createState() => _CalenderWidgetState();
// }

// class _CalenderWidgetState extends State<CalenderWidget> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: TableCalendar(
//         firstDay: DateTime.utc(2000, 1, 1),
//         lastDay: DateTime.utc(2100, 12, 31),
//         focusedDay: _focusedDay,
//         selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//           widget.onDateSelected(selectedDay);
//         },
//         calendarFormat: widget.calendarFormat,
//         availableGestures: AvailableGestures.all,
//         headerStyle: const HeaderStyle(
//           formatButtonVisible: false,
//           titleCentered: true,
//           leftChevronVisible: false,
//           rightChevronVisible: false,
//           headerPadding: EdgeInsets.zero,
//           titleTextStyle: TextStyle(fontSize: 0, color: Colors.transparent),
//         ),
//         calendarStyle: CalendarStyle(
//           isTodayHighlighted: true,
//           selectedDecoration: BoxDecoration(
//             color: Colors.blue,
//             shape: BoxShape.circle,
//           ),
//           todayDecoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.black, width: 2),
//           ),
//           todayTextStyle: TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }
// }
