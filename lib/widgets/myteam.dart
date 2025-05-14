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
import 'package:smart_assist/widgets/call_history.dart';

class Myteam extends StatefulWidget {
  const Myteam({super.key});

  @override
  State<Myteam> createState() => _MyteamState();
}

class _MyteamState extends State<Myteam> {
  bool isHide = false;
  String _selectedType = 'All';
  String _selectedMetric = 'Enquiries';

  bool isHideActivities = false;
  bool isHideCalls = false;
  int _periodIndex = 0; // ALL, MTD, QTD, YTD
  int _tabIndex = 0; // 0 for Individual Performance, 1 for Team Comparison
  int _selectedButtonIndex = 0;
  int _selectedProfileIndex = -1; // Track selected profile
  String _selectedUserId = '';
  int _metricIndex = 0;
  late Future<Map<String, dynamic>> _data;
  late Future<Map<String, dynamic>> _teamComparisonData;

  // remove this
  List<Map<String, dynamic>> staticTeamData = [];
  Set<String> selectedTeams = {};
  bool showAll = false;

  // Class level variables to store upcoming activities
  List<Map<String, dynamic>> _upcomingFollowups = [];
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _upcomingTestDrives = [];

  final FabController fabController = Get.put(FabController());
  Map<String, dynamic> _individualPerformanceData = {};
  // Map<String, dynamic> _allPerformanceData = {};
  Map<String, dynamic> _allPerformanceData = {};

  static Map<String, int> _callLogs = {
    'all': 0,
    'outgoing': 0,
    'incoming': 0,
    'missed': 0,
  };

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
        case 0:
          periodParam = '?type=ALL';
          break;
        case 1:
          periodParam = '?type=1D';
          break;
        case 2:
          periodParam = '?type=1W';
          break;
        case 3:
          periodParam = '?type=1M';
          break;
        case 4:
          periodParam = '?type=1Q';
          break;
        case 5:
          periodParam = '?type=1Y';
          break;
        default:
          periodParam = 'All';
      }

      Uri url = Uri.parse(
          'https://dev.smartassistapp.in/api/users/sm/dashboard/team-comparison$periodParam');

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
        throw Exception('Failed to fetch datas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching team comparison data: $e');
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

