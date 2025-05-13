import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/followups/overdue_followup.dart';
import 'package:smart_assist/widgets/followups/upcoming_row.dart';
import 'package:smart_assist/widgets/home_btn.dart/dashboard_popups/create_Followups_popups.dart';

class AddFollowups extends StatefulWidget {
  const AddFollowups({super.key});

  @override
  State<AddFollowups> createState() => _AddFollowupsState();
}

class _AddFollowupsState extends State<AddFollowups> {
  final Widget _createFollowups = CreateFollowupsPopups(
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
      const String apiUrl = "https://dev.smartassistapp.in/api/tasks/all-tasks";

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
          _originalAllTasks = data['data']['allTasks']?['rows'] ?? [];
          _originalUpcomingTasks =
              data['data']['upcomingWeekTasks']?['rows'] ?? [];
          _originalOverdueTasks =
              data['data']['overdueWeekTasks']?['rows'] ?? [];
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
          'All Followups',
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
                    child: _createFollowups, // Your follow-up widget
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
                      fillColor: const Color(0xFFE1EFFF),
                      contentPadding: const EdgeInsets.fromLTRB(1, 4, 0, 4),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
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
                ),
              ],
            ),
          ),

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
                              child: Text("No Followups available"),
                            ),
                          )
                        : Column(
                            children: [
                              if (_filteredUpcomingTasks.isNotEmpty)
                                FollowupsUpcoming(
                                  upcomingFollowups: _filteredUpcomingTasks,
                                  isNested: true,
                                ),
                              if (_filteredOverdueTasks.isNotEmpty)
                                OverdueFollowup(
                                  overdueeFollowups: _filteredOverdueTasks,
                                  isNested: true,
                                ),
                            ],
                          )
                    : _upcommingButtonIndex == 1
                        ? FollowupsUpcoming(
                            upcomingFollowups: _filteredUpcomingTasks,
                            isNested: true,
                          )
                        : OverdueFollowup(
                            overdueeFollowups: _filteredOverdueTasks,
                            isNested: true,
                          ),
          ),
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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:smart_assist/utils/bottom_navigation.dart';
// import 'package:smart_assist/utils/storage.dart';
// import 'package:smart_assist/widgets/followups/overdue_followup.dart';
// import 'package:smart_assist/widgets/followups/upcoming_row.dart';
// import 'package:smart_assist/widgets/home_btn.dart/popups_model/create_followups/create_Followups_popups.dart';

// class AddFollowups extends StatefulWidget {
//   // final String leadId;
//   const AddFollowups({
//     super.key,
//     // required this.leadId,
//   });

//   @override
//   State<AddFollowups> createState() => _AddFollowupsState();
// }

// class _AddFollowupsState extends State<AddFollowups> {
//   final Widget _createFollowups = const CreateFollowupsPopups();
//   List<dynamic> _originalAllTasks = [];
//   List<dynamic> _originalUpcomingTasks = [];
//   List<dynamic> _originalOverdueTasks = [];
//   List<dynamic> _filteredAllTasks = [];
//   List<dynamic> _filteredUpcomingTasks = [];
//   List<dynamic> _filteredOverdueTasks = [];
//   int _upcommingButtonIndex = 0;
//   TextEditingController searchController = TextEditingController();
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchTasks();
//   }

//   Future<void> fetchTasks() async {
//     setState(() => _isLoading = true);
//     try {
//       final token = await Storage.getToken();
//       const String apiUrl = "https://dev.smartassistapp.in/api/tasks/all-tasks";

