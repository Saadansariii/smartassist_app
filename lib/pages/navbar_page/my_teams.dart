import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/storage.dart';

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
  String _selectedUserId = '';
  late Future<Map<String, dynamic>> _data;
  final FabController fabController = Get.put(FabController());
  Map<String, dynamic> _individualPerformanceData = {};

  // Sample profile data
  // final List<Map<String, String>> teamProfiles = [
  //   {'name': 'Abhey', 'lastName': 'Dayal'},
  //   {'name': 'Amit', 'lastName': 'Arora'},
  //   {'name': 'Gia', 'lastName': 'Valecha'},
  //   {'name': 'Jigar', 'lastName': 'Shah'},
  //   {'name': 'Pritesh', 'lastName': 'Gamali'},
  // ];

  // This will fetch the data based on the selected button
  // Future<Map<String, dynamic>> _fetchData(String category) async {
  //   // Replace this with your API logic
  //   // Simulating an API call based on category
  //   await Future.delayed(Duration(seconds: 1));
  //   // Example mock data based on category
  //   switch (category) {
  //     case 'Enquiries':
  //       return {
  //         'Abhey Dayal': 6,
  //         'Amit Arora': 5,
  //         'Gia Valecha': 2,
  //         'Jigar Shah': 7,
  //         'Pritesh Gamali': 1
  //       };
  //     case 'Test Drives':
  //       return {
  //         'Abhey Dayal': 4,
  //         'Amit Arora': 5,
  //         'Gia Valecha': 3,
  //         'Jigar Shah': 8,
  //         'Pritesh Gamali': 2
  //       };
  //     case 'Net Orders':
  //       return {
  //         'Abhey Dayal': 3,
  //         'Amit Arora': 4,
  //         'Gia Valecha': 2,
  //         'Jigar Shah': 7,
  //         'Pritesh Gamali': 1
  //       };
  //     // Add more categories as needed
  //     default:
  //       return {
  //         'Abhey Dayal': 0,
  //         'Amit Arora': 0,
  //         'Gia Valecha': 0,
  //         'Jigar Shah': 0,
  //         'Pritesh Gamali': 0
  //       };
  //   }
  // }

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

  List<Color> _getGradientForProgress(double percentage) {
    if (percentage >= 0.8) {
      return [
        Color.fromRGBO(255, 237, 215, 0.9),
        Color.fromRGBO(83, 157, 243, 1),
        Color.fromRGBO(144, 109, 250, 1),
      ];
    } else if (percentage >= 0.6) {
      return [
        Color.fromRGBO(229, 208, 210, 1),
        Color.fromRGBO(255, 150, 165, 1),
        Color.fromRGBO(255, 122, 113, 1),
      ];
    } else if (percentage >= 0.3) {
      return [
        Color.fromRGBO(254, 221, 176, 1),
        Color.fromRGBO(144, 109, 250, 1),
        Color.fromRGBO(255, 122, 113, 1),
      ];
    } else {
      return [
        Color.fromRGBO(182, 247, 249, 1),
        Color.fromRGBO(168, 230, 251, 1),
        Color.fromRGBO(196, 201, 255, 1),
      ];
    }
  }

  String _getMetricKey() {
    switch (_selectedButtonIndex) {
      case 1:
        return 'testDrives';
      case 2:
        return 'orders';
      case 3:
        return 'newOrders'; // Update if your backend uses 'orders' or 'newOrders'
      case 4:
        return 'cancellation';
      case 5:
        return 'retails'; // if applicable
      default:
        return 'enquiries';
    }
  }

  String _getPeriodKey() {
    switch (_periodIndex) {
      case 1:
        return 'MTD';
      case 2:
        return 'QTD';
      case 3:
        return 'YTD';
      default:
        return 'ALL'; // if backend returns separate ALL block, else skip
    }
  }

  late Future<List<Map<String, dynamic>>> _teamComparisonData;

  int _selectedPeriodIndex = 0; // 0: All, 1: MTD, 2: QTD, 3: YTD
  int _selectedMetricIndex = 0;

  Future<List<Map<String, dynamic>>> fetchTeamComparisonData() async {
    final token = await Storage.getToken();
    final response = await http.get(
        Uri.parse(
            'https://api.smartassistapp.in/api/users/sm/dashboard/team-comparison'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> teams = decoded['data']['teamsData'];

      List<Map<String, dynamic>> result = [];

      for (var team in teams) {
        // Case 1: Count at team level
        if (team.containsKey('team_name') &&
            team.containsKey(_getPeriodKey())) {
          final name = team['team_name'];
          final periodData = team[_getPeriodKey()];
          final count = periodData[_getMetricKey()] ?? 0;

          result.add({"name": name, "count": count});
        }

        // Case 2: Count at user level inside team
        if (team.containsKey('users')) {
          for (var user in team['users']) {
            final name = user['name'];
            Map<String, dynamic> periodData;

            switch (_periodIndex) {
              case 1:
                periodData = user['MTD'];
                break;
              case 2:
                periodData = user['QTD'];
                break;
              case 3:
                periodData = user['YTD'];
                break;
              default:
                periodData = {
                  "enquiries": (user['MTD']?['enquiries'] ?? 0) +
                      (user['QTD']?['enquiries'] ?? 0) +
                      (user['YTD']?['enquiries'] ?? 0),
                  "testDrives": (user['MTD']?['testDrives'] ?? 0) +
                      (user['QTD']?['testDrives'] ?? 0) +
                      (user['YTD']?['testDrives'] ?? 0),
                  "orders": (user['MTD']?['orders'] ?? 0) +
                      (user['QTD']?['orders'] ?? 0) +
                      (user['YTD']?['orders'] ?? 0),
                  "cancellation": (user['MTD']?['cancellation'] ?? 0) +
                      (user['QTD']?['cancellation'] ?? 0) +
                      (user['YTD']?['cancellation'] ?? 0),
                };
            }

            result.add({
              "name": name,
              "count": periodData[_getMetricKey()] ?? 0,
            });
          }
        }
      }

      return result;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<Map<String, dynamic>> _fetchDataUserProfile() async {
    try {
      // Simulate an API call for Individual Performance or Team Data
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse(
            'https://api.smartassistapp.in/api/users/sm/dashboard/individual-performance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Parse the API response to update the teamProfiles data
        List<Map<String, String>> teamProfiles = [];
        for (var team in data['data']) {
          for (var member in team['teamMembers']) {
            teamProfiles.add({
              'name': member['fname'],
              'lname': member['lname'],
              'user_id': member['user_id'],
            });
          }
        }

        return {
          'status': 200,
          'teamProfiles': teamProfiles,
        };
      } else {
        return {
          'status': response.statusCode,
          'message': 'Failed to load data'
        };
      }
    } catch (e) {
      // Catch any errors during the API call or parsing
      print('Error occurred: $e');
      return {
        'status': 500,
        'message': 'An error occurred while fetching data'
      };
    }
  }

  Future<void> _fetchIndividualPerformance(String userId) async {
    try {
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse(
            'https://api.smartassistapp.in/api/users/sm/dashboard/individual-performance?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Update the individual performance data with the response
        setState(() {
          // Store the full user performance data, including the orders count
          _individualPerformanceData = data['data']['selectedUserPerformance'];
        });
      } else {
        throw Exception('Failed to load individual performance data');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request or data processing
      print('Error occurred: $e');
      // Optionally, update the UI or show a message to the user
    }
  }

// Individual Performance View
  Widget _buildIndividualPerformanceView(
      BuildContext context, double screenWidth) {
    // Get the updated performance data
    final data = _individualPerformanceData;

    // Ensure that the data is available before attempting to display it
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Center(child: Text('No performance data available.')),
      );
    }

    // Access orders.count from MTD, QTD, and YTD
    final mtdOrdersCount = data['MTD']['orders'] ?? 0;
    final qtdOrdersCount = data['QTD']['orders'] ?? 0;
    final ytdOrdersCount = data['YTD']['orders'] ?? 0;

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
                  "${data['MTD']['enquiries']}",
                  "Enquiries",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${data['MTD']['testDrives']}",
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
                  "$mtdOrdersCount", // Display orders.count for MTD
                  "Order Taken",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${data['MTD']['cancellation']}",
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
                  "0", // Display orders.count for QTD
                  "Net Orders ",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  "3", // Display orders.count for YTD
                  "Retails",
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(
      String firstName, String lastName, int index, String userId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedProfileIndex = index;
              _selectedUserId = userId; // Store the selected user_id
              _fetchIndividualPerformance(
                  userId); // Call the API with the new user_id
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
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

  @override
  void initState() {
    super.initState();
    // _data = _fetchData('Test Drives');
    // Make sure you assign the result to the _fetchDataUserProfile() method too.
    // You might want to await the result of _fetchDataUserProfile() before setting up the team profiles.
    _fetchDataUserProfile().then((data) {
      setState(() {
        // You can update the team profiles or other data here based on the fetched response
      });
    }).catchError((e) {
      // Handle any error here
      print('Error: $e');
    });
    _teamComparisonData = fetchTeamComparisonData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => BottomNavigation()));
        //   },
        //   icon: const Icon(
        //     FontAwesomeIcons.angleLeft,
        //     color: Colors.white,
        //   ),
        // ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text('My team', style: AppFont.appbarfontWhite(context)),
      ),
      body: Stack(children: [
        Scaffold(
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
                                _comparisionButtons(screenWidth),
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
                                            _selectedButtonIndex =
                                                0; // for Test Drives etc.

                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 0
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
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
                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 1
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
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
                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 2
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
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
                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                            ;
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 3
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
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
                                            _selectedButtonIndex = 4;
                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 4
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          color: _selectedButtonIndex == 4
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
                                            _selectedButtonIndex = 5;
                                            _teamComparisonData =
                                                fetchTeamComparisonData();
                                          });
                                        },
                                        decoration: BoxDecoration(
                                          border: _selectedButtonIndex == 5
                                              ? Border.all(color: Colors.blue)
                                              : Border.all(
                                                  color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          color: _selectedButtonIndex == 5
                                              ? Colors.blue
                                              : Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Data and Progress Indicator
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _teamComparisonData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      final data = snapshot.data!;
                                      return Column(
                                        children: data.map((userData) {
                                          final percentage =
                                              (userData['count'] as int) / 10.0;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child:
                                                        Text(userData['name'])),
                                                Expanded(
                                                  flex: 2,
                                                  child: LinearPercentIndicator(
                                                    percent: percentage.clamp(
                                                        0.0, 1.0),
                                                    lineHeight: 14.0,
                                                    barRadius:
                                                        const Radius.circular(
                                                            10),
                                                    backgroundColor:
                                                        Colors.grey[300]!,
                                                    linearGradient:
                                                        LinearGradient(
                                                      colors:
                                                          _getGradientForProgress(
                                                              percentage),
                                                    ),
                                                  ),
                                                ),
                                                Text('${userData['count']}'),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    } else {
                                      return const Text('No Data Available');
                                    }
                                  },
                                ),

                                // FutureBuilder<Map<String, dynamic>>(
                                //   future: _data,
                                //   builder: (context, snapshot) {
                                //     if (snapshot.connectionState ==
                                //         ConnectionState.waiting) {
                                //       return Center(
                                //           child: CircularProgressIndicator());
                                //     } else if (snapshot.hasError) {
                                //       return Center(
                                //           child: Text('Error loading data'));
                                //     } else if (snapshot.hasData) {
                                //       var data = snapshot.data!;
                                //       return Padding(
                                //         padding: const EdgeInsets.all(10.0),
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //               borderRadius:
                                //                   BorderRadius.circular(10),
                                //               color: AppColors
                                //                   .backgroundLightGrey),
                                //           child: Column(
                                //             children: data.entries.map((entry) {
                                //               double percentage = entry.value /
                                //                   10.0; // Adjust as needed
                                //               return Padding(
                                //                 padding:
                                //                     const EdgeInsets.symmetric(
                                //                         vertical: 8.0),
                                //                 child: Padding(
                                //                   padding: const EdgeInsets
                                //                       .symmetric(
                                //                       horizontal: 10.0,
                                //                       vertical: 15),
                                //                   child: Row(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment
                                //                             .center,
                                //                     children: [
                                //                       // Name Text
                                //                       Expanded(
                                //                         child: Text(entry.key,
                                //                             style: AppFont
                                //                                 .smallText(
                                //                                     context)),
                                //                       ),
                                //                       // Progress Bar
                                //                       Expanded(
                                //                         flex: 2,
                                //                         child: Padding(
                                //                           padding:
                                //                               const EdgeInsets
                                //                                   .only(
                                //                                   left: 10),
                                //                           child:
                                //                               LinearPercentIndicator(
                                //                             lineHeight: 14.0,
                                //                             percent: percentage,
                                //                             backgroundColor:
                                //                                 Colors
                                //                                     .grey[300]!,
                                //                             barRadius:
                                //                                 const Radius
                                //                                     .circular(
                                //                                     8),
                                //                             linearGradient:
                                //                                 LinearGradient(
                                //                               colors:
                                //                                   _getGradientForProgress(
                                //                                       percentage),
                                //                               begin: Alignment
                                //                                   .centerLeft,
                                //                               end: Alignment
                                //                                   .centerRight,
                                //                             ),
                                //                           ),
                                //                         ),
                                //                       ),
                                //                       // Percentage Text
                                //                       Padding(
                                //                         padding:
                                //                             const EdgeInsets
                                //                                 .only(left: 0),
                                //                         child: Text(
                                //                           '${(percentage * 100).toStringAsFixed(0)}%',
                                //                           style:
                                //                               AppFont.smallText(
                                //                                   context),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               );
                                //             }).toList(),
                                //           ),
                                //         ),
                                //       );
                                //     } else {
                                //       return const Center(child: Text(''));
                                //     }
                                //   },
                                // ),

                                FutureBuilder<Map<String, dynamic>>(
                                  future: _data,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child: Text('Error loading data'));
                                    } else if (snapshot.hasData) {
                                      var data = snapshot.data!;

                                      if (data.containsKey('teamProfiles')) {
                                        // Use the teamProfiles fetched from the API
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              data['teamProfiles'].length,
                                              (index) => _buildProfileAvatar(
                                                data['teamProfiles'][index]
                                                    ['name'],
                                                data['teamProfiles'][index]
                                                    ['lastName'],
                                                index,
                                                data['teamProfiles'][index]
                                                    ['user_id'],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Center(child: Text(''));
                                      }
                                    } else {
                                      return Center(
                                          child: Text('No data available'));
                                    }
                                  },
                                ),
                              ],
                            ), // No padding, no container for Team Comparison
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: _buildFloatingActionButton(context),
        ),

        // Popup Menu (Conditionally Rendered)
        Obx(() => fabController.isFabExpanded.value
            ? _buildPopupMenu(context)
            : SizedBox.shrink()),
      ]),
    );
  }

  // FAB Builder
  Widget _buildFloatingActionButton(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: fabController.toggleFab,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * .15,
          height: MediaQuery.of(context).size.height * .08,
          decoration: BoxDecoration(
            color: fabController.isFabExpanded.value
                ? Colors.red
                : AppColors.colorsBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedRotation(
              turns: fabController.isFabExpanded.value ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                fabController.isFabExpanded.value ? Icons.close : Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Popup Menu Builder
  Widget _buildPopupMenu(BuildContext context) {
    return GestureDetector(
      onTap: fabController.closeFab,
      child: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Popup Items Container aligned bottom right
          Positioned(
            bottom: 90,
            right: 20,
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPopupItem(Icons.people, "Create New Team", -40,
                      onTap: () {
                    fabController.closeFab();
                    // _showFollowupPopup(context, widget.leadId);
                  }),
                  _buildPopupItem(Icons.person, "Create User", -80, onTap: () {
                    fabController.closeFab();
                    // _showAppointmentPopup(context, widget.leadId);
                  }),
                ],
              ),
            ),
          ),

          // ✅ FAB positioned above the overlay
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildFloatingActionButton(context),
          ),
        ],
      ),
    );
  }

  // Popup Item Builder
  Widget _buildPopupItem(IconData icon, String label, double offsetY,
      {required Function() onTap}) {
    return Obx(() => TweenAnimationBuilder(
          tween: Tween<double>(
              begin: 0, end: fabController.isFabExpanded.value ? 1 : 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, offsetY * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.colorsBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
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
            Expanded(
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
                      color: _tabIndex == 0 ? Colors.blue : Colors.transparent,
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
                            color:
                                _tabIndex == 0 ? Colors.white : Colors.black54,
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDataUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading...'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var data = snapshot.data;
          if (data != null && data.containsKey('teamProfiles')) {
            List teamProfiles = data['teamProfiles'];
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
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
                      data['teamProfiles'][index]['user_id'],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No team profiles available.'));
          }
        } else {
          return const Center(child: Text('No data available'));
        }
      },
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
                // _buildPeriodButton('All', 0),
                _buildPeriodButton('MTD', 0),
                _buildPeriodButton('QTD', 1),
                _buildPeriodButton('YTD', 2),
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

  Widget _comparisionButtons(double screenWidth) {
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
                _combuildPeriodButton('All', 0),
                _combuildPeriodButton('MTD', 1),
                _combuildPeriodButton('QTD', 2),
                _combuildPeriodButton('YTD', 3),
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

  Widget _combuildPeriodButton(String text, int index) {
    bool isSelected = _periodIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _periodIndex = index;

          _teamComparisonData = fetchTeamComparisonData();
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

  // Team Comparison View
  Widget _buildTeamComparisonView(BuildContext context, double screenWidth) {
    final data = getSelectedData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First row of cards
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildMetricCard(
          //         "${data['totalTeamEnquiries'] ?? 0}",
          //         "Team Total\nEnquiries",
          //         Colors.blue,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildMetricCard(
          //         "${data['teamConversion'] ?? 0}%",
          //         "Team Conversion\nRate",
          //         Colors.blue,
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 12),

          // // Second row of cards
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildMetricCard(
          //         data['topPerformer'] ?? 'N/A',
          //         "Top\nPerformer",
          //         Colors.blue,
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Expanded(
          //       child: _buildMetricCard(
          //         data['averageResponse'] ?? 'N/A',
          //         "Avg. Response\nTime",
          //         Colors.blue,
          //       ),
          //     ),
          //   ],
          // ),
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
