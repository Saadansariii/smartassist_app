import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/appointment_popup.dart';
import 'package:smart_assist/widgets/oppointment/overdue.dart';
import 'package:smart_assist/widgets/oppointment/upcoming.dart';

class AllAppointment extends StatefulWidget {
  const AllAppointment({super.key});

  @override
  State<AllAppointment> createState() => _AllAppointmentState();
}

class _AllAppointmentState extends State<AllAppointment> {
  final Widget _createAppoinment = AppointmentPopup(
    onFormSubmit: () {},
  );
  List<dynamic> _originalAllTasks = [];
  List<dynamic> _originalUpcomingTasks = [];
  List<dynamic> _originalOverdueTasks = [];
  List<dynamic> _filteredAllTasks = [];
  List<dynamic> _filteredUpcomingTasks = [];
  List<dynamic> _filteredOverdueTasks = [];
  int _upcommingButtonIndex = 0;
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final token = await Storage.getToken();
      const String apiUrl =
          "https://dev.smartassistapp.in/api/events/all-events";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('thisi si sht eurl ');
      print(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          print(data);
          print('helloee');
          _originalAllTasks = data['data']['allEvents']?['rows'] ?? [];
          _originalUpcomingTasks =
              data['data']['upcomingEvents']?['rows'] ?? [];
          _originalOverdueTasks = data['data']['overdueEvents']?['rows'] ?? [];
          _filteredAllTasks = List.from(_originalAllTasks);
          _filteredUpcomingTasks = List.from(_originalUpcomingTasks);
          _filteredOverdueTasks = List.from(_originalOverdueTasks);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAllTasks = List.from(_originalAllTasks);
        _filteredUpcomingTasks = List.from(_originalUpcomingTasks);
        _filteredOverdueTasks = List.from(_originalOverdueTasks);
      } else {
        final lowercaseQuery = query.toLowerCase();
        void filterList(List<dynamic> original, List<dynamic> filtered) {
          filtered.clear();
          filtered.addAll(original.where((task) =>
              task['name'].toString().toLowerCase().contains(lowercaseQuery) ||
              task['subject']
                  .toString()
                  .toLowerCase()
                  .contains(lowercaseQuery)));
        }

        filterList(_originalAllTasks, _filteredAllTasks);
        filterList(_originalUpcomingTasks, _filteredUpcomingTasks);
        filterList(_originalOverdueTasks, _filteredOverdueTasks);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigation()),
          ),
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        title: const Text(
          'All Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _createAppoinment, // Your follow-up widget
                  );
                },
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 36),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Top section with search bar and filter buttons.
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterTasks,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.searchBar,
                      contentPadding: const EdgeInsets.fromLTRB(1, 1, 0, 1),
                      border: InputBorder.none,
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      width: 250,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF767676),
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          _buildFilterButton(
                            index: 0,
                            text: 'All',
                            activeColor:
                                const Color.fromARGB(255, 159, 174, 239),
                          ),
                          _buildFilterButton(
                            index: 1,
                            text: 'Upcoming',
                            activeColor:
                                const Color.fromARGB(255, 81, 223, 121),
                          ),
                          _buildFilterButton(
                            index: 2,
                            text: 'Overdue',
                            activeColor: const Color.fromRGBO(238, 59, 59, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main content: for "All", show both sections in one scroll;
          // for "Upcoming" or "Overdue", show just that section.
          // SliverToBoxAdapter(
          //   child: _isLoading
          //       ? const Center(
          //           child: CircularProgressIndicator(
          //           color: AppColors.colorsBlue,
          //         ))
          //       : _upcommingButtonIndex == 0
          //           ? Column(
          //               children: [
          //                 OppUpcoming(
          //                   upcomingOpp: _filteredUpcomingTasks,
          //                   isNested: true,
          //                 ),
          //                 OppOverdue(
          //                   overdueeOpp: _filteredOverdueTasks,
          //                   isNested: true,
          //                 ),
          //               ],
          //             )
          //           : _upcommingButtonIndex == 1
          //               ? OppUpcoming(
          //                   upcomingOpp: _filteredUpcomingTasks,
          //                   isNested: false,
          //                 )
          //               : OppOverdue(
          //                   overdueeOpp: _filteredOverdueTasks,
          //                   isNested: false,
          //                 ),
          // ),

          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.colorsBlue))
                : _upcommingButtonIndex == 0
                    ? (_filteredUpcomingTasks.isEmpty &&
                            _filteredOverdueTasks.isEmpty)
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text("No appointments available"),
                            ),
                          )
                        : Column(
                            children: [
                              if (_filteredUpcomingTasks.isNotEmpty)
                                OppUpcoming(
                                  upcomingOpp: _filteredUpcomingTasks,
                                  isNested: true,
                                ),
                              if (_filteredOverdueTasks.isNotEmpty)
                                OppOverdue(
                                  overdueeOpp: _filteredOverdueTasks,
                                  isNested: true,
                                ),
                            ],
                          )
                    : _upcommingButtonIndex == 1
                        ? OppUpcoming(
                            upcomingOpp: _filteredUpcomingTasks,
                            isNested: true,
                          )
                        : OppOverdue(
                            overdueeOpp: _filteredOverdueTasks,
                            isNested: true,
                          ),
          ),

          // SliverToBoxAdapter(
          //   child: _isLoading
          //       ? const Center(
          //           child:
          //               CircularProgressIndicator(color: AppColors.colorsBlue))
          //       : _upcommingButtonIndex == 0
          //           ? Column(
          //               children: [
          //                 if (_filteredUpcomingTasks.isNotEmpty)
          //                   OppUpcoming(
          //                     upcomingOpp: _filteredUpcomingTasks,
          //                     isNested: true,
          //                   ),
          //                 if (_filteredOverdueTasks.isNotEmpty)
          //                   OppOverdue(
          //                     overdueeOpp: _filteredOverdueTasks,
          //                     isNested: true,
          //                   ),
          //               ],
          //             )
          //           : _upcommingButtonIndex == 1
          //               ? OppUpcoming(
          //                   upcomingOpp: _filteredUpcomingTasks,
          //                   isNested: false,
          //                 )
          //               : OppOverdue(
          //                   overdueeOpp: _filteredOverdueTasks,
          //                   isNested: false,
          //                 ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required int index,
    required String text,
    required Color activeColor,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _upcommingButtonIndex = index),
        style: TextButton.styleFrom(
          backgroundColor: _upcommingButtonIndex == index
              ? activeColor.withOpacity(0.29)
              : null,
          foregroundColor:
              _upcommingButtonIndex == index ? Colors.blueGrey : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 5),
          side: BorderSide(
            color: _upcommingButtonIndex == index
                ? activeColor
                : Colors.transparent,
            width: .5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
