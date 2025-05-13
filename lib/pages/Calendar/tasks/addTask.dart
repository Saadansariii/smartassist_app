import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Calendar/tasks/task_appointment_pop.dart';
import 'package:smart_assist/pages/Calendar/tasks/task_followups_pop.dart';
import 'package:smart_assist/pages/navbar_page/lead_list.dart';
import 'package:smart_assist/utils/storage.dart';

class AddTaskPopup extends StatefulWidget {
  final DateTime? selectedDate;
  final String leadId;
  final String leadName;
  final String selectedLeadId;
  final String? initialEvent;
  const AddTaskPopup(
      {super.key,
      this.selectedDate,
      required this.leadId,
      required this.leadName,
      required this.selectedLeadId,
      this.initialEvent});

  @override
  State<AddTaskPopup> createState() => _AddTaskPopupState();
}

class _AddTaskPopupState extends State<AddTaskPopup> {
  String? selectedEvent;
  String? selectedCustomer;
  String? leadName;
  String? leadId;
  List<String> dropdownItems = [];
  bool isLoading = false;

  String? selectedLeads;

  @override
  void initState() {
    print('this is selected task date ekadjfadjf');
    print(widget.selectedDate);

    super.initState();
    fetchLeadsData();
    leadName = widget.leadName.isNotEmpty ? widget.leadName : null;
    leadId = widget.leadId.isNotEmpty ? widget.leadId : null;
    selectedLeads = widget.leadName;
    selectedEvent = widget.initialEvent;
    leadId = widget.leadId;
    // if (leadId != null) {}
    if (leadName == null || leadId == null) {
      fetchLeadsData();
    }
    // print('this is the selected widget ${widget.selectedDate}');
  }

  Future<void> fetchLeadsData() async {
    const String apiUrl = "https://dev.smartassistapp.in/api/leads/all";

    final token = await Storage.getToken();
    if (token == null) {
      print("No token found. Please login.");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data['data']['rows'] as List;

        print("Extracted Rows: $rows"); // Debug: Ensure rows are extracted

        if (rows.isNotEmpty) {
          // Extract the lead_id from the first row (or any row you need)
          String leadId = rows[0]['lead_id'];
          // storeLeadId(leadId);
        }

        setState(() {
          dropdownItems = rows.map<String>((row) {
            String leadName = row[data]['lead_name'] ??
                "${row['data']['fname'] ?? ''} ${row['data']['lname'] ?? ''}"
                    .trim();
            return leadName.isNotEmpty ? leadName : "Unknown"; // Default name
          }).toList();

          isLoading = false;
        });

        print(
            "Dropdown Items: $dropdownItems"); // Debug: Ensure dropdown is populated
      } else {
        print("Failed with status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9, // Set max width
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keeps height to content size
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Task / Event',
                  style: AppFont.popupTitle(context),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown 1 (Event Type)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Select event / task',
                    style: AppFont.dropDowmLabel(context)),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.containerPopBg,
                ),
                child: DropdownButton<String>(
                  value: selectedEvent,
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("Select", style: AppFont.dropDown(context)),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: <String>['Appointment', 'Followup', 'Test Drive']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child:
                            Text(value, style: AppFont.dropDowmLabel(context)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEvent = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Dropdown 2 (Customer/Client)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    'Leads Name :',
                    style: AppFont.dropDowmLabel(context),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.containerPopBg,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeadsList(),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        leadId = result['leadId'];
                        leadName = result['leadName']; // This will be the fname
                        print('this is the data on add task page $leadName');
                        print('this is the data on add task page $leadId');
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leadName ?? "Select Lead",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                leadName != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Row with Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                        color: AppColors.colorsBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (leadId == null || leadName == null) {
                            print('No lead selected!');
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Plese Selected the Lead First.')));

                            return;
                          }
                          if (selectedEvent == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Plese Selected Events First.')));
                            return;
                          }
                          Navigator.pop(context); // Close the current dialog
                          Future.microtask(() {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.white,
                                insetPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: selectedEvent == 'Appointment'
                                    ? TaskAppointmentPop(
                                        leadId: leadId!,
                                        leadName: leadName,
                                        selectedEvent: selectedEvent,
                                        selectedDate: widget.selectedDate ??
                                            DateTime.now(),
                                      )
                                    : selectedEvent == 'Test Drive'
                                        ? TaskFollowupsPop(
                                            leadId: leadId!,
                                            leadName: leadName,
                                            selectedEvent: selectedEvent,
                                            selectedDate: widget.selectedDate ??
                                                DateTime.now(),
                                          )
                                        : TaskFollowupsPop(
                                            leadId: leadId!,
                                            leadName: leadName,
                                            selectedEvent: selectedEvent,
                                            selectedDate: widget.selectedDate ??
                                                DateTime.now(),
                                          ),
                              ),
                            );
                          });
                        },
                        child: Text('Next', style: AppFont.buttons(context)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Dropdown Builder
  // Widget _buildDropdown({
  //   required String label,
  //   required String hint,
  //   required String? value,
  //   required List<String> items,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Text(
  //         label,
  //         style: AppFont.dropDowmLabel(),
  //       ),
  //       const SizedBox(height: 10),
  //       Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(8),
  //           color: AppColors.containerPopBg,
  //         ),
  //         child: DropdownButton<String>(
  //           value: value,
  //           hint: Padding(
  //             padding: const EdgeInsets.only(left: 10),
  //             child: Text(hint, style: AppFont.dropDown()),
  //           ),
  //           icon: const Padding(
  //             padding: EdgeInsets.only(right: 10.0),
  //             child: Icon(
  //               Icons.keyboard_arrow_down_rounded,
  //               color: Colors.grey,
  //             ),
  //           ),
  //           isExpanded: true,
  //           underline: const SizedBox.shrink(),
  //           items: items.map((String item) {
  //             return DropdownMenuItem<String>(
  //               value: item,
  //               child: Padding(
  //                 padding: const EdgeInsets.only(left: 10.0),
  //                 child: Text(item, style: AppFont.dropDowmLabel()),
  //               ),
  //             );
  //           }).toList(),
  //           onChanged: onChanged,
  //         ),
  //       ),
  //       const SizedBox(height: 10),
  //     ],
  //   );
  // }
}
