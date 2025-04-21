// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/font/font.dart';

// class BottomBtnThird extends StatefulWidget {
//   const BottomBtnThird({super.key});

//   @override
//   State<BottomBtnThird> createState() => _BottomBtnThirdState();
// }

// class _BottomBtnThirdState extends State<BottomBtnThird> {
//   int _childButtonIndex = 0;

//   // Define data for different time periods
//   final Map<int, List<List<String>>> timeData = {
//     0: [
//       // MTD data
//       ['Enquiries', '02', '42', '42', '42'],
//       ['Lost enquiries', '06', '23', '23', '23'],
//       ['Test drive', '01', '15', '15', '15'],
//       ['New orders', '04', '2', '2', '2'],
//       ['Cancellations', '02', '7', '7', '7'],
//       ['Net orders', '04', '2', '2', '2'],
//       ['Retails', '02', '7', '7', '7'],
//     ],
//     1: [
//       // QTD data
//       ['Enquiries', '12', '95', '98', '110'],
//       ['Test drives', '18', '56', '62', '75'],
//       ['New Orders', '05', '37', '42', '48'],
//       ['Cancellations', '09', '5', '4', '3'],
//       ['Retail', '08', '22', '28', '32'],
//       ['Cancellations', '04', '2', '2', '2'],
//       ['Retail', '02', '7', '7', '7'],
//     ],
//     2: [
//       // YTD data
//       ['Enquiries', '45', '220', '238', '256'],
//       ['Test drives', '32', '121', '145', '165'],
//       ['New Orders', '16', '92', '105', '119'],
//       ['Cancellations', '12', '15', '12', '8'],
//       ['Retail', '23', '84', '95', '105'],
//       ['Cancellations', '04', '2', '2', '2'],
//       ['Retail', '02', '7', '7', '7'],
//     ],
//   };

//   // Get current data based on selected button
//   List<List<String>>? get currentData =>
//       timeData[_childButtonIndex] ?? timeData[0];

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10.0,
//       ),
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         padding: const EdgeInsets.all(5),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             border: Border.all(
//               color: Colors.black38,
//             )),
//         child: Column(
//           children: [
//             // First Row: MTD, QTD, YTD buttons on the left, text on the right
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   width: screenWidth * 0.28, // Adjust width as needed
//                   height: screenWidth * 0.05,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey, width: .5),
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       _buildButton('MTD', 0),
//                       _buildButton('QTD', 1),
//                       _buildButton('YTD', 2),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 5,
//                 ),
//                 // Texts on the right side
//                 // Expanded(
//                 //   child: Column(
//                 //     mainAxisAlignment: MainAxisAlignment.start,
//                 //     children: [
//                 //       Column(
//                 //         children: [
//                 //           Text('Performance'),
//                 //         ],
//                 //       ),
//                 //       // Dealership rank text
//                 //       Column(
//                 //         children: [
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //                 border: Border.all(color: Colors.transparent)),
//                 //             child: Expanded(
//                 //               child: Text(
//                 //                 'My',
//                 //                 style: AppFont.tinyText(context)
//                 //                     .copyWith(fontWeight: FontWeight.w500),
//                 //                 maxLines: 2, // Limit to 2 lines
//                 //               ),
//                 //             ),
//                 //           ),
//                 //           const SizedBox(
//                 //             width: 2,
//                 //           ),
//                 //           // My performance text
//                 //           Container(
//                 //             decoration: BoxDecoration(
//                 //                 border: Border.all(color: Colors.transparent)),
//                 //             child: Expanded(
//                 //               child: Text(
//                 //                 'All india best',
//                 //                 style: AppFont.tinyText(context)
//                 //                     .copyWith(fontWeight: FontWeight.w500),
//                 //                 maxLines: 2,
//                 //               ),
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //       const SizedBox(
//                 //         width: 2,
//                 //       ),
//                 //       // All India rank text
//                 //       Expanded(
//                 //         child: Text(
//                 //           'Dealership',
//                 //           style: AppFont.tinyText(context)
//                 //               .copyWith(fontWeight: FontWeight.w500),
//                 //           maxLines: 2,
//                 //         ),
//                 //       ),
//                 //       const SizedBox(
//                 //         width: 2,
//                 //       ),
//                 //       // All India Best performer text
//                 //       Expanded(
//                 //         child: Text(
//                 //           'All india',
//                 //           style: AppFont.tinyText(context)
//                 //               .copyWith(fontWeight: FontWeight.w500),
//                 //           maxLines: 2,
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),

