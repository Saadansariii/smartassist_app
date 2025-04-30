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
import 'package:shimmer/shimmer.dart';
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
  int _periodIndex = 0;
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
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final token = await Storage.getToken();

      // Determine period parameter based on selection
      String periodParam = '';
      switch (_childButtonIndex) {
        case 1:
          periodParam = '?type=QTD';
          break;
        case 2:
          periodParam = '?type=YTD';
          break;
        default:
          periodParam = '?type=MTD';
      }

      final response = await http.get(
        Uri.parse(
            'https://api.smartassistapp.in/api/users/dashboard/analytics$periodParam'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Check if the widget is still in the widget tree before calling setState
        if (mounted) {
          setState(() {
            _dashboardData = jsonData['data'];
            _isLoading = false;
          });
        }
      } else {
        // Handle unsuccessful status codes
        throw Exception(
            'Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Check if the widget is still in the widget tree before calling setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Handle different types of errors
      if (e is http.ClientException) {
        debugPrint('Network error: $e');
      } else if (e is FormatException) {
        debugPrint('Error parsing data: $e');
      } else {
        debugPrint('Unexpected error: $e');
      }
    }
  }

  // Get current data based on selected period
  Map<String, dynamic> get currentDealershipRank {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }
    return _dashboardData!['dealershipRank'] ?? {};
  }

  Map<String, dynamic> get currentAllIndiaRank {
    if (_dashboardData == null) {
      // Return empty data if API data isn't available yet
      return {};
    }

    // Using allINDRank from API response
    return _dashboardData!['allINDRank'] ?? {};
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
      _dashboardData!['allData']['lostEnquiries']?.toString() ?? '0',
      '0', // No data in API response for all India lost enquiries
      '0', // No rank data for lost enquiries
      '0', // No rank data for lost enquiries
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
    int myNetOrders = (int.tryParse(
                currentDealershipRank['newOrdersCount']?.toString() ?? '0') ??
            0) -
        (int.tryParse(currentDealershipRank['cancellationsCount']?.toString() ??
                '0') ??
            0);
    int allIndiaNetOrders = (int.tryParse(
                currentAllIndiaRank['newOrdersCount']?.toString() ?? '0') ??
            0) -
        (int.tryParse(
                currentAllIndiaRank['cancellationsCount']?.toString() ?? '0') ??
            0);

    data.add([
      'Net Orders',
      myNetOrders.toString(),
      allIndiaNetOrders.toString(),
      '0', // No specific rank data for net orders
      '0', // No specific rank data for net orders
    ]);

    // Add Retail row - assuming allData.ConvertedOrder contains retail data
    data.add([
      'Retail',
      _dashboardData!['allData']['ConvertedOrder']?.toString() ?? '0',
      '0', // No data in API response for all India retail
      '0', // No rank data for retail
      '0', // No rank data for retail
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
                color: Colors.black.withOpacity(.1),
              )),
          // child: _isLoading
          //     ? _buildSkeletonLoader()
          //     : Column(
          //         children: [
          //           const SizedBox(height: 10),
          //           _buildHeaderRow(screenWidth),
          //           const SizedBox(height: 5),
          //           _buildAnalyticsTable()
          //           // // const SizedBox(height: 20),
          //           // _buildTable(),
          //         ],
          //       ),

          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeaderRow(screenWidth),

              _isLoading ? _buildSkeletonLoader() : const SizedBox(height: 5),
              _buildAnalyticsTable()
              
            ],
          ),
        )

        // child: _buildSkeletonLoader()),
        );
  }

  Widget _buildAnalyticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
          verticalInside: BorderSide.none
          // verticalInside: BorderSide(
          //   color: Colors.grey.withOpacity(0.3),
          //   width: 0.5,
          // ),
          ),
      columnWidths: {
        0: FixedColumnWidth(screenWidth * 0.3), // Metric
        1: FixedColumnWidth(screenWidth * 0.15), // My
        2: FixedColumnWidth(screenWidth * 0.15), // All India Best
        3: FixedColumnWidth(screenWidth * 0.15), // Dealership
        4: FixedColumnWidth(screenWidth * 0.15), // All India
      },
      children: [
        // Header Row
        // TableRow(
        //   decoration: BoxDecoration(
        //     color: Colors.grey[100],
        //   ),
        //   children: [
        //     const SizedBox(), // Empty cell for top-left
        //     Center(
        //         child:
        //             Text('Performance', style: AppFont.mediumText14(context))),
        //     const SizedBox(), // Spanned cell - visually handled by alignment
        //     Center(child: Text('Rank', style: AppFont.mediumText14(context))),
        //     const SizedBox(),
        //   ],
        // ),
        TableRow(
          children: [
            const SizedBox(), // Empty cell
            Center(child: Text('My', style: AppFont.tinyText(context))),
            Center(
                child: Text('All India Best',
                    textAlign: TextAlign.center,
                    style: AppFont.tinyText(context))),
            Center(child: Text('Dealership', style: AppFont.tinyText(context))),
            Center(child: Text('All India', style: AppFont.tinyText(context))),
          ],
        ),
        ...tableData.map((row) => _buildTableRow(row)).toList(),
      ],
    );
  }

  Widget _buildHeaderRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // MTD, QTD, YTD toggle buttons
        Container(
          width: screenWidth * 0.30,
          height: screenWidth * 0.06,
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
        // Performance and Rank headers
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Performance Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Performance',
                        style: AppFont.mediumText14(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  // Container(
                  //   height: MediaQuery.of(context).size.height * .07,
                  //   width: 0.1,
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //         right:
                  //             BorderSide(color: Colors.grey.withOpacity(0.3))),
                  //   ),
                  // ),

                  // Rank Column
                  Column(
                    children: [
                      Text(
                        'Rank',
                        style: AppFont.mediumText14(context),
                      ),
                      const SizedBox(height: 8),
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

  // Widget _buildTable() {
  //   double screenWidth = MediaQuery.of(context).size.width;

  //   return Table(
  //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  //     border: TableBorder(
  //       horizontalInside: BorderSide(
  //           color: Colors.grey.withOpacity(0.3),
  //           width: 0.5,
  //           strokeAlign: BorderSide.strokeAlignCenter),
  //       verticalInside: BorderSide.none,
  //     ),
  //     columnWidths: {
  //       0: FixedColumnWidth(screenWidth * 0.3), // Metric name
  //       1: FixedColumnWidth(screenWidth * 0.15), // My Performance
  //       2: FixedColumnWidth(screenWidth * 0.15), // All India Best
  //       3: FixedColumnWidth(screenWidth * 0.15), // Dealership Rank
  //       4: FixedColumnWidth(screenWidth * 0.15), // All India Rank
  //     },
  //     children: tableData.map((rowData) => _buildTableRow(rowData)).toList(),
  //   );
  // }

  TableRow _buildTableRow(List<String> values) {
    return TableRow(
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0),
          child: Text(
            value,
            style: AppFont.smallText(context),
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
              _fetchDashboardData(); // Reload data when period changes
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

  Widget _buildSkeletonLoader() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: List.generate(7, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: 16.0,
                  color: AppColors.backgroundLightGrey,
                ),
                const SizedBox(width: 10),
                Container(
                  width: screenWidth * 0.55,
                  height: 16.0,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Container(
                  width: screenWidth * 0.55,
                  height: 16.0,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Container(
                  width: screenWidth * 0.15,
                  height: 16.0,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Container(
                  width: screenWidth * 0.15,
                  height: 16.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
