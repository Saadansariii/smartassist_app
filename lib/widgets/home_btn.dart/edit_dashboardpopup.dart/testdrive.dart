import 'package:dropdown_button2/dropdown_button2.dart';
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

class Testdrive extends StatefulWidget {
  final String eventId;
  final Function onFormSubmit;
  const Testdrive({
    super.key,
    required this.onFormSubmit,
    required this.eventId,
  });

  @override
  State<Testdrive> createState() => _TestdriveState();
}

class _TestdriveState extends State<Testdrive> {
  Map<String, String> _errors = {};
  TextEditingController startTimeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController modelInterestController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoadingSearch = false;
  String _query = '';
  String? selectedLeads;
  String? selectedLeadsName;
  String _selectedSubject = '';
  String? selectedStatus;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _fetchDataId();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _fetchDataId() async {
    setState(() {
      _isLoadingSearch = true;
    });

    final token = await Storage.getToken();

    try {
      final response = await http.get(
        Uri.parse('https://dev.smartassistapp.in/api/events/${widget.eventId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String comment = data['data']['remarks'] ?? '';
        final String status = data['data']['status'] ?? '';
        descriptionController.text = comment;
        // statusController.text = status;
        // Set dropdown selected value if it matches one of the items
        if (items.contains(status)) {
          selectedValue = status;
        }
      }
    } catch (e) {
      showErrorMessage(context, message: 'Something went wrong..!');
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
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
    String? spId = prefs.getString('user_id');
    final token = await Storage.getToken();

    if (spId == null) {
      showErrorMessage(context,
          message: 'User ID not found. Please log in again.');
      return;
    }

    final newTaskForLead = {
      'comments': descriptionController.text,
      'status': selectedValue,
      'sp_id': spId,
    };

    // 👇 Print the body you're about to send
    print('Sending PUT request body: ${jsonEncode(newTaskForLead)}');

    try {
      final response = await http.put(
        Uri.parse(
            'https://dev.smartassistapp.in/api/events/update/${widget.eventId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newTaskForLead),
      );

      // 👇 Log response status and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print(response.body);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up submitted successfully!')),
        );
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String message =
            responseData['message'] ?? 'Submission failed. Try again.';
        showErrorMessage(context, message: message);
        print(response.body);
      }
    } catch (e) {
      showErrorMessage(context,
          message: 'Something went wrong. Please try again.');
      print('Error during PUT request: $e');
    }
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
            borderRadius: BorderRadius.circular(10),
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

  final List<String> items = [
    'Planned',
    'No Show',
  ];
  String? selectedValue;

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(item, style: AppFont.dropDowmLabel(context)),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (items.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
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
                Text('Update Test-drive',
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        'Status :',
                        style: AppFont.dropDowmLabel(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundLightGrey,
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        style: const TextStyle(color: AppColors.fontColor),
                        isExpanded: true,
                        hint: Text(
                          'Select Item',
                          style: AppFont.dropDowmLabelLightcolors(context),
                        ),
                        items: _addDividersAfterItems(items),
                        value: selectedValue,
                        onChanged: (String? value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 40,
                          width: double.infinity,
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2))),
                          maxHeight: 200,
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          customHeights: _getCustomItemsHeights(),
                        ),
                        iconStyleData: const IconStyleData(
                          openMenuIcon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      'Remarks :',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fontBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                      // label: 'Remark :',
                      controller: descriptionController,
                      hint: 'Add Comments'),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
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
