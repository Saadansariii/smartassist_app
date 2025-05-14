import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FollowupsTeams extends StatefulWidget {
  final Function onFormSubmit;
  const FollowupsTeams({
    super.key,
    required this.onFormSubmit,
  });

  @override
  State<FollowupsTeams> createState() => _FollowupsTeamsState();
}

class _FollowupsTeamsState extends State<FollowupsTeams> {
  Map<String, String> _errors = {};
  TextEditingController startTimeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  final TextEditingController _searchControllerAssignee =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController modelInterestController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoadingSearch = false;
  String _query = '';
  String? selectedLeads;
  String? selectedLeadsName;
  String _selectedSubject = '';
  String? selectedStatus;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  bool _isLoadingAssignee = false;
  String? spId;
  String _assigneeQuery = '';
  List<dynamic> _searchResultsAssignee = [];
  String? selectedAssigneName;
  String? selectedAssigne;
  String? selectedAssigneEmail;

  @override
  void initState() {
    super.initState();
    _searchController
        .addListener(_onSearchChanged); // Initialize speech recognition
    _speech = stt.SpeechToText();
    _searchControllerAssignee.addListener(_onAssigneeSearchChanged);

    _initSpeech();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _searchControllerAssignee.removeListener(_onAssigneeSearchChanged);
    _searchControllerAssignee.dispose();
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

  Future<void> _fetchAssigneeSearchResults(String query) async {
    print(
        "Inside _fetchAssigneeSearchResults with query: '$query'"); // Debug print

    if (query.isEmpty) {
      setState(() {
        _searchResultsAssignee.clear();
      });
      return;
    }

    setState(() {
      _isLoadingAssignee = true;
    });

    try {
      final token = await Storage.getToken();
      print(
          "Token retrieved: ${token != null ? 'Yes' : 'No'}"); // Debug token presence

      final apiUrl =
          'https://dev.smartassistapp.in/api/search/users?user=$query';
      print("API URL: $apiUrl"); // Debug URL

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          "API Response status: ${response.statusCode}"); // Debug response code
      print("API Response body: ${response.body}"); // Debug response data

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          // _searchResultsAssignee = data['data']['suggestions'] ?? [];
          _searchResultsAssignee = data['data']['results'] ?? [];

          print(
              "Search results loaded: ${_searchResultsAssignee.length}"); // Debug results
        });
      } else {
        print("API error: ${response.statusCode} - ${response.body}");
        showErrorMessage(context, message: 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception during API call: $e"); // Debug exception
      showErrorMessage(context, message: 'Something went wrong..! $e');
    } finally {
      setState(() {
        _isLoadingAssignee = false;
      });
    }
  }

  void _onAssigneeSearchChanged() {
    final newQuery = _searchControllerAssignee.text.trim();
    if (newQuery == _assigneeQuery) return;

    _assigneeQuery = newQuery;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_assigneeQuery == _searchControllerAssignee.text.trim()) {
        _fetchAssigneeSearchResults(_assigneeQuery);
      }
    });
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

  /// Fetch search results from API
  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
    });

    final token = await Storage.getToken();

    try {
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/search/global?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data['data']['suggestions'] ?? [];
        });
      }
    } catch (e) {
      showErrorMessage(context, message: 'Something went wrong..!');
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  /// Handle search input change
  void _onSearchChanged() {
    final newQuery = _searchController.text.trim();
    if (newQuery == _query) return;

    _query = newQuery;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_query == _searchController.text.trim()) {
        _fetchSearchResults(_query);
      }
    });
  }

  /// Open date picker
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        _errors.remove('');
      });
    }
  }

  // bool _validation() {
  //   bool isValid = true;

  //   setState(() {
  //     _errors = {};

  //     if (dateController.text.trim().isEmpty) {
  //       _errors['date'] = 'Date is required';
  //       isValid = false;
  //     }
  //   });

  //   return isValid;
  // }

  void _submit() {
    // if (_validation()) {
    submitForm();
    // }
  }

  /// Submit form
  Future<void> submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? spId = prefs.getString('user_id');

    if (spId == null) {
      showErrorMessage(context,
          message: 'User ID not found. Please log in again.');
      return;
    }

    // Parse and format the selected dates/times.
    final rawStartDate =
        DateFormat('dd MMM yyyy').parse(startDateController.text);
    final rawEndDate = DateFormat('dd MMM yyyy')
        .parse(endDateController.text); // Automatically set

    final rawStartTime = DateFormat('hh:mm a').parse(startTimeController.text);
    final rawEndTime = DateFormat('hh:mm a')
        .parse(endTimeController.text); // Automatically set

    // Format for API
    final formattedStartDate = DateFormat('dd/MM/yyyy').format(rawStartDate);
    final formattedEndDate =
        DateFormat('dd/MM/yyyy').format(rawEndDate); // Automatically set

    final formattedStartTime = DateFormat('HH:mm:ss').format(rawStartTime);
    final formattedEndTime =
        DateFormat('HH:mm:ss').format(rawEndTime); // Automatically set

    final newTaskForLead = {
      'subject': _selectedSubject,
      'status': 'Not Started',
      'priority': 'High',
      'time': formattedStartTime,
      'due_date': formattedStartDate,
      'comments': descriptionController.text,
      'sp_id': spId,
      'assignee': selectedAssigne,
      'lead_id': selectedLeads,
    };

    bool success =
        await LeadsSrv.submitFollowups(newTaskForLead, selectedLeads!);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up submitted successfully!')),
      );
      widget.onFormSubmit();
    } else {
      showErrorMessage(context, message: 'Submission failed. Try again.');
    }
  }