//                 Expanded(
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           // Performance Column
//                           Column(
//                             children: [
//                               Text(
//                                 'Performance',
//                                 style: AppFont.mediumText14(context).copyWith(
//                                     fontWeight:
//                                         FontWeight.w400), // adjust as needed
//                               ),
//                               SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'My',
//                                     style: AppFont.tinyText(context)
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'All India Best',
//                                     style: AppFont.tinyText(context)
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           // Rank Column
//                           Column(
//                             children: [
//                               Text(
//                                 'Rank',
//                                 style: AppFont.mediumText14(
//                                     context), // adjust as needed
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Dealership',
//                                     style: AppFont.tinyText(context)
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     'All India',
//                                     style: AppFont.tinyText(context)
//                                         .copyWith(fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20), // Spacing between rows
//             // Second Row: Table
//             _buildTable(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTable() {
//     double screenWidth = MediaQuery.of(context).size.width;

//     // Set responsive column widths based on screen width
//     double columnWidth1 =
//         screenWidth * 0.3; // First column (larger text, like "Enquiries")
//     double columnWidth2 = screenWidth * 0.15; // Other columns (smaller numbers)

//     return Table(
//       defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//       // border: TableBorder.all(color: Colors.grey, width: 0.2),
//       border: const TableBorder.symmetric(
//           inside: BorderSide(color: Colors.grey, width: 0.2)),
//       columnWidths: {
//         0: FixedColumnWidth(columnWidth1),
//         1: FixedColumnWidth(columnWidth2),
//         2: FixedColumnWidth(columnWidth2),
//         3: FixedColumnWidth(columnWidth2),
//         4: FixedColumnWidth(columnWidth2),
//         5: FixedColumnWidth(columnWidth2),
//         6: FixedColumnWidth(columnWidth2),
//       },
//       children: currentData!.map((rowData) => _buildTableRow(rowData)).toList(),
//     );
//   }

