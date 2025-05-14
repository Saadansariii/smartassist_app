import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/config/getX/fab.controller.dart';
import 'package:smart_assist/pages/home/gloabal_search_page/global_search.dart';
import 'package:smart_assist/pages/navbar_page/app_setting.dart';
import 'package:smart_assist/pages/navbar_page/call_logs.dart';
import 'package:smart_assist/pages/navbar_page/favorite.dart';
import 'package:smart_assist/pages/navbar_page/leads_all.dart';
import 'package:smart_assist/pages/navbar_page/logout_page.dart';
import 'package:smart_assist/pages/navbar_page/my_teams.dart';
import 'package:smart_assist/pages/notification/notification.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/home_btn.dart/bottom_btn_third.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/appointment_popup.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_Followups_popups.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_leads.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_testDrive.dart';
import 'package:smart_assist/widgets/home_btn.dart/threeBtn_second_leads.dart';
import 'package:smart_assist/widgets/home_btn.dart/threebtn.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/widgets/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String greeting;
  final String leadId;

  const HomeScreen({
    super.key,
    required this.greeting,
    required this.leadId,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? leadId;
  bool _isHidden = false;
  String greeting = '';
  String name = '';
  int notificationCount = 0;
  int overdueFollowupsCount = 0;
  int overdueAppointmentsCount = 0;
  int overdueTestDrivesCount = 0;
  List<dynamic> upcomingFollowups = [];
  List<dynamic> overdueFollowups = [];
  List<dynamic> upcomingAppointments = [];
  List<dynamic> overdueAppointments = [];
  List<dynamic> upcomingTestDrives = [];
  List<dynamic> overdueTestDrives = [];
  bool isDashboardLoading = false;
  String? teamRole;
  Map<String, dynamic> MtdData = {};
  Map<String, dynamic> QtdData = {};
  Map<String, dynamic> YtdData = {};

  // Search Functionality
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoadingSearch = false;
  // final NavigationController controller = Get.put(NavigationController());
  String _query = '';

  // Initialize the controller
  final FabController fabController = Get.put(FabController());

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _searchController.addListener(_onSearchChanged);
    _loadDashboardAnalytics();
    _loadTeamRole();
    print(_loadTeamRole());
  }

  Future<void> _loadDashboardAnalytics() async {
    setState(() {
      isDashboardLoading = true;
    });
    try {
      final data = await LeadsSrv.fetchDashboardAnalytics();
      setState(() {
        MtdData = data['MTD'] ?? {};
        QtdData = data['QTD'] ?? {};
        YtdData = data['YTD'] ?? {};
      });
    } catch (e) {
      print("Error loading analytics: $e");
    }
  }

  Future<void> _loadTeamRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teamRole = prefs.getString('USER_ROLE');
    });
    // Print all relevant keys
    print('USER_ROLE value: ${prefs.getString('USER_ROLE')}');
    print('All keys: ${prefs.getKeys()}');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isDashboardLoading = true;
    });
    try {
      final data = await LeadsSrv.fetchDashboardData();
      if (mounted) {
        setState(() {
          upcomingFollowups = data['upcomingFollowups'];
          overdueFollowups = data['overdueFollowups'];
          upcomingAppointments = data['upcomingAppointments'];
          overdueAppointments = data['overdueAppointments'];
          upcomingTestDrives = data['upcomingTestDrives'];
          overdueTestDrives = data['overdueTestDrives'];
          overdueFollowupsCount = data.containsKey('overdueFollowupsCount') &&
                  data['overdueFollowupsCount'] is int
              ? data['overdueFollowupsCount']
              : 0;

          overdueAppointmentsCount =
              data.containsKey('overdueAppointmentsCount') &&
                      data['overdueAppointmentsCount'] is int
                  ? data['overdueAppointmentsCount']
                  : 0;

          overdueTestDrivesCount = data.containsKey('overdueTestDrivesCount') &&
                  data['overdueTestDrivesCount'] is int
              ? data['overdueTestDrivesCount']
              : 0;

          notificationCount =
              data.containsKey('notifications') && data['notifications'] is int
                  ? data['notifications']
                  : 0;
          greeting =
              (data.containsKey('greetings') && data['greetings'] is String)
                  ? data['greetings']
                  : 'Welcome!';
          name = (data.containsKey('initials') &&
                  data['initials'] is String &&
                  data['initials'].trim().isNotEmpty)
              ? data['initials'].trim()
              : '';

          // if (upcomingFollowups.isNotEmpty) {
          //   leadId = upcomingFollowups[0]['lead_id'];
          // }
        });
      }
    } catch (e) {
      print(e);
      // showErrorMessage(context, message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isDashboardLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
    });

    final token = await Storage.getToken();

    try {
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/search/global?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data['suggestions'] ?? [];
        });
      }
    } catch (e) {
      // showErrorMessage(context, message: 'Something went wrong..!');
      print(e);
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text.trim();
    if (newQuery == _query) return;

    _query = newQuery;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_query == _searchController.text.trim()) {
        _fetchSearchResults(_query);
      }
    });
  }

  // String? teamRole = await SharedPreferences.getInstance()
  // .then((prefs) => prefs.getString('USER_ROLE'));

  void _showAppointmentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // Remove default padding
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppointmentPopup(
              onFormSubmit: fetchDashboardData,
            ), // Appointment modal
          ),
        );
      },
    );
  }

  void _showTestdrivePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero, // Remove default padding
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateTestdrive(
              onFormSubmit: fetchDashboardData,
            ), // Appointment modal
          ),
        );
      },
    );
  }

  void _showLeadPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
                horizontal: 16), // Add some margin for better UX
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateLeads(
              onFormSubmit: fetchDashboardData,
            ),
          ),
        );
      },
    );
  }

  String _getFirstTwoLettersCapitalized(String input) {
    input = input.trim(); // Remove any extra spaces
    if (input.length >= 1) {
      return input.substring(0, 1).toUpperCase();
    } else if (input.isNotEmpty) {
      return input.toUpperCase();
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1380FE),
            title: Text(
              ' $greeting',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    color: Colors.white,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: AppColors.sideRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                          maxWidth: 20,
                          maxHeight: 20,
                        ),
                        child: Text(
                          notificationCount.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
          body: Stack(children: [
            SafeArea(
              child: RefreshIndicator(
                onRefresh: fetchDashboardData,
                child: isDashboardLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          children: [
                            // const SizedBox(height: 5),

                            /// ✅ Row with Menu, Search Bar, and Microphone
                            Row(
                              children: [
                                // Container(
                                //   width: 40,
                                //   height: 40,
                                //   padding: const EdgeInsets.symmetric(
                                //       vertical: 0, horizontal: 0),
                                //   margin: const EdgeInsets.all(8),
                                //   decoration: BoxDecoration(
                                //       // shape: BoxShape.circle,
                                //       color: AppColors.backgroundLightGrey,
                                //       borderRadius: BorderRadius.circular(30)),
                                //   child: TextButton(
                                //     style: const ButtonStyle(
                                //       minimumSize:
                                //           WidgetStatePropertyAll(Size.zero),
                                //       tapTargetSize:
                                //           MaterialTapTargetSize.shrinkWrap,
                                //       padding: WidgetStatePropertyAll(
                                //           EdgeInsets.zero),
                                //     ),
                                //     onPressed: () {
                                //       Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (context) =>
                                //                   const ProfileScreen()));
                                //     },
                                //     child: Text(
                                //       name.isNotEmpty ? name : 'NA',
                                //       style:
                                //           AppFont.mediumText14bluebold(context),
                                //     ),
                                //   ),
                                // ),

                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: SizedBox(
                                      height: 35,
                                      child: TextField(
                                        readOnly: true,
                                        onTap: () {
                                          Get.to(() => const GlobalSearch());
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          filled: true,
                                          fillColor: AppColors.containerBg,
                                          hintText: 'Search',
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.fontColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          prefixIcon: const Icon(
                                            FontAwesomeIcons.magnifyingGlass,
                                            color: AppColors.iconGrey,
                                            size: 15,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileScreen(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .backgroundLightGrey,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  name.isNotEmpty
                                                      ? name.toUpperCase()
                                                      : 'N',
                                                  style: AppFont
                                                      .mediumText14bluebold(
                                                          context),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            /// ✅ Other UI Components (Follow-ups, Buttons, etc.)
                            // const SizedBox(height: 3),
                            Threebtn(
                              leadId: leadId ?? 'empty',
                              upcomingFollowups: upcomingFollowups,
                              overdueFollowups: overdueFollowups,
                              upcomingAppointments: upcomingAppointments,
                              overdueAppointments: overdueAppointments,
                              upcomingTestDrives: upcomingTestDrives,
                              overdueTestDrives: overdueTestDrives,
                              refreshDashboard: fetchDashboardData,
                              overdueFollowupsCount: overdueFollowupsCount,
                              overdueAppointmentsCount:
                                  overdueAppointmentsCount,
                              overdueTestDrivesCount: overdueTestDrivesCount,
                            ),
                            const BottomBtnSecond(
                                // MtdData: MtdData,
                                // QtdData: QtdData,
                                // YtdData: YtdData,
                                ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Performance analysis',
                                    style: AppFont.appbarfontgrey(context),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isHidden = !_isHidden;
                                        });
                                      },
                                      child: Text(
                                        _isHidden ? 'Show' : 'Hide',
                                        style: AppFont.smallText(context),
                                      ))
                                ],
                              ),
                            ),
                            if (!_isHidden) ...[
                              const BottomBtnThird(),
                            ],

                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
              ),
            ),

            Positioned(
              bottom: 26,
              right: 18,
              child: _buildFloatingActionButton(context),
            ),

            // Popup Menu (Conditionally Rendered)
            Obx(() => fabController.isFabExpanded.value
                ? _buildPopupMenu(context)
                : const SizedBox.shrink()),
          ]),
        ),
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
                  _buildPopupItem(
                      Icons.calendar_month_outlined, "Appointment", -80,
                      onTap: () {
                    fabController.closeFab();
                    _showAppointmentPopup(context);
                  }),
                  _buildPopupItem(Icons.people_alt_rounded, "Enquiry", -60,
                      onTap: () {
                    fabController.closeFab();
                    _showLeadPopup(context);
                  }),
                  _buildPopupItem(Icons.call, "Followup", -40, onTap: () {
                    fabController.closeFab();
                    _showFollowupPopup(context);
                  }),
                  _buildPopupItem(Icons.directions_car, "Test Drive", -20,
                      onTap: () {
                    fabController.closeFab();
                    _showTestdrivePopup(context);
                  }),
                ],
              ),
            ),
          ),

          // ✅ FAB positioned above the overlay
          Positioned(
            bottom: 26,
            right: 18,
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

  void _showFollowupPopup(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CreateFollowupsPopups(
              onFormSubmit: fetchDashboardData, // Pass the function here
            ),
          ),
        );
      },
    );
  }

// ✅ Function to Show `CreateFollowupsPopups` on "Lead"
// void _showFollowupPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.zero,
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           margin: const EdgeInsets.symmetric(
//               horizontal: 16), // Add some margin for better UX
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const CreateFollowupsPopups(),
//         ),
//       );
//     },

//   );
// }

// ✅ Function to Show `CreateFollowupsPopups` on "Lead"
}