//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _originalAllTasks = data['allTasks']?['rows'] ?? [];
//           _originalUpcomingTasks = data['upcomingTasks']?['rows'] ?? [];
//           _originalOverdueTasks = data['overdueTasks']?['rows'] ?? [];
//           _filteredAllTasks = List.from(_originalAllTasks);
//           _filteredUpcomingTasks = List.from(_originalUpcomingTasks);
//           _filteredOverdueTasks = List.from(_originalOverdueTasks);
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _filterTasks(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredAllTasks = List.from(_originalAllTasks);
//         _filteredUpcomingTasks = List.from(_originalUpcomingTasks);
//         _filteredOverdueTasks = List.from(_originalOverdueTasks);
//       } else {
//         final lowercaseQuery = query.toLowerCase();
//         void filterList(List<dynamic> original, List<dynamic> filtered) {
//           filtered.clear();
//           filtered.addAll(original.where((task) =>
//               task['name'].toString().toLowerCase().contains(lowercaseQuery) ||
//               task['subject']
//                   .toString()
//                   .toLowerCase()
//                   .contains(lowercaseQuery)));
//         }

//         filterList(_originalAllTasks, _filteredAllTasks);
//         filterList(_originalUpcomingTasks, _filteredUpcomingTasks);
//         filterList(_originalOverdueTasks, _filteredOverdueTasks);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => BottomNavigation()),
//           ),
//           icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
//         ),
//         backgroundColor: Colors.blue,
//         title: const Text(
//           'All Followups',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return Dialog(
//                     insetPadding: EdgeInsets.symmetric(horizontal: 10),
//                     backgroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: _createFollowups, // Your follow-up widget
//                   );
//                 },
//               );
//             },
//             icon: const Icon(Icons.add, color: Colors.white, size: 36),
//           ),
//         ],
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                   child: TextField(
//                     controller: searchController,
//                     onChanged: _filterTasks,
//                     decoration: InputDecoration(
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFFE1EFFF),
//                       contentPadding: const EdgeInsets.fromLTRB(1, 4, 0, 4),
//                       border: InputBorder.none,
//                       hintText: 'Search',
//                       hintStyle: const TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       suffixIcon: const Icon(Icons.mic, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 20),
//                       Container(
//                         width: 250,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: const Color(0xFF767676),
//                             width: .5,
//                           ),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Row(
//                           children: [
//                             _buildFilterButton(
//                               index: 0,
//                               text: 'All',
//                               activeColor:
//                                   const Color.fromARGB(255, 81, 109, 121),
//                             ),
//                             _buildFilterButton(
//                               index: 1,
//                               text: 'Upcoming',
//                               activeColor:
//                                   const Color.fromARGB(255, 81, 223, 121),
//                             ),
//                             _buildFilterButton(
//                               index: 2,
//                               text: 'Overdue',
//                               activeColor: const Color.fromRGBO(238, 59, 59, 1),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SliverFillRemaining(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _upcommingButtonIndex == 0
//                     ? Column(
//                         children: [
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   FollowupsUpcoming(
//                                     upcomingFollowups: _filteredUpcomingTasks,
//                                   ),
//                                   OverdueFollowup(
//                                     overdueeFollowups: _filteredOverdueTasks,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     : _upcommingButtonIndex == 1
//                         ? FollowupsUpcoming(
//                             upcomingFollowups: _filteredUpcomingTasks,
//                           )
//                         : OverdueFollowup(
//                             overdueeFollowups: _filteredOverdueTasks,
//                           ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterButton({
//     required int index,
//     required String text,
//     required Color activeColor,
//   }) {
//     return Expanded(
//       child: TextButton(
//         onPressed: () => setState(() => _upcommingButtonIndex = index),
//         style: TextButton.styleFrom(
//           backgroundColor: _upcommingButtonIndex == index
//               // ignore: deprecated_member_use
//               ? activeColor.withOpacity(0.29)
//               : null,
//           foregroundColor:
//               _upcommingButtonIndex == index ? Colors.blueGrey : Colors.black,
//           padding: const EdgeInsets.symmetric(vertical: 5),
//           side: BorderSide(
//             color: _upcommingButtonIndex == index
//                 ? activeColor
//                 : Colors.transparent,
//             width: .5,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w400,
//             color: Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }
// }
