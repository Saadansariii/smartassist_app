import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/utils/storage.dart';

class MyTeams extends StatefulWidget {
  const MyTeams({Key? key}) : super(key: key);

  @override
  State<MyTeams> createState() => _MyTeamsState();
}

class _MyTeamsState extends State<MyTeams> {
  // Tab and filter state
  int _tabIndex = 0; // 0 for Individual Performance, 1 for Team Comparison
  int _periodIndex = 0; // ALL, MTD, QTD, YTD
  int _metricIndex = 0; // Selected metric for comparison
  int _selectedProfileIndex = 0; // Default to 'All' profile
  String _selectedUserId = '';
  String _selectedType = 'All';

  bool isHideActivities = false;
  bool isHide = false;
  bool isHideCalls = false;
  // Data state
  bool isLoading = false;
  Map<String, dynamic> _teamData = {};
  Map<String, dynamic> _selectedUserData = {};
  List<Map<String, dynamic>> _teamMembers = [];

  // Activity lists
  List<Map<String, dynamic>> _upcomingFollowups = [];
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _upcomingTestDrives = [];

  // Controller for FAB
  final FabController fabController = Get.put(FabController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch team data using the new consolidated API
      await _fetchTeamDetails();
    } catch (error) {
      print("Error during initialization: $error");
      Get.snackbar(
        'Error',
        'Failed to load team data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fetch team details using the new API endpoint
  Future<void> _fetchTeamDetails() async {
    try {
      final token = await Storage.getToken();

      // Build query parameters based on current filters
      String? periodParam;
      switch (_periodIndex) {
        case 1:
          periodParam = 'MTD';
          break;
        case 2:
          periodParam = 'QTD';
          break;
        case 3:
          periodParam = 'YTD';
          break;
        default:
          periodParam = null;
      }

      final summaryMetrics = [
        'enquiries',
        'testdrives',
        'orders',
        'orders',
        'cancellation',
        'retail'
      ];
      final summaryParam = summaryMetrics[_metricIndex];

      // Build the URL with query parameters
      final queryParams = {
        // '': periodParam,
        if (periodParam != null) 'type': periodParam,
        if (_selectedUserId.isNotEmpty) 'user_id': _selectedUserId,
        'summary': summaryParam,
      };

      Uri uri;

      final baseUri = Uri.parse(
        'https://api.smartassistapp.in/api/users/sm/dashboard/team-dashboard',
      );

      if (queryParams.isEmpty) {
        uri = baseUri;
      } else {
        uri = baseUri.replace(queryParameters: queryParams);
      }

      print('📤 Fetching from: $uri');

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(response.body);
        print(uri);

        setState(() {
          _teamData = data['data'] ?? {};

          // ✅ Only reset if 'allMember' exists and is not empty
          if (_teamData.containsKey('allMember') &&
              _teamData['allMember'].isNotEmpty) {
            _teamMembers = [];

            for (var member in _teamData['allMember']) {
              _teamMembers.add({
                'fname': member['fname'] ?? '',
                'lname': member['lname'] ?? '',
                'user_id': member['user_id'] ?? '',
                'team_name': '',
              });
            }
          }

          // Set the selected user data
          if (_selectedProfileIndex == 0) {
            // All users data
            _selectedUserData = _teamData['summary'] ?? {};
          } else if (_selectedProfileIndex < _teamMembers.length) {
            // Specific user data
            final selectedMember = _teamMembers[_selectedProfileIndex];
            _selectedUserData = selectedMember;

            // Extract upcoming activities for the selected user
            final stats = selectedMember['stats'] ?? {};
            _upcomingFollowups = List<Map<String, dynamic>>.from(
                stats['UpComingFollowups'] ?? []);
            _upcomingAppointments = List<Map<String, dynamic>>.from(
                stats['UpComingAppointment'] ?? []);
            _upcomingTestDrives = List<Map<String, dynamic>>.from(
                stats['UpComingTestDrive'] ?? []);
          }
        });
      } else {
        throw Exception('Failed to fetch team details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching team details: $e');
      // rethrow;
    }
  }

  // Select a different user profile
  void _selectUserProfile(int index, String userId) {
    setState(() {
      _selectedProfileIndex = index;
      _selectedUserId = userId;
    });

    // Refresh data for the selected user
    _fetchTeamDetails();
  }

  // Helper method to get metric value for comparison
  int _getMetricValue(Map<String, dynamic> userData) {
    final stats = userData['stats'] ?? {};
    switch (_metricIndex) {
      case 0:
        return stats['Enquiries'] ?? 0;
      case 1:
        return stats['TestDrives'] ?? 0;
      case 2:
        return stats['Orders'] ?? 0;
      case 3:
        return stats['Orders'] ?? 0; // New Orders (using same field)
      case 4:
        return stats['Cancellation'] ?? 0;
      case 5:
        return stats['Retail'] ?? 0;
      default:
        return stats['Enquiries'] ?? 0;
    }
  }

  // Calculate team total by summing member metrics
  int _calculateTeamTotal(List<Map<String, dynamic>> members) {
    int total = 0;
    for (var member in members) {
      total += _getMetricValue(member);
    }
    return total;
  }

  // Process team data for team comparison display
  List<Map<String, dynamic>> _processTeamComparisonData() {
    List<Map<String, dynamic>> result = [];

    if (_teamData.containsKey('teams')) {
      for (var team in _teamData['teams']) {
        // Add team header
        final teamMembers =
            List<Map<String, dynamic>>.from(team['members'] ?? []);
        result.add({
          'name': team['team_name'] ?? 'Unnamed Team',
          'count': _calculateTeamTotal(teamMembers),
          'type': 'team'
        });

        // Add team members
        for (var member in teamMembers) {
          result.add({
            'name': '${member['fname']} ${member['lname']}',
            'count': _getMetricValue(member),
            'type': 'member'
          });
        }
      }
    }

    return result;
  }

  // Find maximum value for scaling in comparison chart
  int _findMaxValue(List<Map<String, dynamic>> items) {
    int max = 0;
    for (var item in items) {
      final count = item['count'] ?? 0;
      if (count > max) {
        max = count;
      }
    }
    return max > 0 ? max : 1; // Avoid division by zero
  }

  // Get gradient colors for progress bars
  List<Color> _getGradientForIndex(int index) {
    final gradients = [
      [const Color(0xFF4CAF50), const Color(0xFF8BC34A)], // Green
      [const Color(0xFF2196F3), const Color(0xFF03A9F4)], // Blue
      [const Color(0xFFFFEB3B), const Color(0xFFFFC107)], // Yellow
      [const Color(0xFFFF9800), const Color(0xFFFF5722)], // Orange
      [const Color(0xFFE91E63), const Color(0xFFF44336)], // Red
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text('My Team', style: AppFont.appbarfontWhite(context)),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            _buildProfileAvatarStaticsAll(
                              'All',
                              0,
                            ),
                            _buildProfileAvatars(),
                          ]),
                        ),
                        // Profile avatars (previously shown only for Individual Performance tab)

                        const SizedBox(height: 10),

                        // Individual Performance content
                        _buildIndividualPerformanceTab(context, screenWidth),

                        const SizedBox(height: 10),

                        // Team Comparison content
                        _buildTeamComparisonTab(context, screenWidth),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

          // Floating Action Button
          // Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: _buildFloatingActionButton(context),
          // ),

          // Popup Menu (Conditionally Rendered)
          // Obx(() => fabController.isFabExpanded.value
          //     ? _buildPopupMenu(context)
          //     : const SizedBox.shrink()),
        ],
      ),
    );
  }

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

  // Tab buttons for switching between Individual Performance and Team Comparison
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
              child: InkWell(
                onTap: () {
                  setState(() {
                    _tabIndex = 0;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _tabIndex == 0 ? Colors.blue : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Individual Performance',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _tabIndex == 0 ? Colors.blue : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Team Comparison Button
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _tabIndex = 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _tabIndex == 1 ? Colors.blue : Colors.transparent,
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
          ],
        ),
      ),
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
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 5, 0),
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

  // Profile avatars row
  // Widget _buildProfileAvatars() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Container(
  //       margin: const EdgeInsets.only(top: 10),
  //       height: 90,
  //       padding: const EdgeInsets.only(right: 10),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           for (int i = 1; i < _teamMembers.length; i++)
  //             _buildProfileAvatar(
  //               _teamMembers[i]['fname'] ?? '',
  //               i,
  //               _teamMembers[i]['user_id'] ?? '',
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildProfileAvatars() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < _teamMembers.length; i++)
              _buildProfileAvatar(
                _teamMembers[i]['fname'] ?? '',
                i + 1, // Starts from 1 because 0 is 'All'
                _teamMembers[i]['user_id'] ?? '',
              ),
          ],
        ),
      ),
    );
  }

  // Individual profile avatar
  Widget _buildProfileAvatar(String firstName, int index, String userId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          // onTap: () => _selectUserProfile(index, userId),
          onTap: () async {
            setState(() {
              _selectedProfileIndex = index;
              _selectedUserId = userId; // set selected userId
            });
            await _fetchTeamDetails(); // fetch updated data
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
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
      ],
    );
  }

  // Individual Performance Tab Content
  Widget _buildIndividualPerformanceTab(
      BuildContext context, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLightGrey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                _buildPeriodFilter(screenWidth),
                _buildIndividualPerformanceMetrics(context),

                // for upcoming
                if (_selectedType != 'All') ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 10, bottom: 0),
                              child: Text(
                                'Activities',
                                style: AppFont.dropDowmLabel(context),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isHideActivities = !isHideActivities;
                                });
                              },
                              icon: Icon(
                                isHideActivities
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
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
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(top: 10),
                        child: _buildUpcomingActivities(context)),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(left: 10, bottom: 0),
                              child: Text(
                                'Call Analysis',
                                style: AppFont.dropDowmLabel(context),
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
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                size: 35,
                                color: AppColors.iconGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // if (!isHideCalls) ...[
                  //   Container(
                  //       decoration: BoxDecoration(
                  //           color: AppColors.backgroundLightGrey,
                  //           borderRadius: BorderRadius.circular(10)),
                  //       margin: const EdgeInsets.only(top: 10),
                  //       child: _callLogsWidget(context)),
                  // ],
                ],
              ],
            ),
          ),
          if (_selectedType != 'All') ...[
            // _buildUpcomingActivities(context),
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, bottom: 0),
                        child: Text(
                          'Activities',
                          style: AppFont.dropDowmLabel(context),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isHideActivities = !isHideActivities;
                          });
                        },
                        icon: Icon(
                          isHideActivities
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
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
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(top: 10),
                  child: _buildUpcomingActivities(context)),
            ]
          ]
        ],
      ),
    );
  }

  // Team Comparison Tab Content
  Widget _buildTeamComparisonTab(BuildContext context, double screenWidth) {
    return Column(
      children: [
        // _buildPeriodFilter(screenWidth),
        // _buildMetricButtons(),
        _buildTeamComparisonChart(context),
      ],
    );
  }

  // Period filter (ALL, MTD, QTD, YTD)
  Widget _buildPeriodFilter(double screenWidth) {
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
          _fetchTeamDetails();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
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

  // Metric selection buttons for Team Comparison
  Widget _buildMetricButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          _buildMetricButton('Enquiriess', 0),
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

  // Individual Performance Metrics Display
  Widget _buildIndividualPerformanceMetrics(BuildContext context) {
    final stats = _selectedUserData['totalPerformance'] ?? {};
    final metrics = [
      {'label': 'Enquiries', 'key': 'enquiries'},
      {'label': 'Test Drive\nDone', 'key': 'testDrives'},
      {'label': 'Order Taken', 'key': 'orders'},
      {'label': 'Cancellations', 'key': 'cancellation'},
      {
        'label': 'Net Orders',
        'value': (stats['Orders'] ?? 0) - (stats['cancellation'] ?? 0)
      },
      {'label': 'Retails', 'key': 'retail'},
    ];

    List<Widget> rows = [];
    for (int i = 0; i < metrics.length; i += 2) {
      rows.add(
        Row(
          children: [
            for (int j = i; j < i + 2 && j < metrics.length; j++) ...[
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _metricIndex = j;
                      _fetchTeamDetails(); // Refresh data with new metric
                    });
                  },
                  child: _buildMetricCard(
                    "${metrics[j].containsKey('value') ? metrics[j]['value'] : stats[metrics[j]['key']] ?? 0}",
                    metrics[j]['label']!,
                    Colors.blue,
                    isSelected: _metricIndex == j,
                  ),
                ),
              ),
              if (j % 2 == 0) const SizedBox(width: 12),
            ],
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  // Team Comparison Chart
  Widget _buildTeamComparisonChart(BuildContext context) {
    final displayItems = _processTeamComparisonData();
    final maxValue = _findMaxValue(displayItems);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          if (_selectedType != 'dynamic') ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, bottom: 0),
                        child: Text(
                          'Team Comparison',
                          style: AppFont.dropDowmLabel(context),
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
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
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
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Show "Target" label

                    const Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 16.0),
                      child: Text(
                        "Target",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Display all items with progress bars
                    Container(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          final count = item['count'] ?? 0;
                          final percentage =
                              maxValue > 0 ? count / maxValue : 0.0;
                          final isTeam = item['type'] == 'team';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                // Name with proper indentation for team members
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    item['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: isTeam
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Progress bar
                                Expanded(
                                  child: LinearPercentIndicator(
                                    percent: percentage.clamp(0.0, 1.0),
                                    lineHeight: 20.0,
                                    barRadius: const Radius.circular(10),
                                    backgroundColor: Colors.grey[200],
                                    linearGradient: LinearGradient(
                                      colors: _getGradientForIndex(index),
                                    ),
                                    padding: const EdgeInsets.only(right: 10),
                                  ),
                                ),

                                // Count value
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Individual metric card
  Widget _buildMetricCard(
    String value,
    String label,
    Color valueColor, {
    bool isSelected = false,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return Container(
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
    );
  }

  // Upcoming Activities Section
  Widget _buildUpcomingActivities(BuildContext context) {
    // Only show if we have data and not in "All" view
    if (_selectedProfileIndex == 0 ||
        (_upcomingFollowups.isEmpty &&
            _upcomingAppointments.isEmpty &&
            _upcomingTestDrives.isEmpty)) {
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

  // Activity section builder
  Widget _buildActivitySection(
      BuildContext context, List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: _buildActivityCard(
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

  // Individual activity card
  Widget _buildActivityCard(
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
                      // if (vehicle.isNotEmpty) _buildVerticalDivider(15),
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
                      // _formatDate(context, date),
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
}

class _buildVerticalDivider {
  _buildVerticalDivider(int i);
}

// class FlexibleButton extends StatelessWidget {
//   final String title;
//   final VoidCallback onPressed;
//   final BoxDecoration decoration;
//   final TextStyle textStyle;

//   const FlexibleButton(
//       {super.key,
//       required this.title,
//       required this.onPressed,
//       required this.decoration,
//       required this.textStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//       height: 30,
//       decoration: decoration,
//       child: TextButton(
//         style: TextButton.styleFrom(
//           backgroundColor: Color(0xffF3F9FF),
//           padding: EdgeInsets.symmetric(
//             horizontal: 10,
//           ),
//           minimumSize: const Size(0, 0),
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         ),
//         onPressed: onPressed,
//         child: Text(
//           title,
//           style: textStyle,
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

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
