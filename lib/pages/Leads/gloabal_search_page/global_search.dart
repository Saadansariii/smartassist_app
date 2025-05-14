// import 'package:flutter/material.dart';

// class GlobalSearch extends StatefulWidget {
//   const GlobalSearch({super.key});

//   @override
//   State<GlobalSearch> createState() => _GlobalSearchState();
// }

// class _GlobalSearchState extends State<GlobalSearch> {

// // Search Functionality
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> _searchResults = [];
//   bool _isLoadingSearch = false;
//   String _query = '';

//    @override
//   void initState() {
//     super.initState();
//     // fetchDashboardData();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//    Future<void> _fetchSearchResults(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults.clear();
//       });
//       return;
//     }

//     setState(() {
//       _isLoadingSearch = true;
//     });

//     final token = await Storage.getToken();

//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://dev.smartassistapp.in/api/search/global?query=$query'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _searchResults = data['suggestions'] ?? [];
//         });
//       }
//     } catch (e) {
//       showErrorMessage(context, message: 'Something went wrong..!');
//     } finally {
//       setState(() {
//         _isLoadingSearch = false;
//       });
//     }
//   }

//   void _onSearchChanged() {
//     final newQuery = _searchController.text.trim();
//     if (newQuery == _query) return;

//     _query = newQuery;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (_query == _searchController.text.trim()) {
//         _fetchSearchResults(_query);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Global Search'),
//       ),
//       body: SingleChildScrollView(
//         keyboardDismissBehavior:
//                             ScrollViewKeyboardDismissBehavior.onDrag,
//         child: Column(

//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/home/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/home/single_id_screens/single_leads.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/utils/storage.dart';

class GlobalSearch extends StatefulWidget {
  const GlobalSearch({super.key});

  @override
  State<GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<GlobalSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoadingSearch = false;
  String _query = '';
  bool _isErrorShowing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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

    try {
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/search/global?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = data['data']['suggestions'] ?? [];
          _isErrorShowing = false;
        });
      } else {
        // showErrorMessage(context, message: data['message']);
        // Get.snackbar('Error', data['message'].toString());
        if (!_isErrorShowing) {
          setState(() {
            _isErrorShowing = true;
          });
          Get.snackbar(
            'Error',
            data['message'].toString(),
            duration: Duration(seconds: 3),
            onTap: (_) {
              setState(() {
                _isErrorShowing = false;
              });
            },
            isDismissible: true,
          );
        }
      }
    } catch (e) {
      showErrorMessage(context, message: 'Something went wrong..!');
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

    // Also clear error status when user changes search text
    if (_isErrorShowing) {
      setState(() {
        _isErrorShowing = false;
      });
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_query == _searchController.text.trim()) {
        _fetchSearchResults(_query);
      }
    });
  }

  // void _onSearchChanged() {
  //   final newQuery = _searchController.text.trim();
  //   if (newQuery == _query) return;

  //   _query = newQuery;
  //   Future.delayed(const Duration(milliseconds: 1500), () {
  //     if (_query == _searchController.text.trim()) {
  //       _fetchSearchResults(_query);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10, // Removes default space between leading and title
        leadingWidth: 40, // Reduce width of leading to keep it compact
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            icon: const Icon(
              Icons.close,
              size: 30,
              // weight: Double(),
              weight: 100,
            ),
            onPressed: () => Get.back(),
          ),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min, // Prevents unnecessary extra space
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  .8, // Adjust width as needed
              height: MediaQuery.of(context).size.height * .05,
              child: TextField(
                autofocus: true,
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15), // Reduce padding
                  filled: true,
                  fillColor: AppColors.searchBar,
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 8), // Reduce icon padding
                    child: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: AppColors.fontColor,
                      size: 15,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingSearch
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Center(
                      child: Text("No Matching Record found...!",
                          style: AppFont.dropDowmLabel(context))),
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      onTap: () {
                        Get.to(
                            () => FollowupsDetails(leadId: result['lead_id']));
                      },
                      title: Row(
                        children: [
                          Text(
                            result['lead_name'] ?? 'No Name',
                            style: AppFont.dropDowmLabel(context),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          // Divider Replacement: A Thin Line
                          Container(
                            width: .5, // Set width for the divider
                            height: 15, // Make it a thin horizontal line
                            color: Colors.black,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            result['PMI'] ?? 'Discovery Sport',
                            style: AppFont.tinytext(context),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        result['email'] ?? 'No Email',
                        style: AppFont.smallText(context),
                      ),
                      leading: Container(
                          decoration: const BoxDecoration(
                              color: AppColors.containerBg,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.trending_up,
                              color: AppColors.iconGrey,
                            ),
                          )),
                    );
                  },
                ),
    );
  }
}