//  Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required String hint,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5.0),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppColors.fontBlack,
//             ),
//           ),
//         ),
//         Container(
//           height: MediaQuery.of(context).size.height * .055,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: AppColors.containerBg,
//           ),
//           child: Row(
//             children: [
//               // TextField itself
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     hintText: hint,
//                     hintStyle: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                     border: InputBorder.none,
//                   ),
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               // Microphone icon with speech recognition
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   onPressed: () => _toggleListening(controller),
//                   icon: Icon(
//                     _isListening ? FontAwesomeIcons.stop : FontAwesomeIcons.microphone,
//                     color: _isListening ? Colors.red : AppColors.fontColor,
//                     size: 15,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontBlack,
            ),
          ),
        ),
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

  Future<void> _pickStartDate() async {
    FocusScope.of(context).unfocus();

    // Get current start date or use today
    DateTime initialDate;
    try {
      if (startDateController.text.isNotEmpty) {
        initialDate = DateFormat('dd MMM yyyy').parse(startDateController.text);
      } else {
        initialDate = DateTime.now();
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);

      setState(() {
        // Set start date
        startDateController.text = formattedDate;

        // Set end date to the same as start date but not visible in the UI
        // (Only passed to API)
        endDateController.text = formattedDate;
      });
    }
  }

  Future<void> _pickStartTime() async {
    FocusScope.of(context).unfocus();

    // Get current time from startTimeController or use current time
    TimeOfDay initialTime;
    try {
      if (startTimeController.text.isNotEmpty) {
        final parsedTime =
            DateFormat('hh:mm a').parse(startTimeController.text);
        initialTime =
            TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } else {
        initialTime = TimeOfDay.now();
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      // Create a temporary DateTime to format the time
      final now = DateTime.now();
      final time = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      String formattedTime = DateFormat('hh:mm a').format(time);

      // Calculate end time (1 hour later)
      final endHour = (pickedTime.hour + 1) % 24;
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, pickedTime.minute);
      String formattedEndTime = DateFormat('hh:mm a').format(endTime);

      setState(() {
        // Set start time
        startTimeController.text = formattedTime;

        // Set end time to 1 hour later but not visible in the UI
        // (Only passed to API)
        endTimeController.text = formattedEndTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plan a Followup',
                    style: AppFont.popupTitleBlack(context)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    textAlign: TextAlign.start,
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.colorsBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            _buildSearchField(),
            const SizedBox(height: 10),
            // _buildDatePicker(
            //     label: 'Select date:',
            //     controller: dateController,
            //     // errorText: _errors['date'],
            //     onTap: _pickDate),
            // const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     _selectedInput(
            //       label: "Priority:",
            //       options: ["High"],
            //     ),
            //   ],
            // ),

            _buildButtons(
              label: 'Action:',
              // options: ['Call', 'Provide Quotation', 'Send Email'],
              options: {
                "Call": "Call",
                // 'Provide quotation': "Provide Quotation",
                // "Send Email": "Send Email",
                "Send SMS": "Send SMS"
              },
              groupValue: _selectedSubject,
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Text(
                  'When?',
                  style: AppFont.dropDowmLabel(context),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: _buildDatePicker(
                    controller: startDateController,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDatePicker1(
                    controller: startTimeController,
                    onTap: _pickStartTime,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            _buildAssigneSearch(),
            const SizedBox(height: 10),
            _buildTextField(
                label: 'Comments:',
                controller: descriptionController,
                hint: 'Add Comments'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              const Color.fromRGBO(217, 217, 217, 1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Assign to bot",
                          textAlign: TextAlign.center,
                          style: AppFont.buttons(context))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.colorsBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: _submit,
                    child: Text("I'll do it", style: AppFont.buttons(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedInput({
    required String label,
    required List<String> options,
  }) {
    return Flexible(
      // Use Flexible instead of Expanded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
            child: Text(label, style: AppFont.dropDowmLabel(context)),
          ),
          const SizedBox(height: 3),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                constraints: const BoxConstraints(minWidth: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.containerBg,
                ),
                child: Text(option, style: AppFont.dropDown(context)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget _buildDatePicker({
  //   required String label,
  //   required TextEditingController controller,
  //   required VoidCallback onTap,
  //   String? errorText,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // const SizedBox(height: 1),
  //       Padding(
  //         padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 5),
  //         child: Text(
  //           label,
  //           style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //               color: AppColors.fontBlack),
  //         ),
  //       ),
  //       // const SizedBox(height: 2),
  //       GestureDetector(
  //         onTap: onTap,
  //         child: Container(
  //           height: 45,
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               // color: AppColors.containerPopBg,
  //               border: errorText != null
  //                   ? Border.all(color: Colors.redAccent)
  //                   : Border.all(color: Colors.black, width: .5)),
  //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   controller.text.isEmpty ? "DD / MM / YY" : controller.text,
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: controller.text.isEmpty
  //                         ? AppColors.fontColor
  //                         : AppColors.fontColor,
  //                   ),
  //                 ),
  //               ),
  //               const Icon(
  //                 Icons.calendar_month,
  //                 color: AppColors.fontColor,
  //                 size: 20,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   required String label,
  //   required TextEditingController controller,
  //   required String hint,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 5.0),
  //         child: Text(
  //           label,
  //           style: GoogleFonts.poppins(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: AppColors.fontBlack,
  //           ),
  //         ),
  //       ),
  //       Container(
  //         height:
  //             MediaQuery.of(context).size.height * .055, // Set a fixed height
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5),
  //           color: AppColors.containerBg,
  //         ),
  //         child: Row(
  //           children: [
  //             // TextField itself
  //             Expanded(
  //               child: TextField(
  //                 controller: controller,
  //                 decoration: InputDecoration(
  //                   hintText: hint,
  //                   hintStyle: GoogleFonts.poppins(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.grey,
  //                   ),
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
  //                   border: InputBorder.none,
  //                 ),
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ),
  //             // Suffix icon (microphone)
  //             Align(
  //               alignment: Alignment.centerRight,
  //               child: IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(
  //                   FontAwesomeIcons.microphone,
  //                   color: AppColors.fontColor,
  //                   size: 15, // Adjust the size for better alignment
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTextField({
  //   required String label,
  //   required TextEditingController controller,
  //   required String hint,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 5.0),
  //         child: Text(
  //           label,
  //           style: GoogleFonts.poppins(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: AppColors.fontBlack,
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5),
  //           color: AppColors.containerBg,
  //         ),
  //         child: Row(
  //           children: [
  //             // TextField itself
  //             Expanded(
  //               child: TextField(
  //                 controller: controller,
  //                 decoration: InputDecoration(
  //                   hintText: hint,
  //                   hintStyle: GoogleFonts.poppins(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.grey,
  //                   ),
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
  //                   border: InputBorder.none,
  //                 ),
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ),
  //             // Suffix icon (microphone)
  //             TextButton(
  //               onPressed: () {},
  //               child: const Align(
  //                 alignment: Alignment.centerRight,
  //                 child: Icon(
  //                   FontAwesomeIcons.microphone,
  //                   color: AppColors.fontColor,
  //                   size: 16, // Adjust the size for better alignment
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAssigneSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Assignee', style: AppFont.dropDowmLabel(context)),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchControllerAssignee,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.containerBg,
                    hintText: selectedAssigneName ?? 'Select Assignee',
                    hintStyle: TextStyle(
                      color: selectedAssigneName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 15,
                      color: AppColors.fontColor,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  onTap: () {
                    // If there is a selected lead, populate the text field with its name
                    if (selectedAssigneName != null &&
                        _searchControllerAssignee.text.isEmpty) {
                      _searchControllerAssignee.text = selectedAssigneName!;
                      _searchControllerAssignee.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                            offset: _searchControllerAssignee.text.length),
                      );
                    }
                  },
                  onChanged: (value) {
                    print("TextField onChanged: '$value'"); // Additional debug
                  },
                ),
              ),
            ],
          ),
        ),

        // Show loading indicator
        if (_isLoadingAssignee)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show search results
        if (_searchResultsAssignee.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResultsAssignee.length,
              itemBuilder: (context, index) {
                final result = _searchResultsAssignee[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      spId = result['user_id'];
                      selectedAssigne = result['user_id'];
                      selectedAssigneName = result['name'];
                      selectedAssigneEmail = result['email'];

                      _searchControllerAssignee.clear();
                      _searchResultsAssignee.clear();
                    });
                  },
                  title: Text(
                    result['name'] ?? 'No Name',
                    style: GoogleFonts.poppins(
                      color: selectedAssigne == result['user_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  subtitle: Text(
                    result['email'] ?? 'No Email',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: selectedAssigne == result['user_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  leading: const Icon(Icons.person),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Lead', style: AppFont.dropDowmLabel(context)),
        const SizedBox(height: 5),
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.containerBg,
                      hintText: selectedLeadsName ?? 'Select Leads',
                      hintStyle: TextStyle(
                        color: selectedLeadsName != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 15,
                        color: AppColors.fontColor,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.microphone,
                          color: AppColors.fontColor,
                          size: 15,
                        ),
                        onPressed: () {
                          print('Microphone button pressed');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Show loading indicator
        if (_isLoadingSearch)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show search results
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      selectedLeads = result['lead_id'];
                      selectedLeadsName = result['lead_name'];
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                  title: Text(
                    result['lead_name'] ?? 'No Name',
                    style: TextStyle(
                      color: selectedLeads == result['lead_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  leading: const Icon(Icons.person),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 248, 247, 247),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Select" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.fontColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker1({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 248, 247, 247),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Select" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.watch_later_outlined,
                  color: AppColors.fontColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons({
    required Map<String, String> options, // ✅ Short display & actual value
    required String groupValue,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5, 0, 5),
            child: Text(label, style: AppFont.dropDowmLabel(context)),
          ),
        ),
        const SizedBox(height: 5),

        // ✅ Wrap ensures buttons move to next line when needed
        Wrap(
          spacing: 10, // Space between buttons
          runSpacing: 10, // Space between lines
          children: options.keys.map((shortText) {
            bool isSelected =
                groupValue == options[shortText]; // ✅ Compare actual value

            return GestureDetector(
              onTap: () {
                onChanged(
                    options[shortText]!); // ✅ Pass actual value on selection
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.black,
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : AppColors.innerContainerBg,
                ),
                child: Text(
                  shortText, // ✅ Only show short text
                  style: TextStyle(
                    color: isSelected ? Colors.blue : AppColors.fontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 5),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:smart_assist/utils/storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_assist/services/leads_srv.dart';
// import 'package:smart_assist/utils/snackbar_helper.dart';
// import 'package:smart_assist/utils/style_text.dart';

// class CreateFollowupsPopups extends StatefulWidget {
//   final Function onFormSubmit;
//   const CreateFollowupsPopups({
//     super.key,
//     required this.onFormSubmit,
//   });

//   @override
//   State<CreateFollowupsPopups> createState() => _CreateFollowupsPopupsState();
// }

// class _CreateFollowupsPopupsState extends State<CreateFollowupsPopups> {
//   Map<String, String> _errors = {};

//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   TextEditingController modelInterestController = TextEditingController();

//   List<dynamic> _searchResults = [];
//   bool _isLoadingSearch = false;
//   String _query = '';
//   String? selectedLeads;
//   String? selectedLeadsName;
//   String _selectedSubject = '';
//   String? selectedStatus;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   /// Fetch search results from API
//   Future<void> _fetchSearchResults(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults.clear();
//       });
//       return;
//     }

//     setState(() {
//       _isLoadingSearch = true;
//     });

//     final token = await Storage.getToken();

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://dev.smartassistapp.in/api/search/global?query=$query'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _searchResults = data['data']['suggestions'] ?? [];
//         });
//       }
//     } catch (e) {
//       showErrorMessage(context, message: 'Something went wrong..!');
//     } finally {
//       setState(() {
//         _isLoadingSearch = false;
//       });
//     }
//   }

//   /// Handle search input change
//   void _onSearchChanged() {
//     final newQuery = _searchController.text.trim();
//     if (newQuery == _query) return;

//     _query = newQuery;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (_query == _searchController.text.trim()) {
//         _fetchSearchResults(_query);
//       }
//     });
//   }

//   /// Open date picker
//   Future<void> _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//         _errors.remove('');
//       });
//     }
//   }

//   bool _validation() {
//     bool isValid = true;

//     setState(() {
//       _errors = {};

//       if (dateController.text.trim().isEmpty) {
//         _errors['date'] = 'Date is required';
//         isValid = false;
//       }
//     });

//     return isValid;
//   }

//   void _submit() {
//     if (_validation()) {
//       submitForm();
//     }
//   }

//   /// Submit form
//   Future<void> submitForm() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? spId = prefs.getString('user_id');

//     if (spId == null) {
//       showErrorMessage(context,
//           message: 'User ID not found. Please log in again.');
//       return;
//     }

//     final newTaskForLead = {
//       'subject': _selectedSubject,
//       'status': 'Not Started',
//       'priority': 'High',
//       'due_date': dateController.text,
//       'comments': descriptionController.text,
//       'sp_id': spId,
//       'lead_id': selectedLeads,
//     };

//     bool success =
//         await LeadsSrv.submitFollowups(newTaskForLead, selectedLeads!);

//     if (success) {
//       Navigator.pop(context, true);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Follow-up submitted successfully!')),
//       );
//       widget.onFormSubmit();
//     } else {
//       showErrorMessage(context, message: 'Submission failed. Try again.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Plan a Followup',
//                     style: AppFont.popupTitleBlack(context)),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(
//                     textAlign: TextAlign.start,
//                     'Cancel',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       color: AppColors.colorsBlue,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             _buildSearchField(),
//             const SizedBox(height: 10),
//             _buildDatePicker(
//                 label: 'Select date:',
//                 controller: dateController,
//                 errorText: _errors['date'],
//                 onTap: _pickDate),
//             const SizedBox(height: 10),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.start,
//             //   children: [
//             //     _selectedInput(
//             //       label: "Priority:",
//             //       options: ["High"],
//             //     ),
//             //   ],
//             // ),
//             _buildButtons(
//               label: 'Action:',
//               // options: ['Call', 'Provide Quotation', 'Send Email'],
//               options: {
//                 "Call": "Call",
//                 'Provide quotation': "Provide Quotation",
//                 "Send Email": "Send Email",
//                 "Send SMS": "Send Email"
//               },
//               groupValue: _selectedSubject,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedSubject = value;
//                 });
//               },
//             ),
//             _buildTextField(
//                 label: 'Comments:',
//                 controller: descriptionController,
//                 hint: 'Add Comments'),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           backgroundColor:
//                               const Color.fromRGBO(217, 217, 217, 1),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5))),
//                       onPressed: () => Navigator.pop(context),
//                       child: Text("Assign to bot",
//                           textAlign: TextAlign.center,
//                           style: AppFont.buttons(context))),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.zero,
//                         backgroundColor: AppColors.colorsBlue,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5))),
//                     onPressed: _submit,
//                     child: Text("I'll do it", style: AppFont.buttons(context)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _selectedInput({
//     required String label,
//     required List<String> options,
//   }) {
//     return Flexible(
//       // Use Flexible instead of Expanded
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 5),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
//             child: Text(label, style: AppFont.dropDowmLabel(context)),
//           ),
//           const SizedBox(height: 3),
//           Wrap(
//             alignment: WrapAlignment.start,
//             spacing: 10,
//             runSpacing: 10,
//             children: options.map((option) {
//               return Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 constraints: const BoxConstraints(minWidth: 50),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                   color: AppColors.containerBg,
//                 ),
//                 child: Text(option, style: AppFont.dropDown(context)),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDatePicker({
//     required String label,
//     required TextEditingController controller,
//     required VoidCallback onTap,
//     String? errorText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // const SizedBox(height: 1),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 5),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.fontBlack),
//           ),
//         ),
//         // const SizedBox(height: 2),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 45,
//             width: double.infinity,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 // color: AppColors.containerPopBg,
//                 border: errorText != null
//                     ? Border.all(color: Colors.redAccent)
//                     : Border.all(color: Colors.black, width: .5)),
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     controller.text.isEmpty ? "DD / MM / YY" : controller.text,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: controller.text.isEmpty
//                           ? AppColors.fontColor
//                           : AppColors.fontColor,
//                     ),
//                   ),
//                 ),
//                 const Icon(
//                   Icons.calendar_month,
//                   color: AppColors.fontColor,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required String hint,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5.0),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppColors.fontBlack,
//             ),
//           ),
//         ),
//         Container(
//           height:
//               MediaQuery.of(context).size.height * .055, // Set a fixed height
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: AppColors.containerBg,
//           ),
//           child: Row(
//             children: [
//               // TextField itself
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     hintText: hint,
//                     hintStyle: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                     border: InputBorder.none,
//                   ),
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               // Suffix icon (microphone)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   onPressed: () {},
//                   icon: const Icon(
//                     FontAwesomeIcons.microphone,
//                     color: AppColors.fontColor,
//                     size: 15, // Adjust the size for better alignment
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildTextField({
//   //   required String label,
//   //   required TextEditingController controller,
//   //   required String hint,
//   // }) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Padding(
//   //         padding: const EdgeInsets.symmetric(vertical: 5.0),
//   //         child: Text(
//   //           label,
//   //           style: GoogleFonts.poppins(
//   //             fontSize: 14,
//   //             fontWeight: FontWeight.w500,
//   //             color: AppColors.fontBlack,
//   //           ),
//   //         ),
//   //       ),
//   //       Container(
//   //         width: double.infinity,
//   //         decoration: BoxDecoration(
//   //           borderRadius: BorderRadius.circular(5),
//   //           color: AppColors.containerBg,
//   //         ),
//   //         child: Row(
//   //           children: [
//   //             // TextField itself
//   //             Expanded(
//   //               child: TextField(
//   //                 controller: controller,
//   //                 decoration: InputDecoration(
//   //                   hintText: hint,
//   //                   hintStyle: GoogleFonts.poppins(
//   //                     fontSize: 14,
//   //                     fontWeight: FontWeight.w500,
//   //                     color: Colors.grey,
//   //                   ),
//   //                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//   //                   border: InputBorder.none,
//   //                 ),
//   //                 style: GoogleFonts.poppins(
//   //                   fontSize: 14,
//   //                   fontWeight: FontWeight.w500,
//   //                   color: Colors.black,
//   //                 ),
//   //               ),
//   //             ),
//   //             // Suffix icon (microphone)
//   //             TextButton(
//   //               onPressed: () {},
//   //               child: const Align(
//   //                 alignment: Alignment.centerRight,
//   //                 child: Icon(
//   //                   FontAwesomeIcons.microphone,
//   //                   color: AppColors.fontColor,
//   //                   size: 16, // Adjust the size for better alignment
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//   Widget _buildSearchField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Select Lead', style: AppFont.dropDowmLabel(context)),
//         const SizedBox(height: 5),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.055,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: AppColors.containerBg,
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                       filled: true,
//                       fillColor: AppColors.containerBg,
//                       hintText: selectedLeadsName ?? 'Select Leads',
//                       hintStyle: TextStyle(
//                         color: selectedLeadsName != null
//                             ? Colors.black
//                             : Colors.grey,
//                       ),
//                       prefixIcon: const Icon(
//                         FontAwesomeIcons.magnifyingGlass,
//                         size: 15,
//                         color: AppColors.fontColor,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: const Icon(
//                           FontAwesomeIcons.microphone,
//                           color: AppColors.fontColor,
//                           size: 15,
//                         ),
//                         onPressed: () {
//                           print('Microphone button pressed');
//                         },
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Show loading indicator
//         if (_isLoadingSearch)
//           const Padding(
//             padding: EdgeInsets.only(top: 8.0),
//             child: Center(child: CircularProgressIndicator()),
//           ),

//         // Show search results
//         if (_searchResults.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(5),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black12, blurRadius: 4)
//               ],
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _searchResults.length,
//               itemBuilder: (context, index) {
//                 final result = _searchResults[index];
//                 return ListTile(
//                   onTap: () {
//                     setState(() {
//                       FocusScope.of(context).unfocus();
//                       selectedLeads = result['lead_id'];
//                       selectedLeadsName = result['lead_name'];
//                       _searchController.clear();
//                       _searchResults.clear();
//                     });
//                   },
//                   title: Text(
//                     result['lead_name'] ?? 'No Name',
//                     style: TextStyle(
//                       color: selectedLeads == result['lead_id']
//                           ? Colors.black
//                           : AppColors.fontBlack,
//                     ),
//                   ),
//                   leading: const Icon(Icons.person),
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   // Widget _buildSearchField() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Text('Select Lead', style: AppFont.dropDowmLabel(context)),
//   //       const SizedBox(height: 5),
//   //       Container(
//   //         height: MediaQuery.of(context).size.height *
//   //             .055, // Match height from previous widget
//   //         width: double.infinity,
//   //         decoration: BoxDecoration(
//   //           borderRadius: BorderRadius.circular(5),
//   //           color: AppColors.containerBg,
//   //         ),
//   //         child: Row(
//   //           children: [
//   //             // TextField itself
//   //             Expanded(
//   //               child: Align(
//   //                 alignment: Alignment.bottomCenter,
//   //                 child: TextField(
//   //                   controller: _searchController,
//   //                   onTap: () => FocusScope.of(context).unfocus(),
//   //                   decoration: InputDecoration(
//   //                     filled: true,
//   //                     alignLabelWithHint: true,
//   //                     fillColor: AppColors.containerBg,
//   //                     hintText: selectedLeadsName ?? 'Select Leads',
//   //                     hintStyle: TextStyle(
//   //                         color: selectedLeadsName != null
//   //                             ? Colors.black
//   //                             : Colors.grey),
//   //                     prefixIcon: const Icon(
//   //                       FontAwesomeIcons.magnifyingGlass,
//   //                       size: 15,
//   //                       color: AppColors.fontColor,
//   //                     ),
//   //                     suffixIcon: IconButton(
//   //                       icon: const Icon(
//   //                         FontAwesomeIcons.microphone,
//   //                         color: AppColors.fontColor,
//   //                         size: 15, // Adjusted to match sizing
//   //                       ),
//   //                       onPressed: () {
//   //                         // Implement the action for the microphone button here
//   //                         print('Microphone button pressed');
//   //                       },
//   //                     ),
//   //                     border: OutlineInputBorder(
//   //                       borderRadius: BorderRadius.circular(5),
//   //                       borderSide: BorderSide.none,
//   //                     ),
//   //                   ),
//   //                   style: GoogleFonts.poppins(
//   //                     fontSize: 14,
//   //                     fontWeight: FontWeight.w500,
//   //                     color: Colors.black,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       if (_isLoadingSearch) const Center(child: CircularProgressIndicator()),
//   //       if (_searchResults.isNotEmpty)
//   //         Positioned(
//   //           top: 60, // Adjusted top positioning for proper dropdown placement
//   //           left: 20,
//   //           right: 20,
//   //           child: Material(
//   //             elevation: 5,
//   //             child: Container(
//   //               decoration: BoxDecoration(
//   //                 color: Colors.white,
//   //                 borderRadius: BorderRadius.circular(5),
//   //               ),
//   //               child: ListView.builder(
//   //                 shrinkWrap: true, // Shrink to fit the content height
//   //                 physics:
//   //                     NeverScrollableScrollPhysics(), // Prevent scrolling inside the dropdown
//   //                 itemCount: _searchResults.length,
//   //                 itemBuilder: (context, index) {
//   //                   final result = _searchResults[index];
//   //                   return ListTile(
//   //                     onTap: () {
//   //                       setState(() {
//   //                         FocusScope.of(context).unfocus();
//   //                         selectedLeads = result['lead_id'];
//   //                         selectedLeadsName = result['lead_name'];
//   //                         _searchController.clear();
//   //                         _searchResults.clear();
//   //                       });
//   //                     },
//   //                     title: Text(
//   //                       result['lead_name'] ?? 'No Name',
//   //                       style: TextStyle(
//   //                         color: selectedLeads == result['lead_id']
//   //                             ? Colors.black // Selected item color
//   //                             : AppColors.fontBlack, // Default color
//   //                       ),
//   //                     ),
//   //                     leading: const Icon(Icons.person),
//   //                   );
//   //                 },
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //     ],
//   //   );
//   // }

//   Widget _buildButtons({
//     required Map<String, String> options, // ✅ Short display & actual value
//     required String groupValue,
//     required String label,
//     required ValueChanged<String> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(0.0, 5, 0, 5),
//             child: Text(label, style: AppFont.dropDowmLabel(context)),
//           ),
//         ),
//         const SizedBox(height: 5),

//         // ✅ Wrap ensures buttons move to next line when needed
//         Wrap(
//           spacing: 10, // Space between buttons
//           runSpacing: 10, // Space between lines
//           children: options.keys.map((shortText) {
//             bool isSelected =
//                 groupValue == options[shortText]; // ✅ Compare actual value

//             return GestureDetector(
//               onTap: () {
//                 onChanged(
//                     options[shortText]!); // ✅ Pass actual value on selection
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: isSelected ? Colors.blue : Colors.black,
//                     width: .5,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   color: isSelected
//                       ? Colors.blue.withOpacity(0.2)
//                       : AppColors.innerContainerBg,
//                 ),
//                 child: Text(
//                   shortText, // ✅ Only show short text
//                   style: TextStyle(
//                     color: isSelected ? Colors.blue : AppColors.fontColor,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),

//         const SizedBox(height: 5),
//       ],
//     );
//   }
// }
