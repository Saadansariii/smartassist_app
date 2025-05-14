import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
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
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  String lead_name = 'Loading....';
  String expected_date_purchase = 'Loading...';
  String pincode = 'Loading..';
  String lead_status = 'Not Converted';

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

  final TextEditingController descriptionController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

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
      _speech = stt.SpeechToText();
      _initSpeech();
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

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
        showErrorMessage(context,
            message: 'Speech recognition error: ${errorNotification.errorMsg}');
      },
    );
    if (!available) {
      showErrorMessage(context,
          message: 'Speech recognition not available on this device');
    }
  }

// Check if there's any data to determine if buttons should be enabled
  bool areButtonsEnabled() {
    // Return true if any of the lists have data, false if all are empty
    return overdueTasks.isNotEmpty ||
        overdueEvents.isNotEmpty ||
        upcomingTasks.isNotEmpty ||
        upcomingEvents.isNotEmpty ||
        completedTasks.isNotEmpty ||
        completedEvents.isNotEmpty;
  }

  String _getFirstTwoLettersCapitalized(String input) {
    input = input.trim(); // Remove any extra spaces
    if (input.length >= 2) {
      return input.substring(0, 2).toUpperCase();
    } else if (input.isNotEmpty) {
      return input.toUpperCase();
    } else {
      return '';
    }
  }

  // Toggle listening
  void _toggleListening(TextEditingController controller) async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
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
        address = leadData['data']['location'] ?? 'N/A';
        leadSource = leadData['data']['lead_source'] ?? 'N/A';
        fuel_type = leadData['data']['fuel_type'] ?? 'N/A';
        lead_owner = leadData['data']['lead_owner'] ?? 'N/A';
        PMI = leadData['data']['PMI'] ?? 'N/A';
        purchase_type = leadData['data']['purchase_type'] ?? 'N/A';
        enquiry_type = leadData['data']['enquiry_type'] ?? 'N/A';
        expected_date_purchase =
            leadData['data']['expected_date_purchase'] ?? 'N/A';
        lead_name = leadData['data']['lead_name'] ?? 'N/A';
        pincode = leadData['data']['pincode']?.toString() ?? 'N/A';
        lead_status = leadData['data']['opportunity_status'] ?? 'Not Converted';
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  static Future<Map<String, int>> fetchCallLogs(String mobile) async {
    const String apiUrl =
        "https://dev.smartassistapp.in/api/leads/call-logs/all";
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
            color: isActive ? Colors.black : Colors.grey),
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
              onSubmitStatus: fetchSingleIdData,
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

  bool isFabExpanded = false;

  // API call methods
  void handleFabAction() {
    // Your FAB API call logic here
    print('FAB action triggered - API call would happen here');
  }

  void handleLostAction() {
    _showLostDiolog();
    print('Lost API call triggered');
  }

  Future<void> _showLostDiolog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  textAlign: TextAlign.center,
                  'If you wish to mark this enquiry as lost, please provide a reason',
                  style: AppFont.mediumText14(context),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                  // label: 'resion:',
                  controller: descriptionController,
                  hint: 'Add Comments'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pass context to submit
              },
              child: Text(
                'Cancel',
                style: AppFont.mediumText14blue(context),
                // style: TextStyle(color: AppColors.colorsBlue),
              ),
            ),
            TextButton(
              onPressed: () {
                if (descriptionController.text.trim().isEmpty) {
                  // Show a simple error message
                  Get.snackbar(
                    'Error',
                    'Please provide a reason before submitting',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } else {
                  submitLost(context); // Proceed if not empty
                }
              },
              child: Text(
                'Submit',
                style: AppFont.mediumText14blue(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitLost(BuildContext context) async {
    setState(() {
      // _isUploading = true; // If you are showing any loading indicator
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? spId = prefs.getString('user_id');
      final url = Uri.parse(
          'https://dev.smartassistapp.in/api/leads/mark-lost/${widget.leadId}');
      final token = await Storage.getToken();

      // Create the request body
      final requestBody = {
        'sp_id': spId,
        'lost_reason': descriptionController.text,
      };

      // Print the data to console for debugging
      print('Submitting feedback data:');
      print(requestBody);

      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestBody));

      // Print the response
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        // Success handling
        print('Feedback submitted successfully');
        Get.snackbar(
          'Success',
          errorMessage,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Dismiss the dialog after success
      } else {
        // Error handling
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        print('Failed to submit feedback');
        Get.snackbar(
          'Error',
          errorMessage, // Show the backend error message
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Dismiss the dialog on error
      }
    } catch (e) {
      // Exception handling
      print('Exception occurred: ${e.toString()}');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Navigator.pop(context); // Dismiss the dialog on exception
    } finally {
      setState(() {
        // _isUploading = false; // Reset loading state
      });
    }
  }

  void toggleFab() {
    setState(() {
      isFabExpanded = !isFabExpanded;
    });
  }

  Future<void> _showSkipDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  textAlign: TextAlign.center,
                  'Are you sure you want to qualify this lead to an opportunity?',
                  style: AppFont.mediumText14(context),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                // style: TextStyle(color: AppColors.colorsBlue),
                style: AppFont.mediumText14blue(context),
              ),
            ),
            TextButton(
              onPressed: () {
                submitQualify(context); // Pass context to submit
              },
              child: Text(
                'Submit',
                style: AppFont.mediumText14blue(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitQualify(BuildContext context) async {
    setState(() {
      // _isUploading = true; // If you are showing any loading indicator
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? spId = prefs.getString('user_id');
      final url = Uri.parse(
          'https://dev.smartassistapp.in/api/leads/convert-to-opp/${widget.leadId}');
      final token = await Storage.getToken();

      // Create the request body
      final requestBody = {
        'sp_id': spId,
      };

      // Print the data to console for debugging
      print('Submitting feedback data:');
      print(requestBody);

      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestBody));

      // Print the response
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 201) {
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        // Success handling
        print('Feedback submitted successfully');
        Get.snackbar(
          'Success',
          errorMessage,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Dismiss the dialog after success
        await fetchSingleIdData(widget.leadId);
      } else {
        // Error handling
        final errorMessage =
            json.decode(response.body)['message'] ?? 'Unknown error';
        print('Failed to submit feedback');
        Get.snackbar(
          'Error',
          errorMessage, // Show the backend error message
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Dismiss the dialog on error
      }
    } catch (e) {
      // Exception handling
      print('Exception occurred: ${e.toString()}');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Navigator.pop(context); // Dismiss the dialog on exception
    } finally {
      setState(() {
        // _isUploading = false; // Reset loading state
      });
    }
  }

  void handleQualifyAction() {
    _showSkipDialog();
    // API call for Qualify tab
    print('Qualify API call triggered');
  }

  Widget _buildTextField({
    // required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 5.0),
        //   child: Text(
        //     label,
        //     style: GoogleFonts.poppins(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w500,
        //       color: AppColors.fontBlack,
        //     ),
        //   ),
        // ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              // Expanded TextField that adjusts height
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines:
                      null, // This allows the TextField to expand vertically based on content
                  minLines: 1, // Minimum 1 line of height
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              // Microphone icon with speech recognition
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _toggleListening(controller),
                  icon: Icon(
                    _isListening
                        ? FontAwesomeIcons.stop
                        : FontAwesomeIcons.microphone,
                    color: _isListening ? Colors.red : AppColors.fontColor,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.colorsBlueButton,
        // title: Text('Enquiry', style: AppFont.appbarfontWhite(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enquiry', style: AppFont.appbarfontWhite(context)),
            Text('Opportunity Status : $lead_status',
                style: AppFont.smallTextWhite1(context)),
          ],
        ),
        // actions: [
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Text('Enquiry', style: AppFont.appbarfontWhite(context)),
        //       Text('data', style: AppFont.mediumText14white(context))
        //     ],
        //   ),
        // ),
        // ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppColors.white),
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
                                              lead_name,
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
                                            ? Icons.keyboard_arrow_down_rounded
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
                                      title: 'Mobile',
                                      subtitle: mobile,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildContactRow(
                                      icon: Icons.location_on,
                                      title: 'Location',
                                      subtitle: address,
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
                                      title: 'Lead Source',
                                      subtitle:
                                          leadSource, // Replace with the actual address variable
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Left Section: Phone Number and Company
                                  Expanded(
                                    child: _buildContactRow(
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      title: 'Email',
                                      subtitle: email,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildContactRow(
                                      icon: Icons.directions_car,
                                      title: 'Brand',
                                      subtitle: company,
                                    ),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: _buildContactRow(
                              //         icon: Icons.directions_car,
                              //         title: 'Purchase type',
                              //         subtitle:
                              //             purchase_type, // Replace with the actual address variable
                              //       ),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     Expanded(
                              //       child: _buildContactRow(
                              //         icon: Icons.local_gas_station,
                              //         title: 'Fuel type',
                              //         subtitle:
                              //             fuel_type, // Replace with the actual address variable
                              //       ),
                              //     ),
                              //   ],
                              // ),

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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Assignee',
                                        style: AppFont.mediumText14(context),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),

                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: AppColors.homeContainerLeads,
                                        ),
                                        child: Text(
                                          _getFirstTwoLettersCapitalized(
                                              lead_owner),
                                          style:
                                              AppFont.mediumText14blue(context),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      // IconButton(
                                      //     onPressed: () {},
                                      //     icon: Container(
                                      //         padding: EdgeInsets.all(5),
                                      //         decoration: BoxDecoration(
                                      //           borderRadius:
                                      //               BorderRadius.circular(30),
                                      //           color: AppColors
                                      //               .backgroundLightGrey,
                                      //         ),
                                      //         child: const Icon(Icons.add)))
                                    ],
                                  )
                                ],
                              )
                            ],
                          ],
                        ),
                      ),
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
        // Popup Menu overlay (conditionally rendered)
        Obx(() => fabController.isFabExpanded.value
            ? _buildPopupMenu(context)
            : SizedBox.shrink()),
      ]),
      // floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: Stack(alignment: Alignment.bottomCenter, children: [
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Lost Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (areButtonsEnabled()) {
                      handleLostAction();
                    } else {
                      showLostRequiredDialog(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lost',
                      style: AppFont.mediumText14red(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Qualify Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (areButtonsEnabled()) {
                      handleQualifyAction();
                    } else {
                      showTaskRequiredDialog(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF35CB64),
                      // Green color from image
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Qualify',
                      style: AppFont.mediumText14white(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                height: 45,
                child: _buildFloatingActionButton(context),
              ),

              // Popup Menu (Conditionally Rendered)
              // Obx(() => fabController.isFabExpanded.value
              //     ? _buildPopupMenu(context)
              //     : SizedBox.shrink()),
            ],
          ),
        ),
      ]),
    );
  }

