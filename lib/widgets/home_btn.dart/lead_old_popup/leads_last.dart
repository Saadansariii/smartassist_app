import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_id_screens/single_leads.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/widgets/home_btn.dart/lead_old_popup/leads_third.dart';

class LeadsLast extends StatefulWidget {
  final String selectedPurchaseType;
  final String selectedSubType;
  final String selectedFuelType;
  final String selectedBrand;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String selectedSource;
  final String PMI;
  final String selectedEnquiryType;
  final String selectedFuel;
  LeadsLast(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.mobile,
      required this.selectedPurchaseType,
      required this.selectedSubType,
      required this.selectedFuelType,
      required this.selectedBrand,
      required this.selectedSource,
      required this.PMI,
      required this.selectedEnquiryType,
      required this.selectedFuel});

  @override
  State<LeadsLast> createState() => _LeadsLastState();
}

class _LeadsLastState extends State<LeadsLast> {
  // String selectedSource = '';
  // String? selectedPurchaseType;
  // String? selectedFuelType;
  // String? selectedBrand;
  // String? selectedEvent;
  // String? selectedEnquiryType;
  // String? selectedCustomer;

  // String? selectedFuelType;
  // String? selectedPurchaseType;
  // String? selectedBrand;
  // String? selectedEvent;
  // String? selectedSource;
  // String? selectedEnquiryType;
  // String? selectedCustomer;

  String? selectedFuelType;
  String? selectedPurchaseType;
  String? selectedBrand;
  // String? selectedEvent;
  String? selectedSource;
  String? selectedEnquiryType;
  String? selectedCustomer;
  String? selectedSubType;
  String? selectedStatus;
  String? selectedFuel;

  void initState() {
    // TODO: implement initState
    super.initState();
    selectedFuelType = widget.selectedFuelType!;
    selectedPurchaseType = widget.selectedPurchaseType!;
    selectedSubType = widget.selectedSubType!;
    selectedEnquiryType = widget.selectedEnquiryType!;
    selectedSource = widget.selectedSource!;
    selectedFuel = widget.selectedFuel!;
    selectedFuel = widget.selectedFuel!;
    // selectedEvent = widget.selectedEvent!;
    selectedBrand = widget.selectedBrand!;
    print(selectedFuelType);
  }

  // Controllers for capturing input
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool get isLoading => false;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: Text('Add New Leads',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                        ),
                        // const SizedBox(height: 5),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10),
                            child: Text(
                              textAlign: TextAlign.start,
                              'Status',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.containerPopBg,
                            ),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : DropdownButton<String>(
                                    value: selectedStatus,
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text("Select",
                                          style: AppFont.dropDown(context)),
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: "New",
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text("New",
                                              style: AppFont.dropDowmLabel(
                                                  context)),
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: "Follow Up",
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text("Followup",
                                              style: AppFont.dropDowmLabel(
                                                  context)),
                                        ),
                                      ),
                                      // DropdownMenuItem<String>(
                                      //   value: "Qualified",
                                      //   child: Padding(
                                      //     padding: EdgeInsets.only(left: 10.0),
                                      //     child: Text(
                                      //       "Qualified",
                                      //       style: TextStyle(
                                      //           fontSize: 14,
                                      //           fontWeight: FontWeight.w500),
                                      //     ),
                                      //   ),
                                      // ),
                                      DropdownMenuItem<String>(
                                        value: "Lost",
                                        child: Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text("Lost",
                                                style:
                                                    AppFont.dropDowmLabel(
                                                    context))),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStatus =
                                            value!; // Corrected assignment
                                      });

                                      print(
                                          "Selected Status: $selectedStatus"); // Debugging
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Text(
                            'Description :',
                            style: AppFont.dropDowmLabel(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            width: double.infinity, // Full width
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.containerPopBg,
                            ),
                            child: TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  hintText: "Description",
                                  hintStyle: AppFont.dropDown(context),
                                  contentPadding:
                                      const EdgeInsets.only(left: 10),
                                  border: InputBorder.none,
                                ),
                                style: AppFont.dropDown(context)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Text(
                            'Lead code :',
                            style: AppFont.dropDowmLabel(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            width: double.infinity, // Full width
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.containerPopBg,
                            ),
                            child: TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                hintText: "Lead Code",
                                hintStyle: AppFont.dropDown(context),
                                contentPadding: const EdgeInsets.only(left: 10),
                                border: InputBorder.none,
                              ),
                              style: AppFont.dropDowmLabel(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Text('Expected Date Purchased:',
                              style: AppFont.dropDowmLabel(context)),
                        ),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.containerPopBg,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateController.text.isEmpty
                                        ? "Select Date"
                                        : dateController.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: dateController.text.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
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
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //               ),
                            //               child: LeadsThird(
                            //                 firstName: widget.firstName,
                            //                 lastName: widget.lastName,
                            //                 email: widget.email,
                            //                 selectedPurchaseType:
                            //                     selectedPurchaseType!,
                            //                 selectedSubType: selectedSubType!,
                            //                 selectedFuelType: selectedFuelType!,
                            //                 selectedBrand: selectedBrand!,
                            //                 selectedEnquiryType:
                            //                     selectedEnquiryType!,
                            //                 selectedSource: selectedSource!,
                            //                 mobile: widget.mobile,
                            //                 pmi: widget.PMI,
                            //                 selectedEvent: '',
                            //                 selectedFuel: selectedFuel!,
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: LeadsThird(
                                          firstName: widget.firstName,
                                          lastName: widget.lastName,
                                          email: widget.email,
                                          selectedPurchaseType:
                                              selectedPurchaseType!,
                                          selectedSubType: selectedSubType!,
                                          selectedFuelType: selectedFuelType!,
                                          selectedBrand: selectedBrand!,
                                          selectedEnquiryType:
                                              selectedEnquiryType!,
                                          selectedSource: selectedSource!,
                                          mobile: widget.mobile,
                                          pmi: widget.PMI,
                                          selectedEvent: '',
                                          selectedFuel: selectedFuel!,
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
                                  child: Text('Submit',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitForm() async {
    String description = descriptionController.text;
    String phone = phoneController.text;
    String date = dateController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spId = prefs.getString('user_id');

    if (spId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found. Please log in again.')),
        );
      }
      return;
    }

    final leadData = {
      'fname': widget.firstName,
      'lname': widget.lastName,
      'email': widget.email,
      'lead_code': phone,
      'mobile': widget.mobile,
      'purchase_type': selectedPurchaseType,
      'brand': selectedBrand,
      'type': selectedFuelType,
      'sub_type': selectedSubType,
      'sp_id': spId,
      'status': selectedStatus,
      'lead_source': selectedSource,
      'PMI': widget.PMI,
      'expected_date_purchase': date,
      'fuel_type': selectedFuel,
      'enquiry_type': selectedEnquiryType,
    };

    Map<String, dynamic>? response = await LeadsSrv.submitLead(leadData);

    if (response != null) {
      if (response.containsKey('newLead')) {
        String leadId = response['newLead']['lead_id'];
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleLeadsById(leadId: leadId),
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form Submit Successful.')),
        );
      } else if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['error']), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit lead. Please try again.')),
      );
    }
  }
}
