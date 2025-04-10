import 'package:flutter/material.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart'; 
import 'package:smart_assist/widgets/home_btn.dart/leads.dart';
import 'package:smart_assist/widgets/home_btn.dart/order.dart';
import 'package:smart_assist/widgets/home_btn.dart/test_drive.dart';

class BottomBtnSecond extends StatefulWidget {
  final Map<String, dynamic> MtdData;
  final Map<String, dynamic> YtdData;
  final Map<String, dynamic> QtdData;
  const BottomBtnSecond(
      {super.key,
      required this.MtdData,
      required this.YtdData,
      required this.QtdData});

  @override
  State<BottomBtnSecond> createState() => _BottomBtnSecondState();
}

class _BottomBtnSecondState extends State<BottomBtnSecond> {
  // Map<String, dynamic> MtdData = {};
  // Map<String, dynamic> QtdData = {};
  // Map<String, dynamic> YtdData = {};

  Widget? currentWidget;

  int _leadButton = 0;

  @override
  void initState() {
    super.initState();
    // _loadDashboardAnalytics();
    _setInitialWidget();
  }

  void _setInitialWidget() {
    if (_leadButton == 0) {
      currentWidget = Leads(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      );
    } else if (_leadButton == 1) {
      currentWidget = TestDrive(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      );
    } else if (_leadButton == 2) {
      currentWidget = Order(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      ); // if Order doesn't use data
    }
  }

  // Future<void> _loadDashboardAnalytics() async {
  //   try {
  //     final data = await LeadsSrv.fetchDashboardAnalytics();
  //     setState(() {
  //       MtdData = data['MTD'] ?? {};
  //       QtdData = data['QTD'] ?? {};
  //       YtdData = data['YTD'] ?? {};

  //       // Rebuild Leads widget with updated data
  //       if (_leadButton == 0) {
  //         currentWidget = Leads(
  //           MtdData: MtdData,
  //           QtdData: QtdData,
  //           YtdData: YtdData,
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     print("Error loading analytics: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.containerBg,
          border: Border.all(color: Colors.black.withOpacity(.1)),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: SizedBox(
                height: 32,
                width: double.infinity,
                child: Row(
                  children: [
                    // Leads Button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _leadButton = 0;
                            leads(0);
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
                            testDrive(1);
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
                            orders(2);
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
              ), // Handle null case

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor:
          isSelected ? const Color(0xFF1380FE) : Colors.transparent,
      foregroundColor: isSelected ? Colors.white : AppColors.fontColor,
      textStyle: AppFont.threeBtn(context),
    );
  }

  // Update Widgets
  void leads(int index) {
    setState(() {
      currentWidget = Leads(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      );
    });
  }

  void testDrive(int index) {
    setState(() {
      currentWidget = TestDrive(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      );
    });
  }

  void orders(int index) {
    setState(() {
      currentWidget = Order(
        MtdData: widget.MtdData,
        QtdData: widget.QtdData,
        YtdData: widget.YtdData,
      );
    });
  }
}
