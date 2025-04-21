import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/call_history.dart';
import 'package:smart_assist/widgets/home_btn.dart/single_ids_popup/appointment_ids.dart';
import 'package:smart_assist/widgets/home_btn.dart/single_ids_popup/followups_ids.dart';
import 'package:smart_assist/widgets/home_btn.dart/single_ids_popup/testdrive_ids.dart';
import 'package:smart_assist/widgets/leads_details_popup/create_appointment.dart';
import 'package:smart_assist/widgets/leads_details_popup/create_followups.dart';
import 'package:smart_assist/widgets/timeline/timeline_overdue.dart';
import 'package:smart_assist/widgets/timeline/timeline_tasks.dart';
import 'package:smart_assist/widgets/timeline/timeline_completed.dart';
import 'package:smart_assist/widgets/whatsapp_chat.dart';

class FollowupsDetails extends StatefulWidget {
  final String leadId;
  const FollowupsDetails({super.key, required this.leadId});

  @override
  State<FollowupsDetails> createState() => _FollowupsDetailsState();
}

class _FollowupsDetailsState extends State<FollowupsDetails> {
  // Placeholder data
  String mobile = 'Loading...';
  String chatId = 'Loading...';
  String email = 'Loading...';
  String status = 'Loading...';
  String company = 'Loading...';
  String address = 'Loading...';
  String lead_owner = 'Loading....';
  String leadSource = 'Loading....';
  String enquiry_type = 'Loading...';
  String purchase_type = 'Loading...';
  String PMI = 'Loading....';
  String fuel_type = 'Loading....';
  String expected_date_purchase = 'Loading...';

  bool isLoading = false;
  int _childButtonIndex = 0;
  Widget _selectedTaskWidget = Container();
  static Map<String, int> _callLogs = {
    'all': 0,
    'outgoing': 0,
    'incoming': 0,
    'missed': 0,
  };

  //  Widget _callLogsWidget = Container();
  // fetchevent data

  List<Map<String, dynamic>> upcomingTasks = [];
  List<Map<String, dynamic>> overdueTasks = [];
  List<Map<String, dynamic>> overdueEvents = [];
  List<Map<String, dynamic>> upcomingEvents = [];
  List<Map<String, dynamic>> completedEvents = [];
  List<Map<String, dynamic>> completedTasks = [];

  List<String> subjectList = [];
  List<String> priorityList = [];
  List<String> startTimeList = [];
  List<String> endTimeList = [];
  List<String> startDateList = [];

  bool _isHidden = false;
  bool _isHiddenTop = true;
  bool _isHiddenMiddle = true;
  // dropdown
  final Widget _createFollowups = const LeadsCreateFollowup();
  final Widget _createAppoinment = const CreateAppointment();
  // Initialize the controller
  final FabController fabController = Get.put(FabController());
  String leadId = '';

  @override
  void initState() {
    super.initState();
    eventandtask(widget.leadId);
    fetchSingleIdData(widget.leadId).then((_) {
      fetchCallLogs(mobile);
      // _fetchCallLogs();
    });

    // Initially, set the selected widget
    _selectedTaskWidget = TimelineUpcoming(
      tasks: upcomingTasks,
      upcomingEvents: upcomingEvents,
    );

    _selectedTaskWidget = timelineOverdue(
      tasks: overdueTasks,
      overdueEvents: overdueEvents,
    );

    // _callLogsWidget = TimelineEightWid(tasks: upcomingTasks, upcomingEvents: upcomingEvents);
  }

