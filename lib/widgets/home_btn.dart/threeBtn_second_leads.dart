// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:smart_assist/utils/storage.dart';
// import 'package:smart_assist/widgets/home_btn.dart/leads.dart';
// import 'package:smart_assist/widgets/home_btn.dart/order.dart';
// import 'package:smart_assist/widgets/home_btn.dart/test_drive.dart';

// import 'package:http/http.dart' as http;

// class BottomBtnSecond extends StatefulWidget {
//   final Map<String, dynamic> MtdData;
//   final Map<String, dynamic> YtdData;
//   final Map<String, dynamic> QtdData;
//   const BottomBtnSecond(
//       {super.key,
//       required this.MtdData,
//       required this.YtdData,
//       required this.QtdData});

//   @override
//   State<BottomBtnSecond> createState() => _BottomBtnSecondState();
// }

// class _BottomBtnSecondState extends State<BottomBtnSecond> {
//   // Map<String, dynamic> MtdData = {};
//   // Map<String, dynamic> QtdData = {};
//   // Map<String, dynamic> YtdData = {};
//   int _childButtonIndex = 0;
//   bool _isLoading = true;
//   Map<String, dynamic>? _dashboardData;

//   Widget? currentWidget;

//   int _leadButton = 0;

//   @override
//   void initState() {
//     super.initState();
//     // _loadDashboardAnalytics();
//     _fetchDashboardData();
//     _setInitialWidget();
//   }

//   void _setInitialWidget() {
//     if (_leadButton == 0) {
//       currentWidget = Leads(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       );
//     } else if (_leadButton == 1) {
//       currentWidget = TestDrive(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       );
//     } else if (_leadButton == 2) {
//       currentWidget = Order(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       ); // if Order doesn't use data
//     }
//   }

//   Future<void> _fetchDashboardData() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       final token = await Storage.getToken();

//       // Determine period parameter based on selection
//       String periodParam = '';
//       switch (_childButtonIndex) {
//         case 1:
//           periodParam = '?type=QTD';
//           break;
//         case 2:
//           periodParam = '?type=YTD';
//           break;
//         default:
//           periodParam = '?type=MTD';
//       }

//       final response = await http.get(
//         Uri.parse(
//             'https://dev.smartassistapp.in/api/users/dashboard/analytics$periodParam'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         // Check if the widget is still in the widget tree before calling setState
//         if (mounted) {
//           setState(() {
//             _dashboardData = jsonData['data'];
//             _isLoading = false;
//           });
//         }
//       } else {
//         // Handle unsuccessful status codes
//         throw Exception(
//             'Failed to load dashboard data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Check if the widget is still in the widget tree before calling setState
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }

//       // Handle different types of errors
//       if (e is http.ClientException) {
//         debugPrint('Network error: $e');
//       } else if (e is FormatException) {
//         debugPrint('Error parsing data: $e');
//       } else {
//         debugPrint('Unexpected error: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//           color: AppColors.containerBg,
//           border: Border.all(color: Colors.black.withOpacity(.1)),
//           borderRadius: const BorderRadius.all(Radius.circular(5))),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: SizedBox(
//                 height: 32,
//                 width: double.infinity,
//                 child: Row(
//                   children: [
//                     // Leads Button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _leadButton = 0;
//                             leads(0);
//                           });
//                         },
//                         style: _buttonStyle(_leadButton == 0),
//                         child: Text(
//                           'Enquiry',
//                           textAlign: TextAlign.center,
//                           style: AppFont.buttonwhite(context),
//                         ),
//                       ),
//                     ),

//                     // Test Drive Button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _leadButton = 1;
//                             testDrive(1);
//                           });
//                         },
//                         style: _buttonStyle(_leadButton == 1),
//                         child: Text('Test Drive',
//                             textAlign: TextAlign.center,
//                             style: AppFont.buttonwhite(context)),
//                       ),
//                     ),

//                     // Orders Button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _leadButton = 2;
//                             orders(2);
//                           });
//                         },
//                         style: _buttonStyle(_leadButton == 2),
//                         child: Text('Orders',
//                             textAlign: TextAlign.center,
//                             style: AppFont.buttonwhite(context)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           currentWidget ??
//               const SizedBox(
//                 height: 10,
//               ), // Handle null case

//           const SizedBox(
//             height: 5,
//           ),
//         ],
//       ),
//     );
//   }

//   // Button Style
//   ButtonStyle _buttonStyle(bool isSelected) {
//     return TextButton.styleFrom(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//       backgroundColor:
//           isSelected ? const Color(0xFF1380FE) : Colors.transparent,
//       foregroundColor: isSelected ? Colors.white : AppColors.fontColor,
//       textStyle: AppFont.threeBtn(context),
//     );
//   }

//   // Update Widgets
//   void leads(int index) {
//     setState(() {
//       currentWidget = Leads(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       );
//     });
//   }

//   void testDrive(int index) {
//     setState(() {
//       currentWidget = TestDrive(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       );
//     });
//   }

