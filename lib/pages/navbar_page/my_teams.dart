import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
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
  int _metricIndex = 0;
  late Future<Map<String, dynamic>> _data;
  late Future<Map<String, dynamic>> _teamComparisonData;

  // Class level variables to store upcoming activities
  List<Map<String, dynamic>> _upcomingFollowups = [];
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _upcomingTestDrives = [];

  final FabController fabController = Get.put(FabController());
  Map<String, dynamic> _individualPerformanceData = {};

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

  // List<Color> _getGradientForProgress(double percentage) {
  //   if (percentage >= 0.8) {
  //     return [
  //       Color.fromRGBO(255, 237, 215, 0.9),
  //       Color.fromRGBO(83, 157, 243, 1),
  //       Color.fromRGBO(144, 109, 250, 1),
  //     ];
  //   } else if (percentage >= 0.6) {
  //     return [
  //       Color.fromRGBO(229, 208, 210, 1),
  //       Color.fromRGBO(255, 150, 165, 1),
  //       Color.fromRGBO(255, 122, 113, 1),
  //     ];
  //   } else if (percentage >= 0.3) {
  //     return [
  //       Color.fromRGBO(254, 221, 176, 1),
  //       Color.fromRGBO(144, 109, 250, 1),
  //       Color.fromRGBO(255, 122, 113, 1),
  //     ];
  //   } else {
  //     return [
  //       Color.fromRGBO(182, 247, 249, 1),
  //       Color.fromRGBO(168, 230, 251, 1),
  //       Color.fromRGBO(196, 201, 255, 1),
  //     ];
  //   }
  // }

  // Calculate team total by summing member metrics
  int _calculateTeamTotal(Map<String, dynamic> team) {
    int total = 0;
    if (team.containsKey('member') && team['member'].isNotEmpty) {
      for (var member in team['member']) {
        total += _getMetricValueForUser(member);
      }
    }
    return total;
  }

  int _getMetricValueForUser(Map<String, dynamic> user) {
    if (user.containsKey('stats')) {
      final stats = user['stats'];
      switch (_metricIndex) {
        case 0:
          return stats['enquiries'] ?? 0;
        case 1:
          return stats['testDrives'] ?? 0;
        case 2:
          return stats['orders'] ?? 0; // Net Orders
        case 3:
          return stats['orders'] ?? 0; // New Orders (using same field)
        case 4:
          return stats['cancellation'] ?? 0;
        case 5:
          return stats['retail'] ?? 0; // Retail/Sales
        default:
          return stats['enquiries'] ?? 0;
      }
    }
    return 0;
  }

  // Widget for period selection buttons
  Widget _buildPeriodButtons(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
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
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
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

  // Individual period button
  Widget _buildPeriodButton(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _periodIndex = index;
          _teamComparisonData = fetchTeamComparisonData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          // color: _periodIndex == index ? Colors.blue : Colors.transparent,
          border: Border.all(
              color: _periodIndex == index ? Colors.blue : Colors.transparent),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _periodIndex == index ? Colors.blue : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Widget for metric selection buttons
  Widget _buildMetricButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          _buildMetricButton('Enquiries', 0),
          _buildMetricButton('Test Drives', 1),
          _buildMetricButton('Net Orders', 2),
          _buildMetricButton('New Orders', 3),
          _buildMetricButton('Cancellations', 4),
          _buildMetricButton('Retail', 5),
        ],
      ),
    );
  }

  // Individual metric button
  Widget _buildMetricButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _metricIndex = index;
            _teamComparisonData = fetchTeamComparisonData();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: _metricIndex == index ? Colors.blue : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _metricIndex == index ? Colors.blue : Colors.black87,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Get gradient colors for progress bars based on index
  List<Color> _getGradientForIndex(int index) {
    // Creating different color schemes for different rows
    final gradients = [
      [const Color(0xFF4CAF50), const Color(0xFF8BC34A)], // Green
      [const Color(0xFF2196F3), const Color(0xFF03A9F4)], // Blue
      [const Color(0xFFFFEB3B), const Color(0xFFFFC107)], // Yellow
      [const Color(0xFFFF9800), const Color(0xFFFF5722)], // Orange
      [const Color(0xFFE91E63), const Color(0xFFF44336)], // Red
    ];

    return gradients[index % gradients.length];
  }

