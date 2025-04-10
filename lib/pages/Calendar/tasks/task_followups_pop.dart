import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Calendar/tasks/addTask.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';

class TaskFollowupsPop extends StatefulWidget {
  final DateTime? selectedDate;
  final String leadId;
  final String? leadName;
  final String? selectedEvent;
  const TaskFollowupsPop(
      {super.key,
      required this.selectedDate,
      required this.leadName,
      required this.leadId,
      this.selectedEvent});

  @override
  State<TaskFollowupsPop> createState() => _TaskFollowupsPopState();
}

class _TaskFollowupsPopState extends State<TaskFollowupsPop> {
  String? leadName;
  String? leadId;
  DateTime? selectedDate;
  List<String> dropdownItems = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    leadName = widget.leadName;
    leadId = widget.leadId;
    selectedLeads = widget.leadName;
    // fetchDropdownData();
    // print('this is coming from create followups $leadId');
    print('this is coming from create followups $leadName');
    print('this is coming from create followups $leadId');
    // leadId = widget.leadId.isNotEmpty ? widget.leadId : null;
    // leadName = widget.leadName.isNotEmpty ? widget.leadName : null;
    print('InitState leadName: $leadName');
    print('InitState leadId: $leadId');
    leadName = widget.leadName;
    // print('this is the second page ${selectedDate = widget.selectedDate!}');
  }

  String? selectedLeads;
  String? selectedSubject;
  String? selectedStatus;
  String? selectedPriority;
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the date as 'dd/MM/yyyy'
        dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  child: Text('Create Followups', style: AppFont.popupTitle(context)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                  child: Text(
                    'Comments :',
                    style: AppFont.dropDowmLabel(context),
                  ),
                ),
              ),
              Container(
                width: double.infinity, // Full width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.containerPopBg,
                ),
                child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Add Comments",
                      hintStyle: AppFont.dropDown(context),
                      contentPadding: const EdgeInsets.only(left: 10),
                      border: InputBorder.none,
                    ),
                    style: AppFont.dropDowmLabel(context)),
              ),

              const SizedBox(height: 10),

              _buildDropdown(context,
                label: 'Subject:',
                hint: 'Select',
                value: selectedSubject,
                items: [
                  'Call',
                  'Provide Quotation',
                  'Send Email',
                  'Vehicle Selection',
                  'Send SMS',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                  print("Selected Brand: $selectedSubject");
                },
              ),

              _buildDropdown(context,
                label: 'Status:',
                hint: 'Select',
                value: selectedStatus,
                items: [
                  'Not Started',
                  'In Progress',
                  'Completed',
                  'Waiting on someone else',
                  'Deferred',
                  'SMS sent'
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  print("Selected Brand: $selectedStatus");
                },
              ),

              _buildDropdown(context,
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
              const SizedBox(height: 10),

              // buttons
              const SizedBox(height: 10),
              // Row with Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();

                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AddTaskPopup(
                                leadId: leadId ?? '', // Pass the actual leadId
                                leadName: leadName ?? '',
                                selectedLeadId: leadId ?? '',
                                initialEvent: widget.selectedEvent,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
                        child: Text('Submit', style: AppFont.buttons(context)),
                      ),
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
    String description = descriptionController.text;
    String date = widget.selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(widget.selectedDate!)
        : dateController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spId = prefs.getString('user_id');

    print('Retrieved sp_id: $spId');
    print('Retrieved lead_id: ${widget.leadId}'); // Debugging leadId

    if (spId == null || widget.leadId.isEmpty) {
      showErrorMessage(context,
          message: 'User ID or Lead ID not found. Please log in again.');
      return;
    }

    // Prepare the lead data
    final newTaskForLead = {
      'subject': selectedSubject,
      'status': selectedStatus,
      'priority': selectedPriority,
      'due_date': date,
      'comments': descriptionController.text,
      'sp_id': spId,
    };

    print('Lead Data: $newTaskForLead');

    // Pass widget.leadId directly to submitFollowups
    bool success =
        await LeadsSrv.submitFollowups(newTaskForLead, widget.leadId);

    if (success) {
      print('Lead submitted successfully!');

      // Close modal if submission is successful
      if (context.mounted) {
        Navigator.pop(context);
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
Widget _buildDropdown( BuildContext context, {
  required String label,
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Text(
          label,
          style: AppFont.dropDowmLabel(context),
        ),
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
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(Icons.keyboard_arrow_down_rounded),
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
