import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';

class MyTeams extends StatefulWidget {
  const MyTeams({super.key});

  @override
  State<MyTeams> createState() => _MyTeamsState();
}

class _MyTeamsState extends State<MyTeams> {
  int _periodIndex = 0; // ALL, MTD, QTD, YTD
  int _tabIndex = 0; // 0 for Individual Performance, 1 for Team Comparison
  int _selectedButtonIndex = 0;
  int _selectedProfileIndex = -1; // Track selected profile

  // Sample profile data
  final List<Map<String, String>> teamProfiles = [
    {'name': 'Abhey', 'lastName': 'Dayal'},
    {'name': 'Amit', 'lastName': 'Arora'},
    {'name': 'Gia', 'lastName': 'Valecha'},
    {'name': 'Jigar', 'lastName': 'Shah'},
    {'name': 'Pritesh', 'lastName': 'Gamali'},
  ];

  // Sample individual performance data
  final Map<String, dynamic> individualData = {
    'enquiries': 8,
    'testDriveDone': 3,
    'orderTaken': 3,
    'cancellations': 2,
    'netOrder': -1,
    'retail': 0,
  };

  final Map<String, dynamic> teamData = {
    'totalTeamEnquiries': 340,
    'teamConversion': 75,
    'topPerformer': 'John Doe',
    'averageResponse': '2.5 hrs',
  };

  bool isLoading = false;

