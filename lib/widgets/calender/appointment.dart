import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppointmentWidget extends StatefulWidget {
  final List<dynamic> appointments;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const AppointmentWidget({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
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

  DateTime _parseTimeString(String timeStr) {
    // Parse the time string (e.g., "06:30:00") into a DateTime object
    final parts = timeStr.split(':');
    if (parts.length == 3) {
      try {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = int.parse(parts[2]);
        return DateTime(2022, 1, 1, hour, minute,
            second); // Use a dummy date (e.g., 2022-01-01)
      } catch (e) {
        return DateTime(
            2022, 1, 1, 0, 0, 0); // Default to midnight if parsing fails
      }
    }
    return DateTime(2022, 1, 1, 0, 0,
        0); // Default to midnight if the time format is incorrect
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 200)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            );
          }
          if (widget.appointments.isEmpty) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Text(
                    'No appointments available for ${DateFormat('MMMM dd').format(widget.selectedDate)}.'),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.appointments.map((appointment) {
                      print(
                          appointment); // Add a print statement to see each appointment's data

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7FAEE5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.selectedDate.day}', // Day number (e.g., 13)
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            // '${getDayWithSuffix(widget.selectedDate.day).substring(widget.selectedDate.day.toString().length)}',
                                            getDayWithSuffix(
                                                    widget.selectedDate.day)
                                                .substring(widget
                                                    .selectedDate.day
                                                    .toString()
                                                    .length),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              height: 0.5,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          width:
                                              5), // Space between day and month
                                      Text(
                                        DateFormat('MMM')
                                            .format(widget.selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  appointment['name'] ?? 'No Name',
                                  style: TextStyle(
                                      fontSize: screenWidth > 600 ? 18 : 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Wrap(
                                  spacing: 8, // Horizontal spacing
                                  runSpacing:
                                      4, // Vertical spacing when wrapped
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(Icons.call,
                                        size: screenWidth > 600 ? 24 : 20),
                                    Text(
                                      appointment['subject'] ?? 'No Subject',
                                      style: TextStyle(
                                          fontSize:
                                              screenWidth > 600 ? 16 : 14),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Icon(Icons.circle,
                                              size: screenWidth > 600 ? 12 : 8),
                                        ),
                                        Text(
                                          'Start Date',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          appointment['start_time'] != null
                                              ? DateFormat('hh:mm a').format(
                                                  _parseTimeString(appointment[
                                                      'start_time']))
                                              : 'No start time',
                                          style: GoogleFonts.poppins(
                                            fontSize:
                                                screenWidth > 600 ? 16 : 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Icon(Icons.circle,
                                              size: screenWidth > 600 ? 12 : 8),
                                        ),
                                        Text(
                                          'End Date',
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          appointment['end_date'] != null
                                              ? DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(
                                                      appointment['end_date']))
                                              : 'No start date',
                                          style: GoogleFonts.poppins(
                                              fontSize:
                                                  screenWidth > 600 ? 16 : 10),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          );
        });
  }
}
