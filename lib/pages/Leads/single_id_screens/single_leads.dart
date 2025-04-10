import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';

class SingleLeadsById extends StatefulWidget {
  final String leadId;
  const SingleLeadsById({super.key, required this.leadId});

  @override
  State<SingleLeadsById> createState() => _SingleLeadsByIdState();
}

class _SingleLeadsByIdState extends State<SingleLeadsById> {
  String phoneNumber = '';
  String subtype = '';
  String email = '';
  String brand = '';
  String dealerName = '';
  String pmi = '';
  String status = '';
  String leadSource = '';
  String purchaseType = '';
  String leadOwner = '';
  String flag = '';
  String enquiryType = '';
  String leadName = '';

  @override
  void initState() {
    super.initState();
    fetchLeadData(widget.leadId);
    // print('this is lead id $widget.leadId');
    // print(widget.leadId);
  }

  Future<void> fetchLeadData(String leadId) async {
    try {
      final leadData = await LeadsSrv.fetchLeadsById(leadId);
      setState(() {
        phoneNumber = leadData['mobile'] ?? 'N/A';
        subtype = leadData['sub_type'] ?? 'N/A';
        email = leadData['email'] ?? 'N/A';
        brand = leadData['brand'] ?? 'N/A';
        dealerName = leadData['dealer_name'] ?? 'N/A';
        pmi = leadData['PMI'] ?? 'N/A';
        status = leadData['status'] ?? 'N/A';
        leadSource = leadData['lead_source'] ?? 'N/A';
        purchaseType = leadData['purchase_type'] ?? 'N/A';
        leadOwner = leadData['lead_owner'] ?? 'N/A';
        flag = leadData['flag'] ?? 'N/A';
        enquiryType = leadData['enquiry_type'] ?? 'N/A';
        leadName = leadData['lead_name'] ?? 'N/A';
      });
      // ignore: avoid_print
      print("Leads data: $leadData");
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            leadName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.colorsBlue,
            ),
          ),
          const SizedBox(
            height: 15, // Set the height of the divider
            child: VerticalDivider(
              thickness: 1, // Set thickness for visibility
              color: Colors.grey, // Divider color
            ),
          ),
          // const SizedBox(width: 2), // Space after the divider
          Text(pmi,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.iconGrey,
              )),
        ],
      ),
    );
  }

 

  Widget _buildActionButton(
      String text, Color color, VoidCallback onPressed, IconData icon) {
    return Flexible(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead', style: AppFont.appbarfontgrey(context)),
        foregroundColor: AppColors.iconGrey,
        leading: IconButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => BottomNavigation())),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _buildHeader(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const SizedBox(width: 5),
                        _buildInfoBox('Mobile', phoneNumber),
                        // const SizedBox(width: 5),
                        _buildInfoBox('Email', email),
                        // const SizedBox(width: 5),
                      ],
                    ),
                    const SizedBox(
                      width: double.infinity, // Set the height of the divider
                      child: Divider(
                        thickness: 1, // Set thickness for visibility
                        color:
                            Color.fromARGB(255, 221, 219, 219), // Divider color
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(width: 5),
                    _buildInfoBox('Sub Type', subtype),
                    // const SizedBox(width: 5),
                    _buildInfoBox('Brand', brand),
                    // const SizedBox(width: 5),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const SizedBox(width: 5),
                        _buildInfoBox('Status', status),
                        // const SizedBox(width: 5),
                        _buildInfoBox('Lead Source', leadSource),
                        // const SizedBox(width: 5),
                      ],
                    ),
                    const SizedBox(
                      width: double.infinity, // Set the height of the divider
                      child: Divider(
                        thickness: 1, // Set thickness for visibility
                        color:
                            Color.fromARGB(255, 221, 219, 219), // Divider color
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(width: 5),
                    _buildInfoBox('Purchase Type', purchaseType),
                    // const SizedBox(width: 5),
                    _buildInfoBox('Enquiry Type', enquiryType),
                    // const SizedBox(width: 5),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Followup ?', AppColors.colorsBlue, () {},
                      Icons.phone_in_talk_outlined),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildActionButton('Plan a drive', AppColors.fontBlack, () {},
                      Icons.car_crash),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                      'Schedule appointment',
                      AppColors.fontBlack,
                      () {},
                      Icons.calendar_month_outlined),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
