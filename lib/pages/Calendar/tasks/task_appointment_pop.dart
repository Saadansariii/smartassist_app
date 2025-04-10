import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/pages/Calendar/tasks/addTask.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';

class TaskAppointmentPop extends StatefulWidget {
  final DateTime? selectedDate;
  final String leadId;
  final String? selectedEvent;
  final String? leadName;
  const TaskAppointmentPop({
    super.key,
    this.selectedDate,
    this.selectedEvent,
    required this.leadId,
    this.leadName,
  });

  @override
  State<TaskAppointmentPop> createState() => _TaskAppointmentPopState();
}

class _TaskAppointmentPopState extends State<TaskAppointmentPop> {
  String? selectedLeads;
  String? selectedSubject;
  String? selectedStatus;
  String? selectedPriority;

  TextEditingController dateController =
      TextEditingController(); // Start Date (fixed)
  TextEditingController enddateController =
      TextEditingController(); // End Date (editable)

  @override
  void initState() {
    super.initState();
    // print('this is appointment oage ');
    // print(widget.leadName);
    // print(widget.leadId);
    print('this is selected appontment ');
    print(widget.selectedDate);
    if (widget.selectedDate != null) {
      dateController.text =
          DateFormat('dd/MM/yyyy').format(widget.selectedDate!);
    }
  }

  // Pick End Date (Any date, past or future)
  Future<void> _pickEndDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000), // Allow past dates from 2000
      lastDate: DateTime(2100), // Allow future dates up to 2100
    );

    if (pickedDate != null) {
      setState(() {
        enddateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Text('Create Appointment', style: AppFont.popupTitle(context)),
                ),
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                label: 'Priority:',
                hint: 'Select',
                value: selectedPriority,
                items: ['High', 'Normal', 'Low'],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value;
                  });
                  print("Selected Priority: $selectedPriority");
                },
              ),
              _buildDropdown(
                label: 'Subject:',
                hint: 'Select',
                value: selectedSubject,
                items: [
                  'Meeting',
                  'Test Drive',
                  'Service Appointment',
                  'Quotation',
                  'Trade in Evaluation',
                  'Showroom appointment',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                  print("Selected Subject: $selectedSubject");
                },
              ),
              const SizedBox(height: 5),
               // End Date (Editable)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('End Date', style: AppFont.dropDowmLabel(context)),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickEndDate,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.containerPopBg,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        enddateController.text.isEmpty
                            ? "Select End Date"
                            : enddateController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: enddateController.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Buttons
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
                                leadId: widget.leadId,
                                leadName: widget.leadName ?? 'check',
                                selectedLeadId: '',
                                initialEvent: widget.selectedEvent,
                                selectedDate: widget.selectedDate,
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
                        color: AppColors.colorsBlue,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spId = prefs.getString('user_id');

    if (spId == null || widget.leadId.isEmpty) {
      showErrorMessage(context, message: 'User ID or Lead ID not found.');
      return;
    }

    // ✅ Get Start Date (Fixed from widget.selectedDate)
    DateTime startDateTime;
    if (widget.selectedDate != null) {
      startDateTime = widget.selectedDate!;
    } else {
      showErrorMessage(context, message: 'Start date is required.');
      return;
    }

    // ✅ Parse End Date (User-selected)
    DateTime endDateTime;
    if (enddateController.text.isNotEmpty) {
      endDateTime = DateFormat('dd/MM/yyyy').parse(enddateController.text);
    } else {
      endDateTime = startDateTime; // Default to start date if not provided
    }

    // ✅ Ensure End Date is not before Start Date
    if (endDateTime.isBefore(startDateTime)) {
      showErrorMessage(context,
          message: 'End date cannot be before start date.');
      return;
    }

    // ✅ Remove `toUtc()` to Fix One-Day-Less Issue
    String formattedEndDate = DateFormat('dd-MM-yyyy').format(endDateTime);

    String formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
    String formattedEndTime = DateFormat('hh:mm a').format(endDateTime);

    final newTaskForLead = {
      // 'start_date': widget.selectedDate,
      'start_date': DateFormat('dd-MM-yyyy').format(widget.selectedDate!),

      'end_date': formattedEndDate, // ✅ Now the correct end date
      'priority': selectedPriority,
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
      'subject': selectedSubject ?? 'Showroom Appointment',
      'sp_id': spId,
    };

    print('Lead Data: $newTaskForLead');

    bool success =
        await LeadsSrv.submitAppoinment(newTaskForLead, widget.leadId);

    if (success) {
      print('Lead submitted successfully!');
      if (context.mounted) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Form Submit Successful.')));
    } else {
      print('Failed to submit lead.');
    }
  }

  // Future<void> submitForm() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? spId = prefs.getString('user_id');

  //   if (spId == null || widget.leadId.isEmpty) {
  //     showErrorMessage(context, message: 'User ID or Lead ID not found.');
  //     return;
  //   }

  //   // Start Date (Fixed from widget.selectedDate)
  //   DateTime startDateTime;
  //   if (widget.selectedDate != null) {
  //     startDateTime = widget.selectedDate!;
  //   } else {
  //     showErrorMessage(context, message: 'Start date is required.');
  //     return;
  //   }

  //   // Parse End Date (User-selected)
  //   DateTime endDateTime;
  //   if (enddateController.text.isNotEmpty) {
  //     endDateTime = DateFormat('dd/MM/yyyy').parse(enddateController.text);
  //   } else {
  //     endDateTime = startDateTime; // Default to start date if not provided
  //   }

  //   // Validate: End date should not be before start date
  //   if (endDateTime.isBefore(startDateTime)) {
  //     showErrorMessage(context,
  //         message: 'End date cannot be before start date.');
  //     return;
  //   }

  //   // Format dates
  //   String formattedStartDate = DateFormat('dd-MM-yyyy').format(startDateTime);

  //   String formattedEndDate = DateFormat('dd-MM-yyyy').format(endDateTime);

  //   String formattedStartTime = DateFormat('hh:mm a').format(startDateTime);
  //   String formattedEndTime = DateFormat('hh:mm a').format(endDateTime);

  //   final newTaskForLead = {
  //     'start_date': formattedStartDate,
  //     'end_date': formattedEndDate,
  //     'priority': selectedPriority,
  //     'start_time': formattedStartTime,
  //     'end_time': formattedEndTime,
  //     'subject': selectedSubject ?? 'Showroom Appointment',
  //     'sp_id': spId,
  //   };

  //   print('Lead Data: $newTaskForLead');

  //   bool success =
  //       await LeadsSrv.submitAppoinment(newTaskForLead, widget.leadId);

  //   if (success) {
  //     print('Lead submitted successfully!');
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //     }
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Form Submit Successful.')));
  //   } else {
  //     print('Failed to submit lead.');
  //   }
  // }

  // Reusable Dropdown Builder
  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppFont.dropDowmLabel(context)),
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
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey,
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
}
