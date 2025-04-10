import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/widgets/home_btn.dart/lead_old_popup/leads_last.dart';
import 'package:smart_assist/widgets/home_btn.dart/lead_old_popup/leads_second.dart';

class LeadsThird extends StatefulWidget {
  final String selectedSource;
  final String selectedPurchaseType;
  final String selectedSubType;
  final String selectedFuelType;
  final String selectedBrand;
  final String firstName;
  final String lastName;
  final String email;
  final String selectedEnquiryType;
  final String selectedEvent;
  final String? mobile;
  final String? pmi;
  final String selectedFuel;
  LeadsThird({
    super.key,
    required,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.selectedPurchaseType,
    required this.selectedSubType,
    required this.selectedFuelType,
    required this.selectedBrand,
    required this.selectedEnquiryType,
    required this.selectedEvent,
    required this.selectedSource,
    this.mobile,
    this.pmi,
    required this.selectedFuel,
  });

  @override
  State<LeadsThird> createState() => _LeadsThirdState();
}

class _LeadsThirdState extends State<LeadsThird> {
  String? selectedPurchaseType;
  String? selectedFuelType;
  String? selectedBrand;
  // Declare the selection variables for dropdowns
  String? selectedEvent;
  String? selectedSource;
  String? selectedEnquiryType;
  String? selectedCustomer;
  String? selectedSubType;
  String? selectedFuel;

  void initState() {
    // TODO: implement initState
    super.initState();
    // selectedPurchaseType = widget.selectedPurchaseType!;
    // selectedFuelType = widget.selectedFuelType!;
    // selectedBrand = widget.selectedBrand!;
    // selectedSubType = widget.selectedSubType!;

    selectedPurchaseType = widget.selectedPurchaseType;
    selectedFuelType = widget.selectedFuelType;
    selectedBrand = widget.selectedBrand;
    selectedSubType = widget.selectedSubType;
    selectedSource = widget.selectedSource;
    selectedEnquiryType = widget.selectedEnquiryType;
    selectedFuel = widget.selectedFuel;

    // Initialize controllers with passed values if they exist
    if (widget.mobile != null) {
      mobileController.text = widget.mobile!;
    }
    if (widget.pmi != null) {
      pmiController.text = widget.pmi!;
    }
  }