// Update this method to handle different period filters in API request
  Future<Map<String, dynamic>> fetchTeamComparisonData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await Storage.getToken();

      // Determine period parameter based on selection
      String periodParam = '';
      switch (_periodIndex) {
        case 1:
          periodParam = '?type=MTD';
          break;
        case 2:
          periodParam = '?type=QTD';
          break;
        case 3:
          periodParam = '?type=YTD';
          break;
        default:
          periodParam = '';
      }

      Uri url = Uri.parse(
          'https://api.smartassistapp.in/api/users/sm/dashboard/team-comparison$periodParam');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      print('Request URL: ${url.toString()}');
      print(url.toString());
      if (response.statusCode == 200) {
        print(url.toString());
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching team comparison data: $e');
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
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

  // late Future<List<Map<String, dynamic>>> _teamComparisonData;

  int _selectedPeriodIndex = 0; // 0: All, 1: MTD, 2: QTD, 3: YTD
  int _selectedMetricIndex = 0;

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
              'name': member['name'],
              'name': member['fname'],
              'lname': member['lname'],
              'user_id': member['user_id'],
              'team_name': team['team_name'],
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
      // print('Error occurred: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

          // Also extract upcoming activities for use in UI
          _upcomingFollowups = List<Map<String, dynamic>>.from(
              _individualPerformanceData['stats']['UpComingFollowups'] ?? []);
          _upcomingAppointments = List<Map<String, dynamic>>.from(
              _individualPerformanceData['stats']['UpComingAppointment'] ?? []);
          _upcomingTestDrives = List<Map<String, dynamic>>.from(
              _individualPerformanceData['stats']['UpComingTestDrive'] ?? []);
        });
      } else {
        throw Exception('Failed to load individual performance data');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

    // Access the stats data
    final stats = data['stats'];

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
                  "${stats['Enquiries']}",
                  "Enquiries",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${stats['TestDrives']}",
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
                  "${stats['Orders']}",
                  "Order Taken",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${stats['Cancellation']}",
                  "Cancellations",
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Third row of cards (You might need to adjust this based on available data)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "${stats['Orders'] - stats['Cancellation']}", // Net orders calculation
                  "Net Orders",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  "0", // Replace with actual data if available
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

  Widget _buildProfileAvatar(String firstName, int index, String userId) {
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
        // Text(
        //   lastName,
        //   style: AppFont.mediumText14(context),
        // ),
      ],
    );
  }

  Widget _buildUpcomingActivities(BuildContext context) {
    if (_individualPerformanceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Text(
            "Upcoming Activities",
            style: AppFont.mediumText14(context),
          ),
        ),

        // Upcoming Followups
        if (_upcomingFollowups.isNotEmpty)
          _buildActivitySection(context, _upcomingFollowups),

        // Upcoming Appointments
        if (_upcomingAppointments.isNotEmpty)
          _buildActivitySection(context, _upcomingAppointments),

        // Upcoming Test Drives
        if (_upcomingTestDrives.isNotEmpty)
          _buildActivitySection(context, _upcomingTestDrives),
      ],
    );
  }

  Widget _buildActivitySection(
      BuildContext context, List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: Text(
        //     title,
        //     style: AppFont.mediumText14(context),
        //   ),
        // ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(5)),
                child: _buildFollowupCard(
                  context,
                  name: activity['name'] ?? '',
                  subject: activity['subject'] ?? '',
                  date: activity['due_date'] ?? activity['start_date'] ?? '',
                  leadId: activity['lead_id'] ?? '',
                  vehicle: activity['PMI'] ?? '',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowupCard(
    BuildContext context, {
    required String name,
    required String subject,
    required String date,
    required String leadId,
    required String vehicle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: const Border(
          left: BorderSide(width: 8.0, color: AppColors.colorsBlue),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(name, style: AppFont.dashboardName(context)),
                      if (vehicle.isNotEmpty) _buildVerticalDivider(15),
                      if (vehicle.isNotEmpty)
                        Text(
                          vehicle,
                          style: AppFont.dashboardCarName(context),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(subject, style: AppFont.smallText(context)),
                      _formatDate(context, date),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (leadId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FollowupsDetails(leadId: leadId)),
                );
              } else {
                print("Invalid leadId");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: AppColors.arrowContainerColor,
                  borderRadius: BorderRadius.circular(30)),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 25, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatDate(BuildContext context, String dateStr) {
    String formattedDate = '';

    try {
      DateTime parseDate = DateTime.parse(dateStr);

      // Check if the date is today
      if (parseDate.year == DateTime.now().year &&
          parseDate.month == DateTime.now().month &&
          parseDate.day == DateTime.now().day) {
        formattedDate = 'Today';
      } else {
        // If not today, format it as "26th March"
        int day = parseDate.day;
        String suffix = _getDaySuffix(day);
        String month = DateFormat('MMM').format(parseDate); // Full month name
        formattedDate = '${day}$suffix $month';
      }
    } catch (e) {
      formattedDate = dateStr; // Fallback if date parsing fails
    }

    return Row(
      children: [
        const SizedBox(width: 5),
        Text(formattedDate, style: AppFont.smallText(context)),
      ],
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildVerticalDivider(double height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
      height: height,
      width: 0.1,
      decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.fontColor))),
    );
  }

  @override
  void initState() {
    super.initState();
    _data = fetchData();
    // _data = _fetchData('Test Drives');
    // _teamComparisonData = fetchTeamComparisonData();
    _teamComparisonData = fetchTeamComparisonData().then((data) {
      print("Data fetched successfully");
      setState(() {
        isLoading = false;
      });
      return data;
    }).catchError((error) {
      print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
      throw error;
    });
    // _teamComparisonData = fetchTeamComparisonData();
    _fetchDataUserProfile().then((data) {
      setState(() {
        ('Test Drives'); // You can update the team profiles or other data here based on the fetched response
      });
    }).catchError((e) {
      // Handle any error here
      print('Error: $e');
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    // Simulate fetching data
    await Future.delayed(Duration(seconds: 2));
    return {"key": "value"};
  }

  List<Map<String, dynamic>> processDataForDisplay(
      Map<String, dynamic> responseData) {
    List<Map<String, dynamic>> result = [];

    // Add independent user if present
    if (responseData.containsKey('independentUser')) {
      final user = responseData['independentUser'];
      if (user != null) {
        result.add({
          'name': user['name'] ?? 'Unknown',
          'count': _getMetricValueForUser(user),
          'type': 'user'
        });
      }
    }

    // Process teams and their members
    if (responseData.containsKey('teamsData')) {
      final teams = responseData['teamsData'];
      if (teams != null && teams is List) {
        for (var team in teams) {
          // Add team header
          result.add({
            'name': team['team_name'] ?? 'Unnamed Team',
            'count': _calculateTeamTotal(team),
            'type': 'team'
          });

          // Add team members if present
          if (team.containsKey('member') &&
              team['member'] != null &&
              team['member'] is List &&
              team['member'].isNotEmpty) {
            for (var member in team['member']) {
              result.add({
                'name': member['name'] ?? 'Unknown Member',
                'count': _getMetricValueForUser(member),
                'type': 'member'
              });
            }
          }
        }
      }
    }

    return result;
  }

  int findMaxValue(List<Map<String, dynamic>> items) {
    int max = 0;
    for (var item in items) {
      final count = item['count'];
      if (count != null && count is int && count > max) {
        max = count;
      }
    }
    return max > 0 ? max : 1; // Avoid division by zero
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

                  // If _tabIndex != 0, show nothing (empty SizedBox)

                  // Profile avatars (only show for Individual Performance tab)
                  if (_tabIndex == 0) _buildProfileAvatars(),

                  // Period filter and date selection

                  // Start of your widget
                  Column(
                    children: [
                      // Period Filter and Individual/Team view with condition
                      _tabIndex == 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Container(
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
                                        // _buildFollowupCard(context),
                                      ],
                                    ),
                                  ),
                                  _buildUpcomingActivities(context),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                _comparisionButtons(screenWidth),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  child: Wrap(
                                    spacing: 4,
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

                                FutureBuilder<Map<String, dynamic>>(
                                  future: _teamComparisonData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      print(
                                          "FutureBuilder error: ${snapshot.error}");
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (snapshot.hasData) {
                                      final responseData = snapshot.data!;

                                      // Add safety check to see if the data is structured as expected
                                      if (!responseData
                                              .containsKey('independentUser') &&
                                          !responseData
                                              .containsKey('teamsData')) {
                                        print(
                                            "Data structure is not as expected: $responseData");
                                        return const Center(
                                            child: Text('Invalid data format'));
                                      }

                                      // Process data to get all items to display
                                      List<Map<String, dynamic>> displayItems =
                                          processDataForDisplay(responseData);

                                      // Find maximum value for scaling
                                      int maxValue = findMaxValue(displayItems);

                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Show "Target" label
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0, bottom: 16.0),
                                              child: Text(
                                                "Target",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),

                                            // Display all items with progress bars - use a fixed height container instead of Expanded
                                            Container(
                                              height:
                                                  300, // Set a fixed height for the list
                                              child: ListView.builder(
                                                shrinkWrap: true, // Add this
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(), // Allow scrolling
                                                itemCount: displayItems.length,
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      displayItems[index];
                                                  final count =
                                                      item['count'] ?? 0;
                                                  final percentage =
                                                      maxValue > 0
                                                          ? count / maxValue
                                                          : 0.0;
                                                  final isTeam =
                                                      item['type'] == 'team';

                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        // Name with proper indentation for team members
                                                        SizedBox(
                                                          width: 100,
                                                          child: Text(
                                                            item['name'] ?? '',
                                                            style: TextStyle(
                                                              fontWeight: isTeam
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),

                                                        // Progress bar
                                                        Expanded(
                                                          child:
                                                              LinearPercentIndicator(
                                                            percent: percentage
                                                                .clamp(
                                                                    0.0, 1.0),
                                                            lineHeight: 20.0,
                                                            barRadius:
                                                                const Radius
                                                                    .circular(
                                                                    10),
                                                            backgroundColor:
                                                                Colors
                                                                    .grey[200],
                                                            linearGradient:
                                                                LinearGradient(
                                                              colors:
                                                                  _getGradientForIndex(
                                                                      index),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 10),
                                                          ),
                                                        ),

                                                        // Count value
                                                        Text(
                                                          '$count',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                          child: Text('No Data Available'));
                                    }
                                  },
                                ),

// thir code for first button
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
                                                // data['teamProfiles'][index]
                                                //     ['lastName'],
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
                      // color: _tabIndex == 0 ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color:
                            _tabIndex == 0 ? Colors.blue : Colors.transparent,
                      ),
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
                                _tabIndex == 0 ? Colors.blue : Colors.black54,
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
                      // color: _tabIndex == 1 ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color:
                            _tabIndex == 1 ? Colors.blue : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Team Comparison',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _tabIndex == 1 ? Colors.blue : Colors.black54,
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
                margin: const EdgeInsets.only(top: 10),
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    teamProfiles.length,
                    (index) => _buildProfileAvatar(
                      teamProfiles[index]['name'] ?? '',
                      // teamProfiles[index]['lastName'] ?? '',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fontColor, width: .2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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

  // Widget _buildPeriodButton(String text, int index) {
  //   bool isSelected = _periodIndex == index;

  //   return InkWell(
  //     onTap: () {
  //       setState(() {
  //         _periodIndex = index;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
  //       decoration: BoxDecoration(
  //         // color: isSelected ? Colors.blue : Colors.grey.shade200,
  //         // border: Border.all(color:  isSelected Colors.blue : Colors.grey.shade200),
  //         border: Border.all(
  //             color: isSelected ? Colors.blue : Colors.transparent, width: 1),

  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //       child: Text(
  //         text,
  //         style: GoogleFonts.poppins(
  //           fontSize: 12,
  //           fontWeight: FontWeight.w500,
  //           color: isSelected ? Colors.blue : Colors.black,
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          // color: isSelected ? Colors.blue : Colors.grey.shade200,
          // border: Border.all(color:  isSelected Colors.blue : Colors.grey.shade200),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent, width: 1),

          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          // textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamComparisonView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _teamComparisonData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("FutureBuilder error: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final responseData = snapshot.data!;

          // Safety check for data structure
          if (!responseData.containsKey('independentUser') &&
              !responseData.containsKey('teamsData')) {
            return const Center(child: Text('Invalid data format'));
          }

          // Get the metric key based on selected button
          String metricKey = _getMetricKeyForComparison();

          // Process and prepare data for display
          List<Map<String, dynamic>> allMembers =
              _extractAllMembersForComparison(responseData, metricKey);

          // Sort members by value (descending)
          allMembers
              .sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));

          // Find max value for scaling
          int maxValue = allMembers.isEmpty ? 10 : allMembers.first['value'];
          if (maxValue == 0) maxValue = 10; // Prevent division by zero

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // "Target" label on right side
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: Text(
                    "Target",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Display team members with progress bars
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allMembers.length,
                  itemBuilder: (context, index) {
                    final member = allMembers[index];
                    final name = member['name'] ?? 'Unknown';
                    final value = member['value'] as int;
                    final percentage = value / maxValue;

                    // Get color based on index position
                    final barColor = _getBarColorForIndex(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          // Member name (fixed width)
                          SizedBox(
                            width: 90,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Progress bar
                          Expanded(
                            child: Stack(
                              children: [
                                // Background bar
                                Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                // Colored progress bar
                                FractionallySizedBox(
                                  widthFactor: percentage.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Value display
                          SizedBox(
                            width: 30,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No Data Available'));
        }
      },
    );
  }

// Helper method to get the metric key based on button selection
  String _getMetricKeyForComparison() {
    switch (_selectedButtonIndex) {
      case 0:
        return 'enquiries';
      case 1:
        return 'testDrives';
      case 2:
        return 'orders'; // Net Orders
      case 3:
        return 'orders'; // New Orders (same field)
      case 4:
        return 'cancellation';
      case 5:
        return 'retail'; // or whatever field is used for retail
      default:
        return 'enquiries';
    }
  }

// Extract all members including independent user into a flat list
  List<Map<String, dynamic>> _extractAllMembersForComparison(
      Map<String, dynamic> data, String metricKey) {
    List<Map<String, dynamic>> result = [];

    // Add independent user if present
    if (data.containsKey('independentUser') &&
        data['independentUser'] != null) {
      final user = data['independentUser'];
      if (user != null && user.containsKey('stats')) {
        result.add({
          'name': user['name'] ?? 'Unknown',
          'value': user['stats'][metricKey] ?? 0,
        });
      }
    }

    // Process team members
    if (data.containsKey('teamsData') && data['teamsData'] != null) {
      for (var team in data['teamsData']) {
        if (team.containsKey('member') && team['member'] != null) {
          for (var member in team['member']) {
            if (member != null && member.containsKey('stats')) {
              result.add({
                'name': member['name'] ?? 'Unknown',
                'value': member['stats'][metricKey] ?? 0,
              });
            }
          }
        }
      }
    }

    return result;
  }

// Get color for bar based on index position
  Color _getBarColorForIndex(int index) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.amber,
      Colors.orange,
      Colors.red,
    ];

    return colors[index % colors.length];
  }

// Individual period button for comparison tab
  Widget _buildPeriodButtonForComparison(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _periodIndex = index;
          _teamComparisonData = fetchTeamComparisonData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          border: Border.all(
              color: _periodIndex == index ? Colors.blue : Colors.transparent),
          // color: _periodIndex == index ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _periodIndex == index ? Colors.blue : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _comparisionButtons(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildPeriodButtonForComparison('All', 0),
                _buildPeriodButtonForComparison('MTD', 1),
                _buildPeriodButtonForComparison('QTD', 2),
                _buildPeriodButtonForComparison('YTD', 3),
              ],
            ),
          ),

          // Calendar button
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
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

// Button group for metrics selection that matches design
  Widget _buildMetricButtonsRow() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _buildMetricToggleButton('Enquiries', 0),
          _buildMetricToggleButton('Test Drives', 1),
          _buildMetricToggleButton('Net Orders', 2),
          _buildMetricToggleButton('New Orders', 3),
          _buildMetricToggleButton('Cancellations', 4),
          _buildMetricToggleButton('Retail', 5),
        ],
      ),
    );
  }

  Widget _buildMetricToggleButton(String title, int index) {
    bool isSelected = _selectedButtonIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedButtonIndex = index;
            _teamComparisonData = fetchTeamComparisonData();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black87,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
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

  // data will show

  // Widget _buildFollowupCard(BuildContext context) {
  //   // bool isFavoriteSwipe = widget.swipeOffset > 50;
  //   // bool isCallSwipe = widget.swipeOffset < -50;

  //   // Gradient background for swipe
  //   // LinearGradient _buildSwipeGradient() {
  //   //   if (isFavoriteSwipe) {
  //   //     return const LinearGradient(
  //   //       colors: [
  //   //         Color.fromRGBO(239, 206, 29, 0.67),
  //   //         Color.fromRGBO(239, 206, 29, 0.67)
  //   //       ],
  //   //       begin: Alignment.centerLeft,
  //   //       end: Alignment.centerRight,
  //   //     );
  //   //   } else if (isCallSwipe) {
  //   //     return LinearGradient(
  //   //       colors: [
  //   //         Colors.green.withOpacity(0.2),
  //   //         Colors.green.withOpacity(0.8)
  //   //       ],
  //   //       begin: Alignment.centerRight,
  //   //       end: Alignment.centerLeft,
  //   //     );
  //   //   }
  //   //   return const LinearGradient(
  //   //     colors: [AppColors.containerBg, AppColors.containerBg],
  //   //     begin: Alignment.centerLeft,
  //   //     end: Alignment.centerRight,
  //   //   );
  //   // }

  //   return Stack(
  //     children: [
  //       // // Favorite Swipe Overlay
  //       // if (isFavoriteSwipe)
  //       //   Positioned.fill(
  //       //     child: Container(
  //       //       decoration: BoxDecoration(
  //       //         gradient: LinearGradient(
  //       //           colors: [
  //       //             Colors.yellow.withOpacity(0.2),
  //       //             Colors.yellow.withOpacity(0.8)
  //       //           ],
  //       //           begin: Alignment.centerLeft,
  //       //           end: Alignment.centerRight,
  //       //         ),
  //       //         borderRadius: BorderRadius.circular(10),
  //       //       ),
  //       //       child: Center(
  //       //         child: Row(
  //       //           mainAxisAlignment: MainAxisAlignment.start,
  //       //           children: [
  //       //             const SizedBox(width: 15),
  //       //             Icon(
  //       //                 isFav ? Icons.star_outline_rounded : Icons.star_rounded,
  //       //                 color: Color.fromRGBO(226, 195, 34, 1),
  //       //                 size: 40),
  //       //             const SizedBox(width: 10),
  //       //             Text(isFav ? 'Unfavorite' : 'Favorite',
  //       //                 style: GoogleFonts.poppins(
  //       //                     color: Color.fromRGBO(187, 158, 0, 1),
  //       //                     fontSize: 18,
  //       //                     fontWeight: FontWeight.bold)),
  //       //           ],
  //       //         ),
  //       //       ),
  //       //     ),
  //       //   ),

  //       // // Call Swipe Overlay
  //       // if (isCallSwipe)
  //       //   Positioned.fill(
  //       //     child: Container(
  //       //       decoration: BoxDecoration(
  //       //         gradient: LinearGradient(
  //       //           colors: [
  //       //             Colors.green.withOpacity(0.2),
  //       //             Colors.green.withOpacity(0.8)
  //       //           ],
  //       //           begin: Alignment.centerRight,
  //       //           end: Alignment.centerLeft,
  //       //         ),
  //       //         borderRadius: BorderRadius.circular(10),
  //       //       ),
  //       //       child: Center(
  //       //         child: Row(
  //       //           mainAxisAlignment: MainAxisAlignment.start,
  //       //           children: [
  //       //             const SizedBox(
  //       //               width: 10,
  //       //             ),
  //       //             const Icon(Icons.phone_in_talk,
  //       //                 color: Colors.white, size: 30),
  //       //             const SizedBox(width: 10),
  //       //             Text('Call',
  //       //                 style: GoogleFonts.poppins(
  //       //                     color: Colors.white,
  //       //                     fontSize: 18,
  //       //                     fontWeight: FontWeight.bold)),
  //       //             const SizedBox(width: 5),
  //       //           ],
  //       //         ),
  //       //       ),
  //       //     ),
  //       //   ),

  //       // Main Container
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  //         decoration: BoxDecoration(
  //           // gradient: _buildSwipeGradient(),
  //           borderRadius: BorderRadius.circular(5),
  //           border: Border(
  //             left: BorderSide(width: 8.0, color: AppColors.sideGreen),
  //           ),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Row(
  //               children: [
  //                 const SizedBox(width: 8),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         _buildUserDetails(context),
  //                         _buildVerticalDivider(15),
  //                         _buildCarModel(context),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Row(
  //                       children: [
  //                         _buildSubjectDetails(context),
  //                         // _date(context),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             _buildNavigationButton(context),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildNavigationButton(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (widget.leadId.isNotEmpty) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => FollowupsDetails(leadId: widget.leadId)),
  //         );
  //       } else {
  //         print("Invalid leadId");
  //       }
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.all(3),
  //       decoration: BoxDecoration(
  //           color: AppColors.arrowContainerColor,
  //           borderRadius: BorderRadius.circular(30)),
  //       child: const Icon(Icons.arrow_forward_ios_rounded,
  //           size: 25, color: Colors.white),
  //     ),
  //   );
  // }

  // Widget _buildUserDetails(BuildContext context) {
  //   return Text(widget.name,
  //       textAlign: TextAlign.end, style: AppFont.dashboardName(context));
  // }

  // Widget _buildSubjectDetails(BuildContext context) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // const Icon(Icons.phone_in_talk, color: Colors.blue, size: 18),
  //       // const SizedBox(width: 5),
  //       Text(widget.subject, style: AppFont.smallText(context)),
  //     ],
  //   );
  // }

  // Widget _date(BuildContext context) {
  //   String formattedDate = '';

  //   try {
  //     DateTime parseDate = DateTime.parse(widget.date);

  //     // Check if the date is today
  //     if (parseDate.year == DateTime.now().year &&
  //         parseDate.month == DateTime.now().month &&
  //         parseDate.day == DateTime.now().day) {
  //       formattedDate = 'Today';
  //     } else {
  //       // If not today, format it as "26th March"
  //       int day = parseDate.day;
  //       String suffix = _getDaySuffix(day);
  //       String month = DateFormat('MMM').format(parseDate); // Full month name
  //       formattedDate = '${day}$suffix $month';
  //     }
  //   } catch (e) {
  //     formattedDate = widget.date; // Fallback if date parsing fails
  //   }

  //   return Row(
  //     children: [
  //       const SizedBox(width: 5),
  //       Text(formattedDate, style: AppFont.smallText(context)),
  //     ],
  //   );
  // }

  // String _getDaySuffix(int day) {
  //   if (day >= 11 && day <= 13) {
  //     return 'th';
  //   }
  //   switch (day % 10) {
  //     case 1:
  //       return 'st';
  //     case 2:
  //       return 'nd';
  //     case 3:
  //       return 'rd';
  //     default:
  //       return 'th';
  //   }
  // }

  // Widget _buildVerticalDivider(double height) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 3, left: 10, right: 10),
  //     height: height,
  //     width: 0.1,
  //     decoration: const BoxDecoration(
  //         border: Border(right: BorderSide(color: AppColors.fontColor))),
  //   );
  // }

  // Widget _buildCarModel(BuildContext context) {
  //   return Text(
  //     widget.vehicle,
  //     textAlign: TextAlign.start,
  //     style: AppFont.dashboardCarName(context),
  //     softWrap: true,
  //     overflow: TextOverflow.visible,
  //   );
  // }
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
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
