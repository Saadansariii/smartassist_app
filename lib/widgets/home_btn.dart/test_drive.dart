import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TestDrive extends StatefulWidget {
  final Map<String, dynamic> MtdData;
  final Map<String, dynamic> YtdData;
  final Map<String, dynamic> QtdData;
  const TestDrive(
      {super.key,
      required this.MtdData,
      required this.YtdData,
      required this.QtdData});

  @override
  State<TestDrive> createState() => _TestDriveState();
}

class _TestDriveState extends State<TestDrive> {
  // int _childButtonIndex = 0;
  // final PageController _pageController = PageController();

  // Map<String, dynamic> getSelectedData() {
  //   switch (_childButtonIndex) {
  //     case 0:
  //       return widget.MtdData;
  //     case 1:
  //       return widget.QtdData;
  //     case 2:
  //       return widget.YtdData;
  //     default:
  //       return {};
  //   }
  // }

  int _childButtonIndex = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic> getSelectedData() {
    Map<String, dynamic> periodData;

    // Select the appropriate period data
    switch (_childButtonIndex) {
      case 0:
        periodData = widget.MtdData;
        break;
      case 1:
        periodData = widget.QtdData;
        break;
      case 2:
        periodData = widget.YtdData;
        break;
      default:
        periodData = {};
    }

    // Make sure allData exists, otherwise return empty map
    return periodData['data'] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final selectedData = getSelectedData();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.42,
                  height: 27,
                  decoration: BoxDecoration(
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 280,
            child: PageView(
              controller: _pageController,
              children: [
                _buildFirstSlide(context, screenWidth),
                _buildSecondSlide(context, screenWidth),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Smooth Page Indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: WormEffect(
              activeDotColor: Colors.blue,
              dotColor: Colors.grey.shade300,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildFirstSlide(BuildContext context, double screenWidth) {
    final selectedData = getSelectedData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'You have given',
                        'Unique test drives',
                        '${selectedData['uniqueTestDrives'] ?? 0}',
                        screenWidth,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildInfoCard(
                        context,
                        'Give',
                        'More test drive to achive your target',
                        '${selectedData['remainingTestDrives'] ?? 0}',
                        screenWidth,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: _buildInfoCard2(
                  context,
                  '${selectedData['TestDrivesAvg'] ?? 0} days',
                  'On an average, you take',
                  'to convert a test drive to an order ',
                  screenWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondSlide(BuildContext context, double screenWidth) {
    final selectedData = getSelectedData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: _buildInfoCard3(
                  context,
                  // '45%',
                  '${selectedData['enquiryToUniqueTestdriveRatio'] ?? 0} %',
                  'Enquiry to Unique test drive ratio',
                  screenWidth,
                ),
              ),
            ),
            // const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: Container(
                // margin: const EdgeInsets.only(right: 10),
                child: _buildInfoCard3(
                  context,
                  // '29%',

                  '${selectedData['testDriveRatio'] ?? 0} %',
                  'Enquiry to Test Drive Ratio',
                  screenWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Button Builder
  Widget _buildButton(String text, int index) {
    bool isSelected = _childButtonIndex == index;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : Colors.transparent, // Only selected has blue border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              _childButtonIndex = index;
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: isSelected
                ? Colors.blue
                : Colors.black, // Selected text blue, others black
            backgroundColor: Colors.transparent, // No background color change
            padding: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Small Info Cards
  Widget _buildInfoCard(BuildContext context, String title, String title1,
      String value, double screenWidth, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 30, fontWeight: FontWeight.w700, color: valueColor),
          ),
          Text(
            title1,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          // const SizedBox(width: 10),
        ],
      ),
    );
  }

  // Large Info Card
  Widget _buildInfoCard2(BuildContext context, String title, String value,
      String value1, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Text(
              value,
              style: AppFont.dropDowmLabel(context),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 30, fontWeight: FontWeight.w700, color: Colors.blue),
          ),
          Text(
            value1,
            style: AppFont.dropDowmLabel(context),
          ),
          // const SizedBox(height: 2),
          // const SizedBox(
          //   height: 5,
          // ),
          // const Align(
          //     alignment: Alignment.centerRight,
          //     child: Text(
          //       textAlign: TextAlign.center,
          //       '😍',
          //       style:
          //           TextStyle(fontSize: 20, fontFamily: 'YourAppleEmojiFont'),
          //     ))
        ],
      ),
    );
  }

  Widget _buildInfoCard3(
      BuildContext context, String title, String value, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppFont.dropDowmLabel(context),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 30, fontWeight: FontWeight.w700, color: Colors.blue),
          ),
          // const SizedBox(height: 2),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