  String formatDate(String date) {
    try {
      final DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(date);
      return DateFormat("d MMM").format(parsedDate); // Outputs "22 May"
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  Future<void> fetchSingleIdData(String leadId) async {
    try {
      final leadData = await LeadsSrv.singleFollowupsById(leadId);
      setState(() {
        mobile = leadData['data']['mobile'] ?? 'N/A';
        chatId = leadData['data']['chat_id'] ?? 'N/A';
        email = leadData['data']['email'] ?? 'N/A';
        status = leadData['data']['status'] ?? 'N/A';
        company = leadData['data']['brand'] ?? 'N/A';
        address = leadData['data']['address'] ?? 'N/A';
        leadSource = leadData['data']['lead_source'] ?? 'N/A';
        fuel_type = leadData['data']['fuel_type'] ?? 'N/A';
        PMI = leadData['data']['PMI'] ?? 'N/A';
        purchase_type = leadData['data']['purchase_type'] ?? 'N/A';
        enquiry_type = leadData['data']['enquiry_type'] ?? 'N/A';
        expected_date_purchase =
            leadData['data']['expected_date_purchase'] ?? 'N/A';
        lead_owner = leadData['data']['lead_name'] ?? 'N/A';
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  static Future<Map<String, int>> fetchCallLogs(String mobile) async {
    const String apiUrl =
        "https://api.smartassistapp.in/api/leads/call-logs/all";
    final token = await Storage.getToken();

    try {
      // if (mobile.isEmpty) {
      //   throw Exception("Mobile number is required");
      // }
      final encodedMobile = Uri.encodeComponent(mobile);

      final response = await http.get(
        Uri.parse(
            '$apiUrl?mobile=$encodedMobile'), // Correct query parameter format
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];
        print('$apiUrl?mobile=$encodedMobile');
        final Map<String, dynamic> categoryCounts = data['category_counts'];

        // Update the class variable with the category counts
        _callLogs = {
          'all': categoryCounts['all'] ?? 0,
          'outgoing': categoryCounts['outgoing'] ?? 0,
          'incoming': categoryCounts['incoming'] ?? 0,
          'missed': categoryCounts['missed'] ?? 0,
          'rejected': categoryCounts['rejected'] ??
              0, // Added this as it's in your API response
        };
        return _callLogs;
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> allTasks = [];
  List<Map<String, dynamic>> allTestdrive = [];

  Future<void> eventandtask(String leadId) async {
    setState(() => isLoading = true);
    try {
      final data = await LeadsSrv.eventTaskByLead(leadId);

      setState(() {
        // Ensure that upcomingTasks and completedTasks are correctly cast to List<Map<String, dynamic>>.
        overdueTasks = List<Map<String, dynamic>>.from(data['overdueTasks']);
        overdueEvents = List<Map<String, dynamic>>.from(data['overdueEvents']);
        upcomingTasks = List<Map<String, dynamic>>.from(data['upcomingTasks']);
        upcomingEvents =
            List<Map<String, dynamic>>.from(data['upcomingEvents']);
        completedTasks =
            List<Map<String, dynamic>>.from(data['completedTasks']);
        completedEvents =
            List<Map<String, dynamic>>.from(data['completedEvents']);

        // Now you can safely pass the upcomingTasks and completedTasks to the widgets.
        _selectedTaskWidget = TimelineUpcoming(
          tasks: upcomingTasks,
          upcomingEvents: upcomingEvents,
        );
      });
    } catch (e) {
      print('Error Fetching events: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleTasks(int index) {
    setState(() {
      _childButtonIndex = index;

      if (index == 0) {
        // Show upcoming tasks
        _selectedTaskWidget = TimelineUpcoming(
            tasks: upcomingTasks, upcomingEvents: upcomingEvents);
      } else if (index == 1) {
        _selectedTaskWidget = TimelineCompleted(
            events: completedTasks, completedEvents: completedEvents);
      } else {
        _selectedTaskWidget =
            timelineOverdue(tasks: overdueTasks, overdueEvents: overdueEvents);
      }
    });
  }

  // The method to show the toggle options (Upcoming / Completed)
  Widget _buildToggleOption(int index, String text) {
    final bool isActive = _childButtonIndex == index;
    return GestureDetector(
      onTap: () => _toggleTasks(index),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: isActive ? 18 : 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  // Toggle switch to toggle between 'Upcoming' and 'Completed'
  Widget _buildToggleSwitch() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleOption(0, 'Upcoming'),
        const SizedBox(width: 10),
        _buildToggleOption(1, 'Completed'),
        const SizedBox(width: 10),
        _buildToggleOption(2, 'Overdue'),
      ],
    );
  }

  void _showFollowupPopup(BuildContext context, String leadId) {
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
            child: FollowupsIds(
              leadId: leadId,
              onFormSubmit: eventandtask,
            ),
          ),
        );
      },
    );
  }

  void _showAppointmentPopup(BuildContext context, String leadId) {
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
            child: AppointmentIds(
              leadId: leadId,
              onFormSubmit: eventandtask,
            ), // Appointment modal
          ),
        );
      },
    );
  }

  void _showTestdrivePopup(BuildContext context, String leadId) {
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
            child: TestdriveIds(
              leadId: leadId,
              onFormSubmit: eventandtask,
            ), // Appointment modal
          ),
        );
      },
    );
  }

  // ✅ Function to Convert 24-hour Time to 12-hour Format
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return 'N/A';

    try {
      DateTime parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat("hh:mm").format(parsedTime);
    } catch (e) {
      print("Error formatting time: $e");
      return 'Invalid Time';
    }
  }

  // Helper method to build ContactRow widget
  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ContactRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      taskId: widget.leadId,
    );
  }

  Widget _callLogsWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // All Calls
          _buildRow('All Calls', _callLogs['all'] ?? 0, '', Icons.call),

          // Outgoing Calls
          _buildRow('Outgoing Calls', _callLogs['outgoing'] ?? 0, 'outgoing',
              Icons.phone_forwarded_outlined),

          // Incoming Calls
          _buildRow('Incoming Calls', _callLogs['incoming'] ?? 0, 'incoming',
              Icons.call),

          // Missed Calls
          _buildRow('Missed Calls', _callLogs['missed'] ?? 0, 'missed',
              Icons.call_missed),
        ],
      ),
    );
  }