// FAB Builder
  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(
      () => GestureDetector(
        // onTap: fabController.toggleFab,
        onTap: fabController.isFabDisabled.value
            ? null // Disable onTap if FAB is disabled
            : fabController.toggleFab,
        child: AnimatedContainer(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * .15,
          height: MediaQuery.of(context).size.height * .08,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: fabController.isFabDisabled.value
                  ? Colors.grey // Grey when disabled
                  : (fabController.isFabExpanded.value
                      ? Colors.red
                      : AppColors.colorsBlue),
            ),
            // color: fabController.isFabExpanded.value
            //     ? Colors.red
            //     : AppColors.colorsBlue,
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child: AnimatedRotation(
              turns: fabController.isFabExpanded.value ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                fabController.isFabExpanded.value ? Icons.close : Icons.add,
                color: fabController.isFabDisabled.value
                    ? Colors.grey // Grey when disabled
                    : (fabController.isFabExpanded.value
                        ? Colors.red
                        : AppColors.colorsBlue),
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Function to show dialog when disabled buttons are clicked
  void showTaskRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  textAlign: TextAlign.center,
                  'Perform atleast one Test Drive before qualifying this enquiry.',
                  style: AppFont.mediumText14(context),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                // style: TextStyle(color: AppColors.colorsBlue),
                style: AppFont.mediumText14blue(context),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     submitQualify(context); // Pass context to submit
            //   },
            //   child: Text(
            //     'Submit',
            //     style: AppFont.mediumText14blue(context),
            //   ),
            // ),
          ],
        );
      },
    );
  }

// Function to show dialog when disabled buttons are clicked
  void showLostRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          contentPadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  textAlign: TextAlign.center,
                  'Cannot mark this Enquiry as lost without performing any actions ',
                  style: AppFont.mediumText14(context),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                // style: TextStyle(color: AppColors.colorsBlue),
                style: AppFont.mediumText14blue(context),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     submitQualify(context); // Pass context to submit
            //   },
            //   child: Text(
            //     'Submit',
            //     style: AppFont.mediumText14blue(context),
            //   ),
            // ),
          ],
        );
      },
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
            bottom: 20,
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
          // Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: _buildFloatingActionButton(context),
          // ),
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