//   TableRow _buildTableRow(List<String> values) {
//     return TableRow(
//       children: values.map((value) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             value,
//             style:
//                 GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis, // Handle overflow
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildButton(String text, int index) {
//     bool isSelected = _childButtonIndex == index;

//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: TextButton(
//           onPressed: () {
//             setState(() {
//               _childButtonIndex = index;
//             });
//           },
//           style: TextButton.styleFrom(
//             alignment: Alignment.center,
//             foregroundColor: isSelected ? Colors.blue : Colors.black,
//             backgroundColor: isSelected ? Colors.blue : Colors.transparent,
//             padding: const EdgeInsets.symmetric(vertical: 0),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: isSelected ? Colors.white : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';

class BottomBtnThird extends StatefulWidget {
  const BottomBtnThird({super.key});

  @override
  State<BottomBtnThird> createState() => _BottomBtnThirdState();
}

class _BottomBtnThirdState extends State<BottomBtnThird> {
  int _childButtonIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  // Define table metrics - these match what's shown in the image
  final List<String> tableMetrics = [
    'Enquiries',
    'Lost Enquiries',
    'Test drives',
    'New Orders',
    'Cancellations',
    'Net Orders',
    'Retail',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); //uncomment this
  }

  Future<void> _fetchDashboardData() async {
    final token = await Storage.getToken();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.smartassistapp.in/api/users/dashboard/analytics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _dashboardData = jsonData['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching dashboard data: $e');
      // Fallback to mock data in case of error
      _loadMockData();
    }
  }

  void _loadMockData() {
    // This is a fallback in case the API call fails
    _dashboardData = {
      "MTDDealerShipRank": {
        "enquiriesRank": 5,
        "testDrivesRank": 7,
        "newOrdersRank": 3,
        "cancellationsRank": 1,
        "enquiriesCount": 4,
        "testDrivesCount": 1,
        "newOrdersCount": 1,
        "cancellationsCount": 0,
        "netOrdersRank": 2,
        "retailRank": 3,
        "netOrdersCount": 1,
        "retailCount": 0,
        "lostEnquiriesRank": 4,
        "lostEnquiriesCount": 3
      },
      "QTDDealerShipRank": {
        "enquiriesRank": 6,
        "testDrivesRank": 8,
        "newOrdersRank": 4,
        "cancellationsRank": 2,
        "enquiriesCount": 7,
        "testDrivesCount": 2,
        "newOrdersCount": 2,
        "cancellationsCount": 1,
        "netOrdersRank": 3,
        "retailRank": 4,
        "netOrdersCount": 2,
        "retailCount": 1,
        "lostEnquiriesRank": 5,
        "lostEnquiriesCount": 5
      },
      "YTDDealerShipRank": {
        "enquiriesRank": 7,
        "testDrivesRank": 9,
        "newOrdersRank": 5,
        "cancellationsRank": 3,
        "enquiriesCount": 10,
        "testDrivesCount": 3,
        "newOrdersCount": 3,
        "cancellationsCount": 2,
        "netOrdersRank": 4,
        "retailRank": 5,
        "netOrdersCount": 3,
        "retailCount": 2,
        "lostEnquiriesRank": 6,
        "lostEnquiriesCount": 7
      },
      "MTDAllIndiaRank": {
        "enquiriesRank": 25,
        "testDrivesRank": 4,
        "newOrdersRank": 2,
        "cancellationsRank": 1,
        "enquiriesCount": 11,
        "testDrivesCount": 5,
        "newOrdersCount": 3,
        "cancellationsCount": 0,
        "netOrdersRank": 3,
        "retailRank": 1,
        "netOrdersCount": 3,
        "retailCount": 2,
        "lostEnquiriesRank": 3,
        "lostEnquiriesCount": 1
      },
      "QTDAllIndiaRank": {
        "enquiriesRank": 30,
        "testDrivesRank": 6,
        "newOrdersRank": 3,
        "cancellationsRank": 2,
        "enquiriesCount": 15,
        "testDrivesCount": 7,
        "newOrdersCount": 4,
        "cancellationsCount": 1,
        "netOrdersRank": 4,
        "retailRank": 2,
        "netOrdersCount": 4,
        "retailCount": 3,
        "lostEnquiriesRank": 4,
        "lostEnquiriesCount": 2
      },
      "YTDAllIndiaRank": {
        "enquiriesRank": 35,
        "testDrivesRank": 8,
        "newOrdersRank": 4,
        "cancellationsRank": 3,
        "enquiriesCount": 20,
        "testDrivesCount": 9,
        "newOrdersCount": 5,
        "cancellationsCount": 2,
        "netOrdersRank": 5,
        "retailRank": 3,
        "netOrdersCount": 5,
        "retailCount": 4,
        "lostEnquiriesRank": 5,
        "lostEnquiriesCount": 3
      }
    };
    setState(() {
      _isLoading = false;
    });
  }

  // Get current data based on selected time period
  Map<String, dynamic> get currentDealershipRank {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }

    switch (_childButtonIndex) {
      case 0:
        return _dashboardData!['MTDDealerShipRank'];
      case 1:
        return _dashboardData!['QTDDealerShipRank'];
      case 2:
        return _dashboardData!['YTDDealerShipRank'];
      default:
        return _dashboardData!['MTDDealerShipRank'];
    }
  }

  Map<String, dynamic> get currentAllIndiaRank {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }

    switch (_childButtonIndex) {
      case 0:
        return _dashboardData!['MTDAllIndiaRank'];
      case 1:
        return _dashboardData!['QTDAllIndiaRank'];
      case 2:
        return _dashboardData!['YTDAllIndiaRank'];
      default:
        return _dashboardData!['MTDAllIndiaRank'];
    }
  }

  // Generate dynamic table rows based on API data
  List<List<String>> get tableData {
    final List<List<String>> data = [];

    if (_dashboardData == null) {
      return [];
    }

    // Add Enquiries row
    data.add([
      'Enquiries',
      currentDealershipRank['enquiriesCount']?.toString() ?? '0',
      currentAllIndiaRank['enquiriesCount']?.toString() ?? '0',
      currentDealershipRank['enquiriesRank']?.toString() ?? '0',
      currentAllIndiaRank['enquiriesRank']?.toString() ?? '0',
    ]);

    // Add Lost Enquiries row
    data.add([
      'Lost Enquiries',
      currentDealershipRank['lostEnquiriesCount']?.toString() ?? '0',
      currentAllIndiaRank['lostEnquiriesCount']?.toString() ?? '0',
      currentDealershipRank['lostEnquiriesRank']?.toString() ?? '0',
      currentAllIndiaRank['lostEnquiriesRank']?.toString() ?? '0',
    ]);

    // Add Test drives row
    data.add([
      'Test drives',
      currentDealershipRank['testDrivesCount']?.toString() ?? '0',
      currentAllIndiaRank['testDrivesCount']?.toString() ?? '0',
      currentDealershipRank['testDrivesRank']?.toString() ?? '0',
      currentAllIndiaRank['testDrivesRank']?.toString() ?? '0',
    ]);

    // Add New Orders row
    data.add([
      'New Orders',
      currentDealershipRank['newOrdersCount']?.toString() ?? '0',
      currentAllIndiaRank['newOrdersCount']?.toString() ?? '0',
      currentDealershipRank['newOrdersRank']?.toString() ?? '0',
      currentAllIndiaRank['newOrdersRank']?.toString() ?? '0',
    ]);

    // Add Cancellations row
    data.add([
      'Cancellations',
      currentDealershipRank['cancellationsCount']?.toString() ?? '0',
      currentAllIndiaRank['cancellationsCount']?.toString() ?? '0',
      currentDealershipRank['cancellationsRank']?.toString() ?? '0',
      currentAllIndiaRank['cancellationsRank']?.toString() ?? '0',
    ]);

    // Add Net Orders row
    data.add([
      'Net Orders',
      currentDealershipRank['netOrdersCount']?.toString() ?? '0',
      currentAllIndiaRank['netOrdersCount']?.toString() ?? '0',
      currentDealershipRank['netOrdersRank']?.toString() ?? '0',
      currentAllIndiaRank['netOrdersRank']?.toString() ?? '0',
    ]);

    // Add Retail row
    data.add([
      'Retail',
      currentDealershipRank['retailCount']?.toString() ?? '0',
      currentAllIndiaRank['retailCount']?.toString() ?? '0',
      currentDealershipRank['retailRank']?.toString() ?? '0',
      currentAllIndiaRank['retailRank']?.toString() ?? '0',
    ]);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black38,
            )),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _buildHeaderRow(screenWidth),
                  const SizedBox(height: 20),
                  _buildTable(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // MTD, QTD, YTD toggle buttons
        Container(
          width: screenWidth * 0.28,
          height: screenWidth * 0.05,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: .5),
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildButton('MTD', 0),
              _buildButton('QTD', 1),
              _buildButton('YTD', 2),
            ],
          ),
        ),
        // const SizedBox(width: 5),
        // Performance and Rank headers
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Performance Column
                  Column(
                    children: [
                      Text(
                        'Performance',
                        style: AppFont.mediumText14(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My',
                            style: AppFont.tinyText(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'All India Best',
                            style: AppFont.tinyText(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: MediaQuery.of(context).size.height * .07,
                    width: 0.1,
                    decoration: BoxDecoration(
                      border: Border(
                          right:
                              BorderSide(color: Colors.grey.withOpacity(0.3))),
                    ),
                  ),

                  // Rank Column
                  Column(
                    children: [
                      Text(
                        'Rank',
                        style: AppFont.mediumText14(context),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Dealership',
                            style: AppFont.tinyText(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'All India',
                            style: AppFont.tinyText(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5),
      ),
      columnWidths: {
        0: FixedColumnWidth(screenWidth * 0.3), // Metric name
        1: FixedColumnWidth(screenWidth * 0.15), // My Performance
        2: FixedColumnWidth(screenWidth * 0.15), // All India Best
        3: FixedColumnWidth(screenWidth * 0.15), // Dealership Rank
        4: FixedColumnWidth(screenWidth * 0.15), // All India Rank
      },
      children: tableData.map((rowData) => _buildTableRow(rowData)).toList(),
    );
  }

  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign:
                values.indexOf(value) == 0 ? TextAlign.left : TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String text, int index) {
    bool isSelected = _childButtonIndex == index;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              _childButtonIndex = index;
            });
          },
          style: TextButton.styleFrom(
            alignment: Alignment.center,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            backgroundColor: isSelected ? Colors.blue : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