//   void orders(int index) {
//     setState(() {
//       currentWidget = Order(
//         MtdData: widget.MtdData,
//         QtdData: widget.QtdData,
//         YtdData: widget.YtdData,
//       );
//     });
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:smart_assist/widgets/home_btn.dart/leads.dart';
import 'package:smart_assist/widgets/home_btn.dart/order.dart';
import 'package:smart_assist/widgets/home_btn.dart/test_drive.dart';

import 'package:http/http.dart' as http;

class BottomBtnSecond extends StatefulWidget {
  const BottomBtnSecond({super.key});

  @override
  State<BottomBtnSecond> createState() => _BottomBtnSecondState();
}

class _BottomBtnSecondState extends State<BottomBtnSecond> {
  int _childButtonIndex = 0; // 0:MTD, 1:QTD, 2:YTD
  int _leadButton = 0; // 0:Enquiry, 1:Test Drive, 2:Orders

  bool _isLoading = true;
  Map<String, dynamic>? _mtdData;
  Map<String, dynamic>? _qtdData;
  Map<String, dynamic>? _ytdData;
  Widget? currentWidget;

  @override
  void initState() {
    super.initState();
    _fetchAllPeriodData().then((_) {
      _setInitialWidget();
    });
  }

  // Fetch data for all periods (MTD, QTD, YTD)
  Future<void> _fetchAllPeriodData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch MTD data
      await _fetchDashboardData('MTD').then((data) {
        if (mounted) {
          setState(() {
            _mtdData = data;
          });
        }
      });

      // Fetch QTD data
      await _fetchDashboardData('QTD').then((data) {
        if (mounted) {
          setState(() {
            _qtdData = data;
          });
        }
      });

      // Fetch YTD data
      await _fetchDashboardData('YTD').then((data) {
        if (mounted) {
          setState(() {
            _ytdData = data;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching all period data: $e');
    }
  }

  // Fetch dashboard data for a specific period
  Future<Map<String, dynamic>?> _fetchDashboardData(String period) async {
    try {
      final token = await Storage.getToken();

      final uri = Uri.parse(
          'https://dev.smartassistapp.in/api/users/dashboard/analytics?type=$period');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(uri);
      // print('hiii');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        throw Exception(
            'Failed to load $period dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching $period data: $e');
      return null;
    }
  }

  void _setInitialWidget() {
    if (_isLoading ||
        _mtdData == null ||
        _qtdData == null ||
        _ytdData == null) {
      return;
    }

    if (_leadButton == 0) {
      _updateLeadsWidget();
    } else if (_leadButton == 1) {
      _updateTestDriveWidget();
    } else if (_leadButton == 2) {
      _updateOrdersWidget();
    }
  }

  void _updateLeadsWidget() {
    setState(() {
      currentWidget = Leads(
        MtdData: _mtdData!,
        QtdData: _qtdData!,
        YtdData: _ytdData!,
      );
    });
  }

  void _updateTestDriveWidget() {
    setState(() {
      currentWidget = TestDrive(
        MtdData: _mtdData!,
        QtdData: _qtdData!,
        YtdData: _ytdData!,
      );
    });
  }

  void _updateOrdersWidget() {
    setState(() {
      currentWidget = Order(
        MtdData: _mtdData!,
        QtdData: _qtdData!,
        YtdData: _ytdData!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.containerBg,
          border: Border.all(color: Colors.black.withOpacity(.1)),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * .05,
                      width: double.infinity,
                      child: Row(
                        children: [
                          // Leads Button
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _leadButton = 0;
                                  _updateLeadsWidget();
                                });
                              },
                              style: _buttonStyle(_leadButton == 0),
                              child: Text(
                                'Enquiry',
                                textAlign: TextAlign.center,
                                style: AppFont.buttonwhite(context),
                              ),
                            ),
                          ),

                          // Test Drive Button
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _leadButton = 1;
                                  _updateTestDriveWidget();
                                });
                              },
                              style: _buttonStyle(_leadButton == 1),
                              child: Text('Test Drive',
                                  textAlign: TextAlign.center,
                                  style: AppFont.buttonwhite(context)),
                            ),
                          ),

                          // Orders Button
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _leadButton = 2;
                                  _updateOrdersWidget();
                                });
                              },
                              style: _buttonStyle(_leadButton == 2),
                              child: Text('Orders',
                                  textAlign: TextAlign.center,
                                  style: AppFont.buttonwhite(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                currentWidget ??
                    const SizedBox(
                      height: 10,
                    ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
    );
  }

  // Button Style
  ButtonStyle _buttonStyle(bool isSelected) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 8),
      minimumSize: const Size(0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor:
          isSelected ? const Color(0xFF1380FE) : Colors.transparent,
      foregroundColor: isSelected ? Colors.white : AppColors.fontColor,
      textStyle: AppFont.threeBtn(context),
    );
  }
}
