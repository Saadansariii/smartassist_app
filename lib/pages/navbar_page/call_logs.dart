import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  List<CallLogEntry> callLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCallLogPermission();
  }

// Add this function to your _CallLogsState class

  Future<void> postCallLogsToApi() async {
    final token = await Storage.getToken();
    if (callLogs.isEmpty) {
      // Handle empty call logs
      print('No call logs to send');
      return;
    }

    // Format call logs as per required format
    List<Map<String, dynamic>> formattedLogs = callLogs.map((log) {
      return {
        'name': log.name ?? 'Unknown',
        'start_time': log.timestamp?.toString() ?? '',
        'mobile': log.number ?? '',
        'call_type': log.callType?.toString().split('.').last ?? '',
        'call_duration': log.duration?.toString() ?? '',
        'unique_key':
            '${log.timestamp?.toString() ?? ''}${log.number ?? ''}${log.callType?.toString()}${log.duration?.toString()}',
      };
    }).toList();

    print('Formated data from my side : ${jsonEncode(formattedLogs)}');

    // API endpoint URL - replace with your actual API endpoint
    final apiUrl = 'https://dev.smartassistapp.in/api/leads/create-call-logs';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formattedLogs),
      );

      if (response.statusCode == 200) {
        print('Call logs uploaded successfully');
        // You can add user feedback here
      } else {
        print(
            'Failed to upload call logs. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Handle error - perhaps show a dialog to the user
      }
    } catch (e) {
      print('Error uploading call logs: $e');
      // Handle network or other errors
    }
  }

  void fetchCallLogs() async {
    // Get call logs
    Iterable<CallLogEntry> entries = await CallLog.get();

    setState(() {
      callLogs = entries.toList();
      isLoading = false;
    });

    // Post the call logs to the API
    await postCallLogsToApi();
  }

  void getCallLogPermission() async {
    if (await Permission.phone.isGranted) {
      fetchCallLogs();
    } else {
      await Permission.phone.request().then((status) {
        if (status.isGranted) {
          fetchCallLogs();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  // Helper function to get call type icon and color
  IconData getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      case CallType.rejected:
        return Icons.call_missed_outgoing;
      case CallType.blocked:
        return Icons.block;
      case CallType.voiceMail:
        return Icons.voicemail;
      default:
        return Icons.call;
    }
  }

  Color getCallTypeColor(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
      case CallType.rejected:
        return Colors.orange;
      case CallType.blocked:
        return Colors.purple;
      case CallType.voiceMail:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String formatDuration(int? seconds) {
    if (seconds == null) return "0s";

    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String result = "";
    if (hours > 0) result += "${hours}h ";
    if (minutes > 0) result += "${minutes}m ";
    if (remainingSeconds > 0 || result.isEmpty)
      result += "${remainingSeconds}s";

    return result.trim();
  }

  String formatDateTime(int? timestamp) {
    if (timestamp == null) return "";

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final callDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String formattedTime = DateFormat('h:mm a').format(dateTime);

    if (callDate == today) {
      return "Today, $formattedTime";
    } else if (callDate == yesterday) {
      return "Yesterday, $formattedTime";
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call logs', style: AppFont.appbarfontgrey(context)),
        foregroundColor: AppColors.fontColor,
        leading: IconButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => BottomNavigation())),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 25,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : callLogs.isEmpty
              ? const Center(
                  child: Text("No call logs found or permission denied"),
                )
              : ListView.builder(
                  itemCount: callLogs.length,
                  itemBuilder: (context, index) {
                    CallLogEntry log = callLogs[index];
                    String name = log.name ?? "Unknown";
                    String firstLetter = name.isNotEmpty ? name[0] : "#";

                    return ListTile(
                      leading: Container(
                        height: 40.h,
                        width: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6.r),
                          // color: Color(0xff262626),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            textAlign: TextAlign.center,
                            firstLetter,
                            style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: AppColors.colorsBlue),
                            // style: GoogleFonts.poppins(
                            //   fontSize: 23.sp,
                            //   color: Colors.primaries[
                            //       Random().nextInt(Colors.primaries.length)],

                            //   fontWeight: FontWeight.w500,
                            // ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.dropDowmLabel(context),
                            ),
                          ),
                          Icon(
                            getCallTypeIcon(log.callType),
                            size: 16.sp,
                            color: getCallTypeColor(log.callType),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            log.number ?? "No number",
                            style: AppFont.smallText(context),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDateTime(log.timestamp),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xffA0A0A0),
                                  fontFamily: "Poppins",
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                formatDuration(log.duration),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xffA0A0A0),
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      horizontalTitleGap: 12.w,
                    );
                  },
                ),
    );
  }
}
