import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/font/font.dart'; 
import 'package:smart_assist/pages/navbar_page/favorites/favoritesbtns/f_appointment.dart';
import 'package:smart_assist/pages/navbar_page/favorites/favoritesbtns/f_leads.dart';
import 'package:smart_assist/pages/navbar_page/favorites/favoritesbtns/f_opportunity.dart';
import 'package:smart_assist/pages/navbar_page/favorites/favoritesbtns/f_testdrive.dart';
import 'package:smart_assist/pages/navbar_page/favorites/favoritesbtns/f_upcoming.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';

class FavoritePage extends StatefulWidget {
  final String leadId;
  const FavoritePage({super.key, required this.leadId});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int _selectedButtonIndex = 0;
  List<Map<String, dynamic>> followupData = [];
  List<Map<String, dynamic>> appointmentData = [];
  List<Map<String, dynamic>> testDriveData = [];
  List<Map<String, dynamic>> opportunityData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load initial data for followups
    // fetchFollowupData();
    FUpcoming(
      leadId: widget.leadId,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedButtonIndex) {
      case 0:
        return FUpcoming(
          leadId: widget.leadId,
        ); // Load follow-ups
      case 1:
        // return _buildDataList(appointmentData);
        return const FAppointment();
      case 2:
        // return _buildDataList(testDriveData);
        return const FTestdrive();
      case 3:
        // return _buildDataList(opportunityData);
        return FLeads();
      // case 4:
      //   return FOpportunity();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigation(),
              ),
            );
          },
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
        ),
        title: Text('Favourite', style: AppFont.appbarfontWhite(context)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Wrap(
                spacing: 1, // Space between buttons
                children: [
                  FlexibleButton(
                    title: 'Followups',
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 0;
                      });
                    },
                    decoration: BoxDecoration(
                      border: _selectedButtonIndex == 0
                          ? Border.all(color: Colors.blue)
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: _selectedButtonIndex == 0
                          ? Colors.blue
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FlexibleButton(
                    title: 'Appointments',
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 1;
                      });
                    },
                    decoration: BoxDecoration(
                      border: _selectedButtonIndex == 1
                          ? Border.all(color: Colors.blue)
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: _selectedButtonIndex == 1
                          ? Colors.blue
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FlexibleButton(
                    title: 'Test Drive',
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 2;
                      });
                    },
                    decoration: BoxDecoration(
                      border: _selectedButtonIndex == 2
                          ? Border.all(color: Colors.blue)
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: _selectedButtonIndex == 2
                          ? Colors.blue
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FlexibleButton(
                    title: 'Leads',
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 3;
                      });
                    },
                    decoration: BoxDecoration(
                      border: _selectedButtonIndex == 3
                          ? Border.all(color: Colors.blue)
                          : Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: _selectedButtonIndex == 3
                          ? Colors.blue
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 5),
            _buildContent(), // Load follow-ups or other data based on selection
          ],
        ),
      ),
    );
  }
}

class FlexibleButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final BoxDecoration decoration;
  final TextStyle textStyle;

  const FlexibleButton(
      {super.key,
      required this.title,
      required this.onPressed,
      required this.decoration,
      required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: decoration,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color(0xffF3F9FF),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