  // Controller for mobile number input
  TextEditingController mobileController = TextEditingController();
  TextEditingController pmiController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildTitle('Add New Leads')),
                  ),
                  // const SizedBox(height: 5),
                  _buildSectionTitle('Primary Model Intrest:'),
                  _buildTextField(
                    controller: pmiController,
                    hintText: 'PMI',
                    onChanged: (value) {
                      print("Mobile Number: $value");
                    },
                  ),
                  _buildSectionTitle('Fuel Space Type:'),
                  _buildDropdown(
                    label: 'Fuel',
                    value: selectedFuel,
                    items: ['Petrol', 'Diesel', 'BEV', 'PHEV', 'MHEV'],
                    onChanged: (value) {
                      setState(() {
                        selectedFuel = value;
                      });
                      print("Selected Source: $selectedFuel");
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Source:'),
                  _buildDropdown(
                    label: 'Email',
                    value: selectedSource,
                    items: ['Email', 'Field Visit', 'Referral'],
                    onChanged: (value) {
                      setState(() {
                        selectedSource = value;
                      });
                      print("Selected Source: $selectedSource");
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Mobile*'),
                  _buildTextField(
                    controller: mobileController,
                    hintText: '123',
                    onChanged: (value) {
                      print("Mobile Number: $value");
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Enquiry Type:'),
                  _buildDropdown(
                    label: 'Enquiry Type:',
                    value: selectedEnquiryType,
                    items: ['KMI', '(Generic) Purchase intent within 90 days'],
                    onChanged: (value) {
                      setState(() {
                        selectedEnquiryType = value;
                      });
                      print("Selected Enquiry Type: $selectedEnquiryType");
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Title widget
  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
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
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Reusable Dropdown widget
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final bool valueExists = value == null || items.contains(value);
    final currentValue = valueExists ? value : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.containerPopBg),
        child: DropdownButton<String>(
          value: currentValue,
          hint: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Reusable TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.containerPopBg,
        ),
        child: TextField(
          controller: controller, // Assign the controller
          style: AppFont.dropDowmLabel(context),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Expanded(
        //   child: Container(
        //     height: 45,
        //     decoration: BoxDecoration(
        //       color: Colors.black,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: TextButton(
        //       onPressed: () {
        //         Navigator.pop(context);
        //         Future.microtask(() {
        //           showDialog(
        //             context: context,
        //             builder: (context) => Dialog(
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(10),
        //               ),
        //               child: LeadsSecond(
        //                 firstName: widget.firstName,
        //                 lastName: widget.lastName,
        //                 email: widget.email,
        //                 selectedEvent: widget.selectedEvent,
        //                 selectedPurchaseType: selectedPurchaseType!,
        //                 selectedSubType: selectedSubType!,
        //                 selectedFuelType: selectedFuelType!,
        //                 selectedBrand: selectedBrand!,
        //                 selectedFuel: selectedFuel!,
        //                 // selectedEnquiryType: selectedEnquiryType!,
        //                 // selectedSource: selectedSource!,
        //                 // mobile: widget.mobile,
        //                 // pmi: widget.PMI,
        //               ),
        //             ),
        //           );
        //         });
        //       },
        //       child: Text('Previous',
        //           style: GoogleFonts.poppins(
        //               fontSize: 16,
        //               fontWeight: FontWeight.w600,
        //               color: Colors.white)),
        //     ),
        //   ),
        // ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: LeadsSecond(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      email: widget.email,
                      selectedEvent: widget.selectedEvent,
                      selectedPurchaseType: selectedPurchaseType!,
                      selectedSubType: selectedSubType!,
                      selectedFuelType: selectedFuelType!,
                      selectedBrand: selectedBrand!,
                      selectedFuel: selectedFuel!,
                      // selectedEnquiryType: selectedEnquiryType!,
                      // selectedSource: selectedSource!,
                      // mobile: widget.mobile,
                      // pmi: widget.PMI,
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
        // Expanded(
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.blue,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //     onPressed: () {
        //       if (selectedSource == null || selectedEnquiryType == null) {
        //         // Show error message
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(
        //             content: Text('Please fill in all required fields'),
        //           ),
        //         );
        //         return;
        //       }

        //       Navigator.pop(context);
        //       Future.microtask(() {
        //         showDialog(
        //           context: context,
        //           builder: (context) => Dialog(
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //             child: LeadsLast(
        //               firstName: widget.firstName,
        //               lastName: widget.lastName,
        //               email: widget.email,
        //               mobile: mobileController.text,
        //               selectedPurchaseType: selectedPurchaseType!,
        //               selectedEnquiryType: selectedEnquiryType!,
        //               PMI: pmiController.text,
        //               selectedSource: selectedSource!,
        //               selectedSubType: selectedSubType!,
        //               selectedFuelType: selectedFuelType!,
        //               selectedBrand: selectedBrand!,
        //               selectedFuel: selectedFuel!,
        //             ),
        //           ),
        //         );
        //       });
        //     },
        //     child: Text(
        //       'Next',
        //       style: GoogleFonts.poppins(
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),

        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: LeadsLast(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      email: widget.email,
                      mobile: mobileController.text,
                      selectedPurchaseType: selectedPurchaseType!,
                      selectedEnquiryType: selectedEnquiryType!,
                      PMI: pmiController.text,
                      selectedSource: selectedSource!,
                      selectedSubType: selectedSubType!,
                      selectedFuelType: selectedFuelType!,
                      selectedBrand: selectedBrand!,
                      selectedFuel: selectedFuel!,
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
    );
  }
}
