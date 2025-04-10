import 'package:flutter/material.dart';
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

class CreateAppointment extends StatefulWidget {
  const CreateAppointment({super.key});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  List<String> dropdownItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // fetchDropdownData();
  }

// Store lead_id in SharedPreferences
  Future<void> storeLeadId(String leadId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lead_id', leadId); // Save lead_id in SharedPreferences
    print("Stored lead_id: $leadId"); // Debugging
  }

  String? selectedLeads;
  String? selectedSubject;
  String? selectedStatus;
  String? selectedPriority;

  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  // TextEditingController descriptionController = TextEditingController();

  Future<void> _pickDate({required bool isStartDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date and Time
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          // Format Date & Time as 'dd/MM/yyyy hh:mm a'
          String formattedDateTime =
              DateFormat('dd/MM/yyyy hh:mm a').format(combinedDateTime);

          if (isStartDate) {
            startdateController.text = formattedDateTime;
          } else {
            enddateController.text = formattedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Create Appoinment',
                    style: AppFont.popupTitle(context)),
              ),

              const SizedBox(
                height: 10,
              ),

              _buildDropdown(
                context,
                label: 'Priority:',
                hint: 'Select',
                value: selectedPriority,
                items: ['High', 'Normal', 'Low'],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value;
                  });
                  print("Selected Brand: $selectedPriority ");
                },
              ),

              _buildDropdown(
                context,
                label: 'Subject:',
                hint: 'Select',
                value: selectedSubject,
                items: [
                  "Meeting",
                  "Test Drive",
                  "Showroom appointment",
                  "Service Appointment",
                  "Quotation",
                  "Trade in evaluation"
                ],
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                  print("Selected Brand: $selectedSubject");
                },
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Text('Start Date', style: AppFont.dropDowmLabel(context)),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => _pickDate(isStartDate: true),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.containerPopBg,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          startdateController.text.isEmpty
                              ? "Select Date"
                              : startdateController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: startdateController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.iconGrey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('End Date', style: AppFont.dropDowmLabel(context)),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => _pickDate(isStartDate: false),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.containerPopBg,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          enddateController.text.isEmpty
                              ? "Select Date"
                              : enddateController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: enddateController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.iconGrey,
                      ),
                    ],
                  ),
                ),
              ),

              // buttons
              const SizedBox(height: 30),
              // Row with Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.black, // Cancel button color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close modal on cancel
                        },
                        child: Text('Cancel', style: AppFont.buttons(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                          onPressed: () {
                            submitForm();
                          },
                          child: Text(
                            'Submit',
                            style: AppFont.buttons(context),
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spId = prefs.getString('user_id');
    String? leadId = prefs.getString('lead_id');

    // Convert the selected date-time into DateTime objects
    DateTime startDateTime =
        DateFormat('dd/MM/yyyy hh:mm a').parse(startdateController.text);
    DateTime endDateTime =
        DateFormat('dd/MM/yyyy hh:mm a').parse(enddateController.text);

    // Extract date in 'yyyy-MM-dd' format
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDateTime);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDateTime);

    // Extract time in 'hh:mm a' format
    String formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
    String formattedEndTime = DateFormat('hh:mm a').format(endDateTime);

    print('Retrieved sp_id: $spId');
    print('Retrieved lead_id: $leadId');

    if (spId == null || leadId == null) {
      showErrorMessage(context,
          message: 'User ID or Lead ID not found. Please log in again.');
      return;
    }

    // Prepare the lead data
    final newTaskForLead = {
      'start_date': startdateController.text,
      'end_date': enddateController.text,
      'priority': selectedPriority,
      'start_time': formattedStartTime, // hh:mm a format
      'end_time': formattedEndTime,
      'subject': selectedSubject,
      'sp_id': spId,
    };

    print('Lead Data: $newTaskForLead');

    // Pass the leadId to the submitFollowups function
    bool success = await LeadsSrv.submitAppoinment(newTaskForLead, leadId);

    if (success) {
      print('Lead submitted successfully!');

      // Close modal if submission is successful
      if (context.mounted) {
        Navigator.pop(context); // Closes the modal
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form Submit Successful.')),
      );
    } else {
      print('Failed to submit lead.');
    }
  }
}

// Reusable Dropdown Builder
Widget _buildDropdown(
  BuildContext context, {
  required String label,
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: AppFont.dropDowmLabel(context),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.containerPopBg,
        ),
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(hint, style: AppFont.dropDown(context)),
          ),
          icon: const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(
              Icons.keyboard_arrow_down_sharp,
              color: AppColors.fontColor,
              size: 25,
            ),
          ),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(item, style: AppFont.dropDowmLabel(context)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