// First, add a method to fetch the All performance data
  Future<void> _fetchAllTeamPerformance() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/users/sm/dashboard/all-performance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Store the all performance data
        setState(() {
          _allPerformanceData = data['data'];
        });

        print("All team performance data fetched successfully");
      } else {
        throw Exception('Failed to load all team performance data');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchDataUserProfile() async {
    try {
      // Simulate an API call for Individual Performance or Team Data
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/users/sm/dashboard/individual-performance'),
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
              'fname': member['fname'],
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
            'https://dev.smartassistapp.in/api/users/sm/dashboard/individual-performance?user_id=$userId'),
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
    // Determine which data to use based on selection
    Map<String, dynamic> performanceData;
    Map<String, dynamic> stats;

    if (_selectedProfileIndex == 0) {
      // Using All performance data
      if (_allPerformanceData.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Center(child: Text('No performance data available.')),
        );
      }

      // Format the data to match the expected structure
      stats = {
        'Enquiries': _allPerformanceData['enquiries'] ?? 0,
        'TestDrives': _allPerformanceData['testDrives'] ?? 0,
        'Orders': _allPerformanceData['orders'] ?? 0,
        'Cancellation': _allPerformanceData['cancellation'] ?? 0,
      };

      performanceData = {'stats': stats};
    } else {
      // Using individual performance data
      if (_individualPerformanceData.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Center(child: Text('No performance data available.')),
        );
      }

      // Access the stats data from individual performance
      performanceData = _individualPerformanceData;
      stats = performanceData['stats'];
    }

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
                  isSelected: _selectedMetric == "Enquiries",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "Enquiries";
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${stats['TestDrives']}",
                  "Test Drive\nDone",
                  Colors.blue,
                  isSelected: _selectedMetric == "TestDrives",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "TestDrives";
                    });
                  },
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
                  isSelected: _selectedMetric == "Orders",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "Orders";
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "${stats['Cancellation']}",
                  "Cancellations",
                  Colors.blue,
                  isSelected: _selectedMetric == "Cancellation",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "Cancellation";
                    });
                  },
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
                  "${(stats['Orders'] ?? 0) - (stats['Cancellation'] ?? 0)}", // Net orders calculation
                  "Net Order",
                  Colors.blue,
                  isSelected: _selectedMetric == "Net Order",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "Net Order";
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  "0", // Replace with actual data if available
                  "Retails",
                  Colors.blue,
                  isSelected: _selectedMetric == "Retails",
                  onTap: () {
                    setState(() {
                      _selectedMetric = "Retails";
                    });
                  },
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
              _selectedType = 'dynamic';
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
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

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          //   child: Text(
          //     "No Activities",
          //     style: AppFont.mediumText14(context),
          //   ),
          // ),

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
      ),
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
    _selectedProfileIndex = 0;
    _initialize();
  }

  // Static data for team comparison
  List<Map<String, dynamic>> _getStaticTeamData() {
    return [
      {
        'name': 'Sumit',
        'type': 'team',
        'count': 75,
        'id': 'product_team',
        'members': [
          {'name': 'Andrew Smith', 'count': 35, 'id': 'andrew_smith'},
          {'name': 'Michael Torres', 'count': 25, 'id': 'michael_torres'},
          {'name': 'Sam Peters', 'count': 65, 'id': 'sam_peters'},
        ]
      },
      {
        'name': 'Anand',
        'type': 'team',
        'count': 85,
        'id': 'sales_team',
        'members': [
          {'name': 'Angela Davis', 'count': 15, 'id': 'angela_davis'},
          {'name': 'Mark Singer', 'count': 60, 'id': 'mark_singer'},
          {'name': 'Sarah Johnson', 'count': 45, 'id': 'sarah_johnson'},
        ]
      },
      {
        'name': 'Kenem',
        'type': 'team',
        'count': 55,
        'id': 'design_team',
        'members': [
          {'name': 'James Wilson', 'count': 30, 'id': 'james_wilson'},
          {'name': 'Emma Taylor', 'count': 70, 'id': 'emma_taylor'},
          {'name': 'David Lopez', 'count': 40, 'id': 'david_lopez'},
        ]
      },
      {
        'name': 'sikos',
        'type': 'team',
        'count': 55,
        'id': 'design_team',
        'members': [
          {'name': 'James Wilson', 'count': 30, 'id': 'james_wilson'},
          {'name': 'Emma Taylor', 'count': 70, 'id': 'emma_taylor'},
          {'name': 'David Lopez', 'count': 40, 'id': 'david_lopez'},
        ]
      }
    ];
  }

  // Find the maximum value for scaling progress bars
  int findMaxValue(List<Map<String, dynamic>> items) {
    int max = 0;
    for (var item in items) {
      if (item['count'] != null && item['count'] > max) {
        max = item['count'];
      }

      if (item['members'] != null) {
        for (var member in item['members']) {
          if (member['count'] != null && member['count'] > max) {
            max = member['count'];
          }
        }
      }
    }
    return max;
  }

  // Get display items based on selected teams or show all
  List<Map<String, dynamic>> getDisplayItems() {
    List<Map<String, dynamic>> displayItems = [];

    if (showAll) {
      // Show all teams and their members
      for (var team in staticTeamData) {
        displayItems.add(team);
        if (team['members'] != null) {
          for (var member in team['members']) {
            member['type'] = 'member';
            displayItems.add(member);
          }
        }
      }
    } else if (selectedTeams.isEmpty) {
      // Show only team headers when nothing is selected
      displayItems = List.from(staticTeamData);
    } else {
      // Show selected teams and their members
      for (var team in staticTeamData) {
        if (selectedTeams.contains(team['id'])) {
          displayItems.add(team);
          if (team['members'] != null) {
            for (var member in team['members']) {
              member['type'] = 'member';
              displayItems.add(member);
            }
          }
        }
      }
    }

    return displayItems;
  }

  // Handle team selection
  void toggleTeamSelection(String teamId) {
    setState(() {
      if (selectedTeams.contains(teamId)) {
        selectedTeams.remove(teamId);
        showAll = false;
      } else {
        // Limit to two selections
        if (selectedTeams.length < 2) {
          selectedTeams.add(teamId);
        } else {
          // If already have 2 selections, remove the first one and add the new one
          selectedTeams = {selectedTeams.last, teamId};
        }
        showAll = false;
      }
    });
  }

  Future<void> _initialize() async {
    setState(() {
      isLoading = true;
    });

    try {
      //  _data = fetchData();
      _data = fetchData();
      _teamComparisonData = fetchTeamComparisonData();
      await _teamComparisonData; // properly await

      staticTeamData = _getStaticTeamData(); //remove this

      // Fetch team performance data for all users first
      await _fetchAllTeamPerformance();

      _fetchDataUserProfile().then((data) {
        // Update any fields based on user profile data
        print('User profile fetched successfully');
      }).catchError((e) {
        print('Error fetching user profile: $e');
      });

      print("Team comparison data fetched successfully");
    } catch (error) {
      print("Error during initialization: $error");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    // Simulate fetching data
    try {
      await Future.delayed(const Duration(seconds: 2));
      return {"key": "value"};
    } catch (e) {
      print(e);
      return {};
    }
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
//uncommment
  // int findMaxValue(List<Map<String, dynamic>> items) {
  //   int max = 0;
  //   for (var item in items) {
  //     final count = item['count'];
  //     if (count != null && count is int && count > max) {
  //       max = count;
  //     }
  //   }
  //   return max > 0 ? max : 1; // Avoid division by zero
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final List<Map<String, dynamic>> displayItems = getDisplayItems();
    final int maxValue = findMaxValue(staticTeamData);

    return Scaffold(
      appBar: AppBar(
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
                  // _buildTabButtons(),

                  // If _tabIndex != 0, show nothing (empty SizedBox)

                  // Profile avatars (only show for Individual Performance tab)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_tabIndex == 0) ...[
                          _buildProfileAvatarStaticsAll(
                            'All',
                            0,
                          ),
                          _buildProfileAvatars(),
                        ]
                      ],
                    ),
                  ),

                  // Period filter and date selection

                  // Start of your widget
                  Column(
                    children: [
                      // Period Filter and Individual/Team view with condition

                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLightGrey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  _comparisionButtons(screenWidth),
                                  _buildIndividualPerformanceView(
                                      context, screenWidth),
                                  // _buildFollowupCard(context),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            if (_selectedType != 'All') ...[
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 10, bottom: 0),
                                          child: Text(
                                            'Activities',
                                            style:
                                                AppFont.dropDowmLabel(context),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isHideActivities =
                                                  !isHideActivities;
                                            });
                                          },
                                          icon: Icon(
                                            isHideActivities
                                                ? Icons
                                                    .keyboard_arrow_down_rounded
                                                : Icons
                                                    .keyboard_arrow_up_rounded,
                                            size: 35,
                                            color: AppColors.iconGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isHideActivities) ...[
                                Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.backgroundLightGrey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.only(top: 10),
                                    child: _buildUpcomingActivities(context)),
                              ],
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 10, bottom: 0),
                                          child: Text(
                                            'Call Analysis',
                                            style:
                                                AppFont.dropDowmLabel(context),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isHideCalls = !isHideCalls;
                                            });
                                          },
                                          icon: Icon(
                                            isHideCalls
                                                ? Icons
                                                    .keyboard_arrow_down_rounded
                                                : Icons
                                                    .keyboard_arrow_up_rounded,
                                            size: 35,
                                            color: AppColors.iconGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isHideCalls) ...[
                                Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.backgroundLightGrey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.only(top: 10),
                                    child: _callLogsWidget(context)),
                              ],
                            ],

                            const SizedBox(
                              height: 10,
                            ),

                            if (_selectedType != 'dynamic') ...[
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 10, bottom: 0),
                                          child: Text(
                                            'Team Comparison',
                                            style:
                                                AppFont.dropDowmLabel(context),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isHide = !isHide;
                                            });
                                          },
                                          icon: Icon(
                                            isHide
                                                ? Icons
                                                    .keyboard_arrow_down_rounded
                                                : Icons
                                                    .keyboard_arrow_up_rounded,
                                            size: 35,
                                            color: AppColors.iconGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isHide) ...[
                                Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.backgroundLightGrey,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        // Show "Target" label
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // "Show All" button (appears only when teams are selected)
                                            if (selectedTeams.isNotEmpty &&
                                                !showAll)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      showAll = true;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: const Text("Show All"),
                                                ),
                                              ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10,
                                                  right: 8.0,
                                                  bottom: 10.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  child: Text(
                                                    "Target",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Display all items with progress bars
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: displayItems.length,
                                          itemBuilder: (context, index) {
                                            final item = displayItems[index];
                                            final count = item['count'] ?? 0;
                                            final percentage = maxValue > 0
                                                ? count / maxValue
                                                : 0.0;
                                            final isTeam =
                                                item['type'] == 'team';
                                            final teamId = item['id'] ?? '';
                                            final isSelected =
                                                selectedTeams.contains(teamId);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Checkbox (only for team headers)
                                                  if (isTeam)
                                                    Checkbox(
                                                      value: isSelected,
                                                      onChanged: (bool? value) {
                                                        toggleTeamSelection(
                                                            teamId);
                                                      },
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    )
                                                  else
                                                    const SizedBox(width: 24),

                                                  // Name with proper indentation for team members
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      item['name'] ?? '',
                                                      style: TextStyle(
                                                        fontWeight: isTeam
                                                            ? FontWeight
                                                                .normal // Changed from bold to normal
                                                            : FontWeight.normal,
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  // Progress bar
                                                  Expanded(
                                                    child:
                                                        LinearPercentIndicator(
                                                      percent: percentage.clamp(
                                                          0.0, 1.0),
                                                      lineHeight: 20.0,
                                                      barRadius:
                                                          const Radius.circular(
                                                              10),
                                                      backgroundColor:
                                                          Colors.grey[200],
                                                      linearGradient:
                                                          LinearGradient(
                                                        colors:
                                                            _getGradientForIndex(
                                                                index),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                    ),
                                                  ),

                                                  // Count value
                                                  Text(
                                                    '$count',
                                                    style: const TextStyle(
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
                                      ],
                                    ))
                              ],
                            ],
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
                                            data['teamProfiles'][index]['name'],
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
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 5,
          right: 16,
          child: _buildFloatingActionButton(context),
        ),

        // Popup Menu (Conditionally Rendered)
        Obx(() => fabController.isFabExpanded.value
            ? _buildPopupMenu(context)
            : const SizedBox.shrink()),
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

  Widget _callLogsWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // All Calls
          _buildRow('All Calls', _callLogs['all'] ?? 0, '', Icons.call),

          // Outgoing Calls
          _buildRow('Outgoing Calls', _callLogs['outgoing'] ?? 0, 'outgoing',
              Icons.phone_forwarded_outlined),

          // Incoming Calls
          _buildRow('Incoming Calls', _callLogs['incoming'] ?? 0, 'incoming',
              Icons.call),

          // Missed Calls
          _buildRow('Missed Calls', _callLogs['missed'] ?? 0, 'missed',
              Icons.call_missed),
        ],
      ),
    );
  }

