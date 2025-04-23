import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_id_screens/single_leads.dart';
import 'package:smart_assist/pages/home/single_id_screens/single_leads.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/services/leads_srv.dart';

class LeadsIds extends StatefulWidget {
  const LeadsIds({super.key});

  @override
  State<LeadsIds> createState() => _LeadsIdsState();
}

class _LeadsIdsState extends State<LeadsIds> {
  final PageController _pageController = PageController();
  List<Map<String, String>> dropdownItems = [];
  // final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int _currentStep = 0;

  // Form error tracking
  Map<String, String> _errors = {};

  String _selectedBrand = '';
  String _selectedType = '';
  String _selectedFuel = '';
  String _selectedPurchaseType = '';
  String _selectedEnquiryType = '';

  // Define constants
  final double _minValue = 4000000; // 40 lakhs
  final double _maxValue = 20000000; // 200 lakhs (2 crore)

  // Initialize range values within min-max bounds
  late RangeValues _rangeAmount;

  // String  selectedLeads = '';
  // String selectedPurchaseType = 'New Vehicle';
  // String selectedType = 'Product';
  String selectedSubType = 'Retail';
  // String selectedTire = 'New';
  // String? selectedSubject;
  // String? selectedPriority;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController modelInterestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rangeAmount = RangeValues(_minValue, _maxValue);
    // fetchDropdownData();
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        if (isStartDate) {
          startDateController.text = formattedDate;
          _errors.remove('startDate');
        } else {
          endDateController.text = formattedDate;
        }
      });
    }
  }

  // Validate page 1 fields
  bool _validatePage1() {
    bool isValid = true;
    setState(() {
      _errors = {}; // Clear previous errors

      // Validate first name
      if (firstNameController.text.trim().isEmpty) {
        _errors['firstName'] = 'First name is required';
        isValid = false;
      }

      // Validate last name
      if (lastNameController.text.trim().isEmpty) {
        _errors['lastName'] = 'Last name is required';
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

      // Validate fuel type
      if (_selectedFuel.isEmpty) {
        _errors['fuel'] = 'Please select a fuel type';
        isValid = false;
      }

      // Validate purchase type
      if (_selectedPurchaseType.isEmpty) {
        _errors['purchaseType'] = 'Please select a purchase type';
        isValid = false;
      }

      // Validate enquiry type
      if (_selectedEnquiryType.isEmpty) {
        _errors['enquiryType'] = 'Please select an enquiry type';
        isValid = false;
      }

      // Validate primary model interest
      // if (modelInterestController.text.trim().isEmpty) {
      //   _errors['model'] = 'Primary model interest is required';
      //   isValid = false;
      // }

      // Validate expected purchase date
      if (endDateController.text.trim().isEmpty) {
        _errors['purchaseDate'] = 'Expected purchase date is required';
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
      // Validate first page before proceeding
      if (_validatePage1()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep++);
      } else {
        // Show a snackbar with validation errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please correct the errors before continuing'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Validate second page before submitting
      if (_validatePage2()) {
        _submitForm();
      } else {
        print('select the fiels first');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() {
    submitForm();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text('Add New Enquiry',
                    style: AppFont.popupTitleBlack(context)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
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
                          margin: const EdgeInsets.only(
                              bottom: 17), // Move line up to align with circles
                          height: 2,
                          color: _currentStep == 1
                              ? Colors.grey.shade300
                              : Colors.grey.shade300,
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
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: height * .57,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                label: 'First Name',
                                controller: firstNameController,
                                hintText: 'first name',
                                errorText: _errors['firstName'],
                                onChanged: (value) {
                                  if (_errors.containsKey('firstName')) {
                                    setState(() {
                                      _errors.remove('firstName');
                                    });
                                  }
                                  print("firstName : $value");
                                }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                                label: 'Last Name',
                                errorText: _errors['lastName'],
                                controller: lastNameController,
                                hintText: 'Last name',
                                onChanged: (value) {
                                  if (_errors.containsKey('lastName')) {
                                    setState(() {
                                      _errors.remove('lastName');
                                    });
                                  }
                                  print("lastName : $value");
                                }),
                          )
                        ],
                      ),
                      _buildTextField(
                          label: 'Email',
                          controller: emailController,
                          hintText: 'Email',
                          errorText: _errors['email'],
                          onChanged: (value) {
                            if (_errors.containsKey('email')) {
                              setState(() {
                                _errors.remove('email');
                              });
                            }
                            print("email : $value");
                          }),
                      _buildTextField(
                          label: 'Mobile No',
                          controller: mobileController,
                          errorText: _errors['mobile'],
                          hintText: '+91',
                          onChanged: (value) {
                            if (_errors.containsKey('mobile')) {
                              setState(() {
                                _errors.remove('mobile');
                              });
                            }
                            print("mobile : $value");
                          }),
                      const SizedBox(
                        height: 5,
                      ),
                      _buildButtons(
                        label: 'Lead Source',
                        options: {"Email": "Email", "Online Add": "Online Add"},
                        groupValue: _selectedType,
                        errorText: _errors['leadSource'],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                            if (_errors.containsKey('leadSource')) {
                              _errors.remove('leadSource');
                            }
                          });
                        },
                      ),
                      _buildAmountRange(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      _buildButtonsFloat(
                          options: {
                            "Jaguar": "Jaguar",
                            "Land Rover": "Land Rover",
                          },
                          groupValue: _selectedBrand,
                          label: 'Brand',
                          errorText: _errors['brand'],
                          onChanged: (value) {
                            setState(() {
                              _selectedBrand = value;
                              if (_errors.containsKey('brand')) {
                                _errors.remove('brand');
                              }
                            });
                          }),
                      const SizedBox(height: 10),

                      _buildButtonsFloat(
                          options: {
                            // "EV": "EV",
                            "Petrol": "Petrol",
                            "Diesel": "Diesel",
                          },
                          groupValue: _selectedFuel,
                          label: 'Fuel Type',
                          errorText: _errors['fuel'],
                          onChanged: (value) {
                            setState(() {
                              if (_errors.containsKey('fuel')) {
                                _errors.remove('fuel');
                              }
                              _selectedFuel = value;
                            });
                          }),
                      const SizedBox(height: 10),
                      _buildButtonsFloat(
                          options: {
                            "New": "New Vehicle",
                            "Pre-Owned": "Used Vehicle",
                          },
                          groupValue: _selectedPurchaseType,
                          label: 'Purchase Type',
                          errorText: _errors['purchaseType'],
                          onChanged: (value) {
                            setState(() {
                              _selectedPurchaseType = value;
                              if (_errors.containsKey('purchaseType')) {
                                _errors.remove('purchaseType');
                              }
                            });
                          }),
                      const SizedBox(height: 10),
                      _buildButtonsFloat(
                          options: {
                            "KMI": "KMI",
                            "Generic":
                                "(Generic) Purchase intent within 90 days",
                          },
                          groupValue: _selectedEnquiryType,
                          label: 'Enquiry Type',
                          errorText: _errors['enquiryType'],
                          onChanged: (value) {
                            setState(() {
                              _selectedEnquiryType = value;
                              if (_errors.containsKey('enquiryType')) {
                                _errors.remove('enquiryType');
                              }
                            });
                          }),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text('Primary Model Intrest',
                              style: AppFont.dropDowmLabel(context)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 45,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Keep border radius small
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Match with enabledBorder
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: AppColors.containerBg,
                            hintText: 'Type',
                            hintStyle: AppFont.dropDown(context),
                            prefixIcon: const Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: AppColors.fontColor,
                              size: 15,
                            ),
                            // suffixIcon: const Icon(
                            //   FontAwesomeIcons.microphone,
                            //   color: AppColors.fontColor,
                            //   size: 15,
                            // ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 2),
                      _buildDatePicker(
                          label: 'Expected purchase date',
                          controller: endDateController,
                          errorText: _errors['purchaseDate'],
                          onTap: () => _pickDate(isStartDate: false)),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ Updated Button Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      if (_currentStep == 0) {
                        Navigator.pop(context); // Close if on first page
                      } else {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
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
                      backgroundColor: AppColors.colorsBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == 1 ? "Create" : "Continue",
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
        const SizedBox(
          height: 5,
        ),
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
        const SizedBox(
          height: 5,
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
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.fontBlack),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // color: AppColors.containerPopBg,
                border: errorText != null
                    ? Border.all(color: Colors.red)
                    : Border.all(color: Colors.black, width: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "DD / MM / YY" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty
                          ? AppColors.fontColor
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.fontBlack,
                ),
              ],
            ),
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
    String? errorText,
  }) {
    List<String> optionKeys = options.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        // if (errorText != null)
        //   Padding(
        //     padding: const EdgeInsets.only(left: 5, top: 0),
        //     child: Text(
        //       errorText,
        //       style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
        //     ),
        //   ),
      ],
    );
  }
  // Widget _buildButtonsFloat({
  //   required Map<String, String> options,
  //   required String groupValue,
  //   required String label,
  //   required ValueChanged<String> onChanged,
  //   String? errorText,
  // }) {
  //   List<String> optionKeys = options.keys.toList();

  //   return Container(
  //     decoration: BoxDecoration(
  //         color: const Color.fromARGB(255, 248, 247, 247),
  //         borderRadius: const BorderRadius.all(Radius.circular(5)),
  //         border: errorText != null
  //             ? Border.all(color: Colors.red, width: 1.0)
  //             : null),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment
  //                 .center, // ✅ Aligns label and buttons properly
  //             children: [
  //               // 🔹 Brand Label (Left Side, Vertically Centered)
  //               SizedBox(
  //                 child: Align(
  //                   alignment:
  //                       Alignment.centerRight, // ✅ Ensures proper alignment
  //                   child: Text(
  //                     label,
  //                     style: AppFont.dropDowmLabel(context),
  //                     textAlign: TextAlign.left,
  //                   ),
  //                 ),
  //               ),

  //               const SizedBox(width: 10),

  //               // 🔹 Right Side: Brand Options in Two Rows
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment:
  //                       CrossAxisAlignment.start, // Align buttons left
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment:
  //                           MainAxisAlignment.end, // ✅ Align left
  //                       children: [
  //                         _buildOptionButton(
  //                             optionKeys[0], options, groupValue, onChanged),
  //                         const SizedBox(width: 5),
  //                         _buildOptionButton(
  //                             optionKeys[1], options, groupValue, onChanged),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAmountRange() {
    // Convert to lakhs for display
    final double startLakh = _rangeAmount.start / 100000;
    final double endLakh = _rangeAmount.end / 100000;

    // Format with one decimal place
    final startText = startLakh.toStringAsFixed(1);
    final endText = endLakh.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        Text(
          "Budget",
          style: AppFont.dropDowmLabel(context),
        ),

        const SizedBox(height: 5),

        // 🔹 Show Selected Range as Text
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            "₹$startText lakh - ₹$endText lakh",
            style: AppFont.smallText(context),
          ),
        ),

        // const SizedBox(height: 5),

        // 🔹 Range Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.colorsBlue,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: AppColors.colorsBlue,
            overlayColor: Colors.blue.withOpacity(0.2),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RangeSlider(
            values: _rangeAmount,
            min: _minValue,
            max: _maxValue,
            divisions: 180, // (200-40) increments of 1 lakh each
            labels: RangeLabels(
              "₹${startText}L",
              "₹${endText}L",
            ),
            onChanged: (RangeValues values) {
              // Round to nearest lakh
              final double newStart = (values.start / 100000).round() * 100000;
              final double newEnd = (values.end / 100000).round() * 100000;

              // Ensure values are within bounds
              final clampedStart = newStart.clamp(_minValue, _maxValue);
              final clampedEnd = newEnd.clamp(_minValue, _maxValue);

              setState(() {
                _rangeAmount = RangeValues(clampedStart, clampedEnd);
              });
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildButtonFuel({
  //   required Map<String, String> options,
  //   required String groupValue,
  //   required String label,
  //   required ValueChanged<String> onChanged,
  //   String? errorText,
  // }) {
  //   List<String> optionKeys = options.keys.toList();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         height: MediaQuery.of(context).size.height * .06,
  //         decoration: BoxDecoration(
  //             color: const Color.fromARGB(255, 248, 247, 247),
  //             borderRadius: const BorderRadius.all(
  //               Radius.circular(5),
  //             ),
  //             border: errorText != null
  //                 ? Border.all(color: Colors.red, width: 1.0)
  //                 : null),
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   SizedBox(
  //                     child: Align(
  //                       alignment:
  //                           Alignment.centerRight, // ✅ Ensures proper alignment
  //                       child: Text(
  //                         label,
  //                         style: AppFont.dropDowmLabel(context),
  //                         textAlign: TextAlign.left,
  //                       ),
  //                     ),
  //                   ),

  //                   const SizedBox(width: 10),

  //                   // 🔹 Right Side: Brand Options in Two Rows
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment:
  //                           CrossAxisAlignment.start, // Align buttons left
  //                       children: [
  //                         Row(
  //                           mainAxisAlignment:
  //                               MainAxisAlignment.end, // ✅ Align left
  //                           children: [
  //                             _buildOptionFuel(optionKeys[0], options,
  //                                 groupValue, onChanged),
  //                             const SizedBox(width: 5),
  //                             _buildOptionFuel(optionKeys[1], options,
  //                                 groupValue, onChanged),
  //                             // const SizedBox(width: 5),
  //                             // _buildOptionFuel(
  //                             //     optionKeys[2], options, groupValue, onChanged),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

// ✅ Button Builder Function
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

  // Widget _buildEnquiryType({
  //   required Map<String, String> options,
  //   required String groupValue,
  //   required String label,
  //   required ValueChanged<String> onChanged,
  //   String? errorText,
  // }) {
  //   List<String> optionKeys = options.keys.toList();

  //   return Container(
  //     height: MediaQuery.of(context).size.height * .06,
  //     decoration: BoxDecoration(
  //       color: const Color.fromARGB(255, 248, 247, 247),
  //       borderRadius: BorderRadius.all(Radius.circular(5)),
  //       border: errorText != null
  //           ? Border.all(color: Colors.red, width: 1.0)
  //           : null,
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment
  //                 .center, // ✅ Aligns label and buttons properly
  //             children: [
  //               // 🔹 Brand Label (Left Side, Vertically Centered)
  //               SizedBox(
  //                 // width: 80, // ✅ Fixed width to align properly
  //                 child: Align(
  //                   alignment:
  //                       Alignment.centerRight, // ✅ Ensures proper alignment
  //                   child: Text(
  //                     label,
  //                     style: AppFont.dropDowmLabel(context),
  //                     textAlign: TextAlign.left,
  //                   ),
  //                 ),
  //               ),

  //               const SizedBox(width: 10),

  //               // 🔹 Right Side: Brand Options in Two Rows
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment:
  //                       CrossAxisAlignment.start, // Align buttons left
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment:
  //                           MainAxisAlignment.end, // ✅ Align left
  //                       children: [
  //                         _buildOptionButtonEnquiry(
  //                             optionKeys[0], options, groupValue, onChanged),
  //                         const SizedBox(width: 5),
  //                         _buildOptionButtonEnquiry(
  //                             optionKeys[1], options, groupValue, onChanged),
  //                         const SizedBox(width: 5),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPurchaseType({
  //   required Map<String, String> options,
  //   required String groupValue,
  //   required String label,
  //   required ValueChanged<String> onChanged,
  //   String? errorText,
  // }) {
  //   List<String> optionKeys = options.keys.toList();

  //   return Container(
  //     height: MediaQuery.of(context).size.height * .06,
  //     decoration: BoxDecoration(
  //         color: const Color.fromARGB(255, 248, 247, 247),
  //         borderRadius: const BorderRadius.all(Radius.circular(5)),
  //         border: errorText != null
  //             ? Border.all(color: Colors.red, width: 1.0)
  //             : null),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               SizedBox(
  //                 child: Align(
  //                   alignment: Alignment.centerRight,
  //                   child: Text(
  //                     label,
  //                     style: AppFont.dropDowmLabel(context),
  //                     textAlign: TextAlign.left,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         _buildOptionButtonPurchase(
  //                             optionKeys[0], options, groupValue, onChanged),
  //                         const SizedBox(width: 5),
  //                         _buildOptionButtonPurchase(
  //                             optionKeys[1], options, groupValue, onChanged),
  //                         const SizedBox(width: 5),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildOptionFuel(String shortText, Map<String, String> options,
  //     String groupValue, ValueChanged<String> onChanged) {
  //   bool isSelected = groupValue == options[shortText];

  //   return GestureDetector(
  //     onTap: () {
  //       onChanged(options[shortText]!);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: isSelected ? AppColors.colorsBlue : Colors.grey,
  //           width: 1.0,
  //         ),
  //         borderRadius: BorderRadius.circular(15),
  //         color:
  //             isSelected ? AppColors.colorsBlue.withOpacity(0.2) : Colors.white,
  //       ),
  //       child: Center(
  //         child: Text(
  //           shortText,
  //           style: TextStyle(
  //             color: isSelected ? AppColors.colorsBlue : Colors.black,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildOptionButtonEnquiry(
  //     String shortText,
  //     Map<String, String> options,
  //     String groupValue,
  //     ValueChanged<String> onChanged) {
  //   bool isSelected = groupValue == options[shortText];

  //   return GestureDetector(
  //     onTap: () {
  //       onChanged(options[shortText]!);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: isSelected ? AppColors.colorsBlue : Colors.grey,
  //           width: 1.0,
  //         ),
  //         borderRadius: BorderRadius.circular(15),
  //         color:
  //             isSelected ? AppColors.colorsBlue.withOpacity(0.2) : Colors.white,
  //       ),
  //       child: Center(
  //         child: Text(
  //           shortText,
  //           style: TextStyle(
  //             color: isSelected ? AppColors.colorsBlue : Colors.black,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildOptionButtonPurchase(
  //     String shortText,
  //     Map<String, String> options,
  //     String groupValue,
  //     ValueChanged<String> onChanged) {
  //   bool isSelected = groupValue == options[shortText];

  //   return GestureDetector(
  //     onTap: () {
  //       onChanged(options[shortText]!);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: isSelected ? AppColors.colorsBlue : Colors.grey,
  //           width: 1.0,
  //         ),
  //         borderRadius: BorderRadius.circular(15),
  //         color:
  //             isSelected ? AppColors.colorsBlue.withOpacity(0.2) : Colors.white,
  //       ),
  //       child: Center(
  //         child: Text(
  //           shortText,
  //           style: TextStyle(
  //             color: isSelected ? AppColors.colorsBlue : Colors.black,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildButtons({
    required Map<String, String>
        options, // ✅ Use a Map for short display & actual value
    required String groupValue,
    required String label,
    String? errorText,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: options.keys.map((shortText) {
            bool isSelected = groupValue == options[shortText];

            return GestureDetector(
              onTap: () {
                onChanged(options[shortText]!);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected ? AppColors.colorsBlue : AppColors.fontColor,
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: isSelected
                      ? AppColors.colorsBlue.withOpacity(0.2)
                      : Colors.white,
                ),
                child: Text(
                  shortText, // ✅ Only show short text
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.colorsBlue : AppColors.fontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

  Future<void> submitForm() async {
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
        print("Error: User ID not found."); // ✅ Print error in console
        return;
      }

      final leadData = {
        'fname': firstNameController.text,
        'lname': lastNameController.text,
        'email': emailController.text,
        'mobile': mobileController.text,
        'purchase_type': _selectedPurchaseType,
        'brand': _selectedBrand,
        'type': 'Product',
        'sub_type': selectedSubType,
        'sp_id': spId,
        'PMI': 'Discovery',
        'expected_date_purchase': endDateController.text,
        'fuel_type': _selectedFuel,
        'enquiry_type': _selectedEnquiryType,
        'lead_source': _selectedType,
      };

      print(
          "Submitting lead data: $leadData"); // ✅ Print lead data before submission

      Map<String, dynamic>? response = await LeadsSrv.submitLead(leadData);

      if (response != null) {
        print("Response received: $response"); // ✅ Print full response

        if (response.containsKey('data')) {
          String leadId = response['data']['lead_id'];

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleLeadsById(leadId: leadId),
              ),
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form Submit Successful.')),
          );
        } else if (response.containsKey('error')) {
          String errorMsg = response['error'];
          print("API Error: $errorMsg"); // ✅ Log API error

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      } else {
        print("Error: API response is null"); // ✅ Log null response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit lead. Please try again.')),
        );
      }
    } catch (e, stackTrace) {
      print("Exception Occurred: $e"); // ✅ Log any unexpected exceptions
      print("Stack Trace: $stackTrace"); // ✅ Print stack trace for debugging

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }
}
