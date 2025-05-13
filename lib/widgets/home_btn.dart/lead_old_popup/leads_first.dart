import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/color/colors.dart';
import 'dart:convert';
import 'package:smart_assist/widgets/home_btn.dart/lead_old_popup/leads_second.dart';
import 'package:smart_assist/utils/storage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadFirstStep extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String selectedPurchaseType;
  final String selectedSubType;
  final String selectedFuelType;
  final String selectedBrand;
  final String? email;
  final String? selectedEvent;

  const LeadFirstStep({
    Key? key,
    required this.selectedPurchaseType,
    required this.selectedSubType,
    required this.selectedFuelType,
    required this.selectedBrand,
    this.firstName,
    this.lastName,
    this.email,
    this.selectedEvent,
  }) : super(key: key);

  @override
  _LeadFirstStepState createState() => _LeadFirstStepState();
}

class _LeadFirstStepState extends State<LeadFirstStep> {
  // controller
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String fName = '';
  String? firstName;
  String? lastName;
  String? email;
  String? selectedEvent;
  String? selectedEventId;
  // List<String> dropdownItems = [];
  List<Map<String, String>> dropdownItems = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchDropdownData();
    selectedEvent = widget.selectedEvent;

    // Initialize controllers if values exist

    if (selectedEventId == null) {
      fetchDropdownData();
    }

    if (widget.firstName != null) {
      firstNameController.text = widget.firstName!;
    }
    if (widget.lastName != null) {
      lastNameController.text = widget.lastName!;
    }
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
  }

  Future<void> fetchDropdownData() async {
    const String apiUrl = "https://dev.smartassistapp.in/api/admin/users/all";

    final token = await Storage.getToken();
    if (token == null) {
      print("No token found. Please login.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data['rows'] as List;

        setState(() {
          dropdownItems = rows.map((row) {
            return {
              "name": row['name'] as String,
              "id": row['user_id'] as String,
            };
          }).toList();

          // Do NOT auto-select any value
          // selectedEvent = dropdownItems.isNotEmpty ? dropdownItems.first["id"] : null;
        });

        isLoading = false;
      } else {
        print("Failed with status code: ${response.statusCode}");
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
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
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Add New Leads',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 5
              // ),
              _buildSectionTitle('Assign to:'),
              _buildDropdown(
                // label: 'Assign to:',
                hint: 'Select an Option',
                value: selectedEventId, // Now storing ID instead of name
                items:
                    dropdownItems, // Must be a List of { "id": ..., "name": ... }
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEventId = newValue; // Store selected ID
                  });
                },
              ),

              // const SizedBox(height: 10),

              const SizedBox(height: 10),

              _buildSectionTitle('First Name:'),
              _buildTextField(
                controller: firstNameController,
                hintText: 'John',
                onChanged: (value) {
                  print("lastName: $value");
                },
              ),
              const SizedBox(height: 10),

              _buildSectionTitle('Last Name:'),
              _buildTextField(
                controller: lastNameController,
                hintText: 'Deo',
                onChanged: (value) {
                  print("lastName: $value");
                },
              ),
              const SizedBox(height: 10),

              _buildSectionTitle('Email:'),
              _buildTextField(
                controller: emailController,
                hintText: 'AlexCarter@gmail.com',
                onChanged: (value) {
                  print("email: $value");
                },
              ),
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
                        child: Text('Cancel',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty ||
                            emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all the fields.')),
                          );
                          return;
                        }

                        if (!isValidEmail(emailController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a valid email address.')),
                          );
                          return;
                        }

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
                              child: LeadsSecond(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                selectedPurchaseType: '',
                                selectedFuelType: '',
                                selectedBrand: '',
                                selectedSubType: '',
                                selectedEvent: selectedEvent!,
                                selectedFuel: '',
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  String? selectedEventId;

  Widget _buildDropdown({
    // required String label,
    required String hint,
    required String? value, // Store selected ID
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: GoogleFonts.poppins(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500,
        //     color: Colors.black,
        //   ),
        // ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value, // Ensure value is the selected ID
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.containerPopBg,
          ),
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.fontColor,
            size: 30,
          ),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item["id"], // Store ID as value
              child: Text(
                item["name"] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a value';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Reusable TextField Builder

// Title widget
  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        textAlign: TextAlign.start,
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.containerPopBg,
      ),
      child: TextField(
        controller: controller, // Assign the controller
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
