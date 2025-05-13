import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LeadUpdate extends StatefulWidget {
  final Function onFormSubmit;
  final String leadId;
  const LeadUpdate(
      {super.key, required this.onFormSubmit, required this.leadId});

  @override
  State<LeadUpdate> createState() => _LeadUpdateState();
}

class _LeadUpdateState extends State<LeadUpdate> {
  final PageController _pageController = PageController();
  bool isLoading = true;
  int _currentStep = 0;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isSubmitting = false;

  // Form error tracking
  Map<String, String> _errors = {};
  bool _isLoadingSearch = false;
  String _selectedBrand = '';
  String _selectedEnquiryType = '';
  Map<String, dynamic>? _existingLeadData;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController modelInterestController = TextEditingController();
  bool consentValue = false;

  @override
  void initState() {
    super.initState();
    // Initialize speech recognition
    _speech = stt.SpeechToText();
    _initSpeech();
    _fetchLeadData();
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

  // Fetch lead data by ID to populate the form
  Future<void> _fetchLeadData() async {
    setState(() {
      isLoading = true;
    });

    final token = await Storage.getToken();

    try {
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/leads/by-id/${widget.leadId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Populate the form with existing data
        if (data['data'] != null) {
          setState(() {
            _existingLeadData = data['data'];

            // Set form field values
            nameController.text = data['data']['lead_name'] ?? '';
            emailController.text = data['data']['email'] ?? '';

            // Handle mobile number formatting (remove +91 if present)
            String mobile = data['data']['mobile'] ?? '';
            if (mobile.startsWith('+91')) {
              mobile = mobile.substring(3); // Remove +91 prefix
            }
            mobileController.text = mobile;

            // Set dropdown values
            _selectedBrand = data['data']['brand'] ?? '';
            _selectedEnquiryType = data['data']['enquiry_type'] ?? '';

            // Set model interest
            modelInterestController.text = data['data']['PMI'] ?? '';
          });
        }
      } else {
        showErrorMessage(context, message: 'Failed to fetch lead data');
      }
    } catch (e) {
      showErrorMessage(context,
          message: 'Something went wrong: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add this helper method for showing error messages
  void showErrorMessage(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validate page 1 fields
  bool _validatePage1() {
    bool isValid = true;
    setState(() {
      _errors = {}; // Clear previous errors

      // Validate first name
      if (nameController.text.trim().isEmpty) {
        _errors['name'] = 'Name is required';
        isValid = false;
      }

      // Validate email
      if (emailController.text.trim().isEmpty) {
        _errors['email'] = 'Email is required';
        isValid = false;
      } else if (!_isValidEmail(emailController.text.trim())) {
        _errors['email'] = 'Please enter a valid email';
        isValid = false;
      }

      // Validate mobile
      if (mobileController.text.trim().isEmpty) {
        _errors['mobile'] = 'Mobile number is required';
        isValid = false;
      } else if (!_isValidMobile(mobileController.text.trim())) {
        _errors['mobile'] = 'Please enter a valid 10-digit mobile number';
        isValid = false;
      }
    });

    return isValid;
  }

  // Validate page 2 fields
  bool _validatePage2() {
    bool isValid = true;
    setState(() {
      _errors = {}; // Clear previous errors

      // Validate brand
      if (_selectedBrand.isEmpty) {
        _errors['brand'] = 'Please select a brand';
        isValid = false;
      }

      // Validate enquiry type if needed
      if (_selectedEnquiryType.isEmpty) {
        _errors['enquiryType'] = 'Please select an enquiry type';
        isValid = false;
      }
    });

    return isValid;
  }

  // Email validation
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  // Mobile validation
  bool _isValidMobile(String mobile) {
    // Remove any non-digit characters
    String digitsOnly = mobile.replaceAll(RegExp(r'\D'), '');

    // Check if it's 10 digits (standard Indian mobile number)
    return digitsOnly.length == 10;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_validatePage1()) {
        setState(() => _currentStep++);
        // No need for PageController navigation with IndexedStack
      } else {
        Get.snackbar(
          'Error',
          'Please check the contact details',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      if (_validatePage2()) {
        _submitForm(); // Submit form after second page
      } else {
        Get.snackbar(
          'Error',
          'Please check the vehicle details',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      await submitLeadUpdate();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Submission failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text('Update Lead',
                          style: AppFont.popupTitleBlack(context)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      // Step indicators with line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Step 1 indicator column
                            Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _currentStep == 0
                                        ? AppColors.colorsBlue
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        color: _currentStep == 0
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Contact \nDetails',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _currentStep == 0
                                        ? AppColors.colorsBlue
                                        : Colors.grey,
                                    fontWeight: _currentStep == 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),

                            // Connector line
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 17),
                                height: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),

                            // Step 2 indicator column
                            Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _currentStep == 1
                                        ? AppColors.colorsBlue
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        color: _currentStep == 1
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Vehicle \nDetails',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _currentStep == 1
                                        ? AppColors.colorsBlue
                                        : Colors.grey,
                                    fontWeight: _currentStep == 1
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Page content
                  IndexedStack(
                    index: _currentStep,
                    children: [
                      // First page - Contact Details
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                label: 'Name',
                                controller: nameController,
                                hintText: 'Enter name',
                                errorText: _errors['name'],
                                isRequired: true,
                                onChanged: (value) {
                                  if (_errors.containsKey('name')) {
                                    setState(() {
                                      _errors.remove('name');
                                    });
                                  }
                                }),
                            _buildTextField(
                                label: 'Email',
                                controller: emailController,
                                hintText: 'Email address',
                                errorText: _errors['email'],
                                isRequired: true,
                                onChanged: (value) {
                                  if (_errors.containsKey('email')) {
                                    setState(() {
                                      _errors.remove('email');
                                    });
                                  }
                                }),
                            _buildNumberWidget(
                              label: 'Mobile No',
                              controller: mobileController,
                              errorText: _errors['mobile'],
                              hintText: 'Mobile number',
                              isRequired: true,
                              onChanged: (value) {
                                if (_errors.containsKey('mobile')) {
                                  setState(() {
                                    _errors.remove('mobile');
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // Second page - Vehicle Details
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildButtonsFloat(
                                options: {
                                  "Jaguar": "Jaguar",
                                  "Land Rover": "Land Rover",
                                },
                                groupValue: _selectedBrand,
                                label: 'Brand',
                                errorText: _errors['brand'],
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBrand = value;
                                    if (_errors.containsKey('brand')) {
                                      _errors.remove('brand');
                                    }
                                  });
                                }),
                            const SizedBox(height: 15),
                            _buildEnquiryTypeSelector(
                                options: {
                                  "KMI": "KMI",
                                  "Generic": "Generic",
                                },
                                groupValue: _selectedEnquiryType,
                                errorText: _errors['enquiryType'],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEnquiryType = value;
                                    if (_errors.containsKey('enquiryType')) {
                                      _errors.remove('enquiryType');
                                    }
                                  });
                                }),
                            const SizedBox(height: 15),
                            _buildTextField(
                                label: 'Primary Model Interest',
                                controller: modelInterestController,
                                hintText: 'Enter model name',
                                errorText: _errors['model'],
                                onChanged: (value) {
                                  if (_errors.containsKey('model')) {
                                    setState(() {
                                      _errors.remove('model');
                                    });
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(217, 217, 217, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            if (_currentStep == 0) {
                              Navigator.pop(context); // Close if on first page
                            } else {
                              setState(() => _currentStep--);
                            }
                          },
                          child: Text(
                            _currentStep == 0 ? "Cancel" : "Previous",
                            style: AppFont.buttons(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorsBlueButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: isSubmitting ? null : _nextStep,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep == 1 ? "Update" : "Continue",
                                  style: AppFont.buttons(context),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNumberWidget({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 248, 247, 247),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : null,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              controller: controller,
              style: AppFont.dropDowmLabel(context),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.fontBlack,
              ),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 248, 247, 247),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : null,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              style: AppFont.dropDowmLabel(context),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildButtonsFloat({
    required Map<String, String> options,
    required String groupValue,
    required String label,
    required ValueChanged<String> onChanged,
    bool isRequired = false,
    String? errorText,
  }) {
    List<String> optionKeys = options.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 248, 247, 247),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: RichText(
                        text: TextSpan(
                          style: AppFont.dropDowmLabel(context),
                          children: [
                            TextSpan(text: label),
                            if (isRequired)
                              const TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildOptionButton(optionKeys[0], options,
                                  groupValue, onChanged),
                              const SizedBox(width: 5),
                              _buildOptionButton(optionKeys[1], options,
                                  groupValue, onChanged),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildEnquiryTypeSelector({
    required Map<String, String> options,
    required String groupValue,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.fontBlack,
              ),
              children: [
                TextSpan(text: 'Enquiry Type'),
                const TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 248, 247, 247),
            border: errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.entries.map((entry) {
                bool isSelected = groupValue == entry.value;
                return GestureDetector(
                  onTap: () {
                    onChanged(entry.value);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.colorsBlue : Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: isSelected
                          ? AppColors.colorsBlue.withOpacity(0.1)
                          : AppColors.innerContainerBg,
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.colorsBlue
                            : AppColors.fontColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton(String shortText, Map<String, String> options,
      String groupValue, ValueChanged<String> onChanged) {
    bool isSelected = groupValue == options[shortText];

    return GestureDetector(
      onTap: () {
        onChanged(options[shortText]!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.colorsBlue : Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? AppColors.colorsBlue.withOpacity(0.1)
              : AppColors.innerContainerBg,
        ),
        child: Center(
          child: Text(
            shortText,
            style: TextStyle(
              color: isSelected ? AppColors.colorsBlue : AppColors.fontColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> submitLeadUpdate() async {}

  Future<void> submitLeadUpdate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? spId = prefs.getString('user_id');

      if (spId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User ID not found. Please log in again.')),
          );
        }
        return;
      }

      String mobileNumber = mobileController.text;

      // Ensure the mobile number always includes the country code
      if (!mobileNumber.startsWith('+91')) {
        mobileNumber = '+91$mobileNumber';
      }

      final leadData = {
        'name': nameController.text,
        'email': emailController.text,
        'mobile': mobileNumber,
        'brand': _selectedBrand,
        'sp_id': spId,
        'PMI': modelInterestController.text,
        'enquiry_type': _selectedEnquiryType,
      };

      final token = await Storage.getToken();

      final response = await http.put(
        Uri.parse(
            'https://dev.smartassistapp.in/api/leads/update/${widget.leadId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(leadData),
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
}