// Helper method to build each row with dynamic values
  Widget _buildRow(String title, int count, String category, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          icon,
          size: 25,
          color: _getIconColor(category),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.1),
        Text(
          title,
          style: AppFont.dropDowmLabel(context),
        ),
        Expanded(child: Container()),
        Text(
          '$count', // Use dynamic value
          style: AppFont.dropDowmLabel(context),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallHistory(
                  category: category,
                  mobile: '',
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 25,
            color: AppColors.iconGrey,
          ),
        ),
      ],
    );
  }

// Helper method to get icon color based on category
  Color _getIconColor(String category) {
    switch (category) {
      case 'outgoing':
        return AppColors.colorsBlue;
      case 'incoming':
        return AppColors.sideGreen;
      case 'missed':
        return AppColors.sideRed;
      case 'rejected':
        return AppColors.iconGrey;
      default:
        return AppColors.iconGrey;
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < teamProfiles.length; i++)
                      _buildProfileAvatar(
                        // teamProfiles[i]['name'] ?? '',
                        teamProfiles[i]['fname'] ?? '',
                        i + 1, // Index starts from 1 because 0 is for "All"
                        teamProfiles[i]['user_id'] ?? '',
                      ),
                  ],
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

  Widget _buildProfileAvatarStaticsAll(
    String firstName,
    int index,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedProfileIndex = index;
              _selectedType = 'All';
              // _selectedType = firstName;
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
          'All',
          style: AppFont.mediumText14(context),
        ),
        // Text(
        //   lastName,
        //   style: AppFont.mediumText14(context),
        // ),
      ],
    );
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
            margin: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildPeriodButtonForComparison('1D', 0),
                _buildPeriodButtonForComparison('1W', 1),
                _buildPeriodButtonForComparison('1M', 2),
                _buildPeriodButtonForComparison('1Q', 3),
                _buildPeriodButtonForComparison('1Y', 4),
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

  Widget _buildMetricCard(
    String value,
    String label,
    Color valueColor, {
    required bool isSelected,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
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
      ),
    );
  }

  // Widget _buildMetricCard(
  //   String value,
  //   String label,

  //   Color valueColor, {

  //   Color backgroundColor = Colors.white,
  //   Color textColor = Colors.black,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: backgroundColor,
  //       borderRadius: BorderRadius.circular(8),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           value,
  //           style: GoogleFonts.poppins(
  //             fontSize: 30,
  //             fontWeight: FontWeight.bold,
  //             color: backgroundColor == Colors.white ? valueColor : textColor,
  //           ),
  //         ),
  //         const SizedBox(width: 4),
  //         Align(
  //           alignment: Alignment.centerRight,
  //           child: Text(
  //             label,
  //             maxLines: 3,
  //             textAlign: TextAlign.center,
  //             style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               color: textColor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

extension on EdgeInsets {
  only({required double left}) {}
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
          backgroundColor: const Color(0xffF3F9FF),
          padding: const EdgeInsets.symmetric(
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