  Map<String, dynamic> getSelectedData() {
    // Return different data based on tab selection
    if (_tabIndex == 0) {
      // Individual performance data
      return individualData;
    } else {
      // Team comparison data
      return teamData;
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedButtonIndex) {
      case 0:
      // return FUpcoming(
      //   leadId: widget.leadId,
      // ); // Load follow-ups
      case 1:
      // return _buildDataList(appointmentData);
      // return const FAppointment();
      case 2:
      // return _buildDataList(testDriveData);
      // return const FTestdrive();
      case 3:
      // return _buildDataList(opportunityData);
      // return FLeads();
      // case 4:
      //   return FOpportunity();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text('My team', style: AppFont.appbarfontWhite(context)),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab selection buttons
              _buildTabButtons(),

              // Message below tabs
              _tabIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'Select a PS to view their statistics',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : SizedBox(), // If _tabIndex != 0, show nothing (empty SizedBox)

              // Profile avatars (only show for Individual Performance tab)
              if (_tabIndex == 0) _buildProfileAvatars(),

              // Period filter and date selection

              // Start of your widget
              Column(
                children: [
                  // Period Filter and Individual/Team view with condition
                  _tabIndex == 0
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLightGrey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                _buildPeriodFilter(
                                    screenWidth), // Content area - different for each tab
                                _buildIndividualPerformanceView(
                                    context, screenWidth),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            _buildPeriodFilter(screenWidth),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              child: Wrap(
                                spacing: 1, // Space between buttons
                                children: [
                                  FlexibleButton(
                                    title: 'Enquiries',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 0;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 0
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                                    title: 'Test Drives',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 1;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 1
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                                    title: 'Net Orders',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 2;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 2
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                                    title: 'New Orders',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 3;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 3
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                                  FlexibleButton(
                                    title: 'Cancellations',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 3;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 3
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                                  FlexibleButton(
                                    title: 'Retails',
                                    onPressed: () {
                                      setState(() {
                                        _selectedButtonIndex = 3;
                                      });
                                    },
                                    decoration: BoxDecoration(
                                      border: _selectedButtonIndex == 3
                                          ? Border.all(color: Colors.blue)
                                          : Border.all(
                                              color: Colors.transparent),
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
                            _buildTeamComparisonView(context, screenWidth),
                          ],
                        ), // No padding, no container for Team Comparison
                ],
              ),

              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Container(
              //       decoration: BoxDecoration(
              //           color: AppColors.backgroundLightGrey,
              //           borderRadius: BorderRadius.circular(5)),
              //       child: Column(
              //         children: [
              //           _buildPeriodFilter(
              //               screenWidth), // Content area - different for each tab
              //           _tabIndex == 0
              //               ? _buildIndividualPerformanceView(
              //                   context, screenWidth)
              //               : _buildTeamComparisonView(context, screenWidth),
              //         ],
              //       )),
              // ),

              // Add some bottom padding for better scrolling experience
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.backgroundLightGrey,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // Individual Performance Button
            Container(
              color: Colors.transparent,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _tabIndex = 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            _tabIndex == 0 ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Individual Performance',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _tabIndex == 0
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Team Comparison Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _tabIndex = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabIndex == 1 ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Team Comparison',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _tabIndex == 1 ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatars() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          teamProfiles.length,
          (index) => _buildProfileAvatar(
            teamProfiles[index]['name'] ?? '',
            teamProfiles[index]['lastName'] ?? '',
            index,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String firstName, String lastName, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedProfileIndex = index;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundLightGrey,
              border: _selectedProfileIndex == index
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.grey.shade400,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          firstName,
          style: AppFont.mediumText14(context),
        ),
        Text(
          lastName,
          style: AppFont.mediumText14(context),
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Period selector (ALL, MTD, QTD, YTD)
          Container(
            height: 26,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fontColor, width: .5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildPeriodButton('All', 0),
                _buildPeriodButton('MTD', 1),
                _buildPeriodButton('QTD', 2),
                _buildPeriodButton('YTD', 3),
              ],
            ),
          ),

          // Calendar button
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              // color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, size: 18),
              onPressed: () {
                // Handle calendar selection
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, int index) {
    bool isSelected = _periodIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _periodIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          // color: isSelected ? Colors.blue : Colors.grey.shade200,
          // border: Border.all(color:  isSelected Colors.blue : Colors.grey.shade200),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent, width: 2),

          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  // Individual Performance View
  Widget _buildIndividualPerformanceView(
      BuildContext context, double screenWidth) {
    final data = getSelectedData();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First row of cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "8",
                  "Enquiries",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "3",
                  "Test Drive\nDone",
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Second row of cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "3",
                  "Order Taken",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "2",
                  "Cancellations",
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Third row of cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "-1",
                  "Net Order",
                  Colors.red,
                  backgroundColor: const Color(0xFFFF3B30),
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  "0",
                  "Retail",
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Team Comparison View
  Widget _buildTeamComparisonView(BuildContext context, double screenWidth) {
    final data = getSelectedData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First row of cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "${data['totalTeamEnquiries'] ?? 0}",
                  "Team Total\nEnquiries",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${data['teamConversion'] ?? 0}%",
                  "Team Conversion\nRate",
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Second row of cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  data['topPerformer'] ?? 'N/A',
                  "Top\nPerformer",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  data['averageResponse'] ?? 'N/A',
                  "Avg. Response\nTime",
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String value,
    String label,
    Color valueColor, {
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: backgroundColor == Colors.white ? valueColor : textColor,
            ),
          ),
          const SizedBox(width: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              maxLines: 3,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
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

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';

// class MyTeams extends StatefulWidget {
//   const MyTeams({super.key});

//   @override
//   State<MyTeams> createState() => _MyTeamsState();
// }

// class _MyTeamsState extends State<MyTeams> {
//   int _childButtonIndex = 0;
//   int _activeButtonIndex = 0;
//   int _selectedProfileIndex = -1;
//   int _tabIndex = 0;

//   late Widget? currentWidget;

//   Map<String, dynamic> getSelectedData() {
//     switch (_childButtonIndex) {
//       case 0:
//       // return MtdData;
//       case 1:
//       // return QtdData;
//       case 2:
//       // return YtdData;
//       default:
//         return {};
//     }
//   }

//   //   // Sample profile data
//   final List<Map<String, String>> teamProfiles = [
//     {'name': 'Abhey', 'lastName': 'Dayal'},
//     {'name': 'Amit', 'lastName': 'Arora'},
//     {'name': 'Gia', 'lastName': 'Valecha'},
//     {'name': 'Jigar', 'lastName': 'Shah'},
//     {'name': 'Pritesh', 'lastName': 'Gamali'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(builder: (context) => BottomNavigation()),
//             // );

//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             FontAwesomeIcons.angleLeft,
//             color: Colors.white,
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xFF1380FE),
//         title: Text('My Team', style: AppFont.appbarfontWhite(context)),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * .95,
//                     height: 35,
//                     decoration: BoxDecoration(
//                       color: AppColors.containerBg,
//                       border: Border.all(
//                           color: const Color(0xFF767676).withOpacity(0.3),
//                           width: 0.5), // Border around the container
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       children: [
//                         // Upcoming Button
//                         Expanded(
//                           child: TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _childButtonIndex =
//                                       0; // Set Upcoming as active
//                                   // _childSelection[_activeButtonIndex] = 0;
//                                 });
//                               },
//                               style: TextButton.styleFrom(
//                                 alignment: Alignment.center,

//                                 backgroundColor: _childButtonIndex == 0
//                                     ? Colors.blue // Green for Upcoming
//                                     : Colors.transparent,
//                                 foregroundColor: _childButtonIndex == 0
//                                     ? Colors.white
//                                     : Colors.black,
//                                 // padding: const EdgeInsets.symmetric(vertical: 5),
//                                 padding: EdgeInsets.zero,

//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       30), // Optional: Rounded corners
//                                 ),
//                               ),
//                               child: Text(
//                                 'Individual Performance',
//                                 style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w400,
//                                     color: _childButtonIndex == 0
//                                         ? Colors.white
//                                         : const Color(0xff000000)
//                                             .withOpacity(0.56)),
//                               )),
//                         ),

//                         // Overdue Button
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () {
//                               setState(() {
//                                 _childButtonIndex =
//                                     1; // Mark this button as active
//                                 // _childSelection[_activeButtonIndex] = 1;
//                               });
//                             },
//                             style: TextButton.styleFrom(
//                               backgroundColor: _childButtonIndex == 1
//                                   ? Colors.blue // Red highlight when active
//                                   : Colors.transparent,
//                               foregroundColor: _childButtonIndex == 1
//                                   ? Colors.white
//                                   : Colors.black,
//                               padding: EdgeInsets.zero,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Team Comparision',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w400,
//                                     color: _childButtonIndex == 1
//                                         ? Colors.white
//                                         : const Color(0xff000000)
//                                             .withOpacity(0.56),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [Text('Select a PS to view their statistic')],
//             ),
//             if (_tabIndex == 0) _buildProfileAvatars(),
//             Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroundLightGrey,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Row with filter buttons and calendar
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 _buildButton('ALL', 0),
//                                 _buildButton('MTD', 1),
//                                 _buildButton('QTD', 2),
//                                 _buildButton('YTD', 3),
//                               ],
//                             ),
//                             const Image(
//                               image: AssetImage('assets/calendar.png'),
//                               height: 24,
//                               width: 24,
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // _buildFirstSlide should render below, not inside Row
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height *
//                               0.4, // 40% of screen height
//                           child: _buildFirstSlide(context, screenWidth),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFirstSlide(BuildContext context, double screenWidth) {
//     final selectedData = getSelectedData();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: _buildInfoCard1(
//                     context,
//                     'Enquiries you have',
//                     '${selectedData['totalEnquiries'] ?? 0}',
//                     screenWidth,
//                     Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   flex: 1,
//                   child: _buildInfoCard1(
//                     context,
//                     'Enquiries lost',
//                     '${selectedData['lostEnquiries'] ?? 0}',
//                     screenWidth,
//                     Colors.red,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: _buildInfoCard1(
//                     context,
//                     'Enquiries you have',
//                     '${selectedData['totalEnquiries'] ?? 0}',
//                     screenWidth,
//                     Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   flex: 1,
//                   child: _buildInfoCard1(
//                     context,
//                     'Enquiries lost',
//                     '${selectedData['lostEnquiries'] ?? 0}',
//                     screenWidth,
//                     Colors.red,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard1(BuildContext context, String title, String value,
//       double screenWidth, Color valueColor) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration:
//                   BoxDecoration(border: Border.all(color: Colors.transparent)),
//               child: Text(
//                 title,
//                 softWrap: true,
//                 // textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 4,
//                 style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.grey[700]),
//               ),
//             ),
//             // const SizedBox(height: 5),
//             Text(
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               maxLines: 4,
//               value,
//               style: GoogleFonts.poppins(
//                   fontSize: 24, fontWeight: FontWeight.w700, color: valueColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileAvatars() {
//     return Container(
//       height: 120,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(
//           teamProfiles.length,
//           (index) => _buildProfileAvatar(
//             teamProfiles[index]['name'] ?? '',
//             teamProfiles[index]['lastName'] ?? '',
//             index,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileAvatar(String firstName, String lastName, int index) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         InkWell(
//           onTap: () {
//             setState(() {
//               _selectedProfileIndex = index;
//             });
//           },
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey.shade300,
//               border: _selectedProfileIndex == index
//                   ? Border.all(color: Colors.blue, width: 2)
//                   : null,
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.person,
//                 color: Colors.grey.shade400,
//                 size: 32,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           firstName,
//           style: GoogleFonts.poppins(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           lastName,
//           style: GoogleFonts.poppins(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoCard2(BuildContext context, String title, String value,
//       double screenWidth, Color valueColor) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration:
//                   BoxDecoration(border: Border.all(color: Colors.transparent)),
//               child: Expanded(
//                 child: Text(
//                   title,
//                   softWrap: true,
//                   // textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 4,
//                   style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.grey[700]),
//                 ),
//               ),
//             ),
//             // const SizedBox(height: 5),
//             Text(
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               maxLines: 4,
//               value,
//               style: GoogleFonts.poppins(
//                   fontSize: 24, fontWeight: FontWeight.w700, color: valueColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Button Builder
//   Widget _buildButton(String text, int index) {
//     bool isSelected = _childButtonIndex == index;

//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.transparent,
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: TextButton(
//           onPressed: () {
//             setState(() {
//               _childButtonIndex = index;
//             });
//           },
//           style: TextButton.styleFrom(
//             foregroundColor: isSelected ? Colors.blue : Colors.black,
//             backgroundColor: Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 5),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: isSelected ? Colors.blue : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