// Helper method to build each row with dynamic values
  Widget _buildRow(String title, int count, String category, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          icon,
          size: 25,
          color: _getIconColor(category),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.1),
        Text(
          title,
          style: AppFont.dropDowmLabel(context),
        ),
        Expanded(child: Container()),
        Text(
          '$count', // Use dynamic value
          style: AppFont.dropDowmLabel(context),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallHistory(
                  category: category,
                  mobile: mobile,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 25,
            color: AppColors.iconGrey,
          ),
        ),
      ],
    );
  }

// Helper method to get icon color based on category
  Color _getIconColor(String category) {
    switch (category) {
      case 'outgoing':
        return AppColors.colorsBlue;
      case 'incoming':
        return AppColors.sideGreen;
      case 'missed':
        return AppColors.sideRed;
      case 'rejected':
        return AppColors.iconGrey;
      default:
        return AppColors.iconGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLightGrey,
        title: Text('Enquiry', style: AppFont.appbarfontgrey(context)),
        actions: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppColors.iconGrey),
          onPressed: () {
            // Navigator.pop(context, true);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BottomNavigation()));
          },
        ),
        elevation: 0,
      ),
      body: Stack(children: [
        Scaffold(
          body: Container(
            width: double.infinity, // ✅ Ensures full width
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundLightGrey,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Main Container with Flexbox Layout
                      Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              // Profile Section (Icon, Name, Divider, Gmail, Car Name)
                              Row(
                                children: [
                                  // Profile Icon and Name
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                                textAlign: TextAlign.left,
                                                lead_owner,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black)),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        Text(PMI,
                                            maxLines: 4,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isHiddenTop = !_isHiddenTop;
                                          });
                                        },
                                        icon: Icon(
                                          _isHiddenTop
                                              ? Icons
                                                  .keyboard_arrow_down_rounded
                                              : Icons.keyboard_arrow_up_rounded,
                                          size: 35,
                                          color: AppColors.iconGrey,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Contact Details Section (Phone, Company, Address)
                              if (!_isHiddenTop) ...[
                                const Divider(
                                  thickness: 0.5,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    // Left Section: Phone Number and Company
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.phone,
                                        title: 'Phone Number',
                                        subtitle: mobile,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.location_on,
                                        title: 'Company',
                                        subtitle: company,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.alt_route_outlined,
                                        title: 'Status',
                                        subtitle:
                                            status, // Replace with the actual address variable
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.person,
                                        title: 'Address',
                                        subtitle:
                                            'Malad', // Replace with the actual address variable
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Left Section: Phone Number and Company
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons
                                            .account_balance_wallet_outlined,
                                        title: 'Car budget',
                                        subtitle: '2xxxxxxx',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.directions_car,
                                        title: 'Brand',
                                        subtitle: PMI,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.directions_car,
                                        title: 'Purchase type',
                                        subtitle:
                                            purchase_type, // Replace with the actual address variable
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.local_gas_station,
                                        title: 'Fuel type',
                                        subtitle:
                                            fuel_type, // Replace with the actual address variable
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Left Section: Phone Number and Company
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.calendar_month,
                                        title: 'Expected purchase date',
                                        subtitle:
                                            formatDate(expected_date_purchase),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildContactRow(
                                        icon: Icons.directions_car,
                                        title: 'Enquiry type',
                                        subtitle: enquiry_type,
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          )),
                      const SizedBox(height: 10), // Spacer
                      // History Section
                      // Text('hiii'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildToggleSwitch(),
                                // TextButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       _isHidden = !_isHidden;
                                //     });
                                //   },
                                //   child: Text(
                                //     _isHidden ? 'Show' : 'Hide',
                                //     style: GoogleFonts.poppins(
                                //         fontSize: 15,
                                //         fontWeight: FontWeight.w500,
                                //         color: Colors.black),
                                //   ),
                                // ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isHidden = !_isHidden;
                                    });
                                  },
                                  icon: Icon(
                                    _isHidden
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.keyboard_arrow_up_rounded,
                                    size: 35,
                                    color: AppColors.iconGrey,
                                  ),
                                ),
                              ],
                            ),

                            // Show only if _isHidden is false
                            if (!_isHidden) ...[
                              //  i want to show here the timeline eight and nine
                              // and nine data
                              _selectedTaskWidget,
                            ]
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // _buildToggleSwitch(),
                                Row(
                                  children: [
                                    Text(
                                      'Call logs',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WhatsappChat(
                                                      chatId: chatId,
                                                      userName: lead_owner,
                                                    )));
                                      },
                                      child: Text(
                                        'Whatsapp',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // TextButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       _isHiddenMiddle = !_isHiddenMiddle;
                                //     });
                                //   },
                                //   child: Text(
                                //     _isHiddenMiddle ? 'Show' : 'Hide',
                                //     style: GoogleFonts.poppins(
                                //         fontSize: 15,
                                //         fontWeight: FontWeight.w500,
                                //         color: Colors.black),
                                //   ),
                                // ),

                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isHiddenMiddle = !_isHiddenMiddle;
                                    });
                                  },
                                  icon: Icon(
                                    _isHiddenMiddle
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.keyboard_arrow_up_rounded,
                                    size: 35,
                                    color: AppColors.iconGrey,
                                  ),
                                ),
                              ],
                            ),
                            if (!_isHiddenMiddle) ...[
                              _callLogsWidget(context),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Floating Action Button

        Positioned(
          bottom: 16,
          right: 16,
          child: _buildFloatingActionButton(context),
        ),

        // Popup Menu (Conditionally Rendered)
        Obx(() => fabController.isFabExpanded.value
            ? _buildPopupMenu(context)
            : SizedBox.shrink()),
      ]),
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

  // Popup Menu Builder
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
                  _buildPopupItem(Icons.call, "Followup", -40, onTap: () {
                    fabController.closeFab();
                    _showFollowupPopup(context, widget.leadId);
                  }),
                  _buildPopupItem(
                      Icons.calendar_month_outlined, "Appointment", -80,
                      onTap: () {
                    fabController.closeFab();
                    _showAppointmentPopup(context, widget.leadId);
                  }),
                  _buildPopupItem(Icons.directions_car, "Test Drive", -20,
                      onTap: () {
                    fabController.closeFab();
                    _showTestdrivePopup(context, widget.leadId);
                  }),
                ],
              ),
            ),
          ),

          // ✅ FAB positioned above the overlay
          Positioned(
            bottom: 16,
            right: 16,
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
}

class ContactRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String taskId;

  const ContactRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.taskId,
  });

  @override
  State<ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<ContactRow> {
  String phoneNumber = 'Loading...';
  String email = 'Loading...';
  String status = 'Loading...';
  String company = 'Loading...';
  String address = 'Loading...';
  String lead_owner = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchSingleIdData(widget.taskId); // Fetch data when widget is initialized
  }

  Future<void> fetchSingleIdData(String taskId) async {
    try {
      final leadData = await LeadsSrv.singleFollowupsById(taskId);
      setState(() {
        phoneNumber = leadData['data']['mobile'] ?? 'N/A';
        email = leadData['data']['lead_email'] ?? 'N/A';
        status = leadData['data']['status'] ?? 'N/A';
        company = leadData['data']['PMI'] ?? 'N/A';
        address = leadData['data']['address'] ?? 'N/A';
        lead_owner = leadData['data']['lead_owner'] ?? 'N/A';
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text at the top
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 241, 248, 255)),
            child: Icon(
              widget.icon,
              size: 25,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.fontColor),
                ),
                // const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fontBlack),
                  softWrap: true, // Allows text wrapping
                  overflow: TextOverflow.visible, // Ensures no cutoff
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationController extends GetxController {
  final RxBool isFabExpanded = false.obs;

  void toggleFab() {
    // Add a slight delay to ensure smooth animation
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
      isFabExpanded.toggle();
    });
  }
}
