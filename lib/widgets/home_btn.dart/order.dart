import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/font/font.dart';

class Order extends StatefulWidget {
  final Map<String, dynamic> MtdData;
  final Map<String, dynamic> YtdData;
  final Map<String, dynamic> QtdData;
  const Order(
      {super.key,
      required this.MtdData,
      required this.YtdData,
      required this.QtdData});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  // int _childButtonIndex = 0;

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
    return periodData['allData'] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    final selectedData = getSelectedData();

    return Column(
      children: [
        // Row with Buttons and Enquiry Bank

        const SizedBox(height: 15),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Match heights
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max, // Use full height
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: screenWidth * 0.40,
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
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: _buildInfoCard(
                        context,
                        _getLeftOneTitle(_childButtonIndex),
                        _getLeftOneValue(_childButtonIndex),
                        _getLeftTwoTitle(_childButtonIndex),
                        _getLeftTwoValue(_childButtonIndex),
                        screenWidth,
                        _getGreenCardColor(_childButtonIndex),
                        _getRedCardColor(_childButtonIndex),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: _buildInfoCardSecond(
                        context,
                        screenWidth,
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max, // Use full height
                  children: [
                    Expanded(
                        // 🔹 Make the right column stretch fully
                        child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: _buildInfoCard2(
                        context,
                        _getRightOneCardTitle(_childButtonIndex),
                        _getRightOneCardValue(_childButtonIndex),
                        screenWidth,
                        _getGreenCardColor1(_childButtonIndex),
                      ),
                    )),
                    const SizedBox(height: 10),
                    Expanded(
                        // 🔹 Ensure both cards take equal space
                        child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: _buildInfoCard2(
                        context,
                        _getRightTwoCardTitle(_childButtonIndex),
                        _getRightTwoCardValue(_childButtonIndex),
                        screenWidth,
                        _getBlueCardColor(_childButtonIndex),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  // Dynamic Titles and Values for Each Selected Button
  String _getLeftOneTitle(int index) {
    switch (index) {
      case 0:
        return 'Orders with you';
      case 1:
        return 'Orders with you';
      case 2:
        return 'Orders with you';
      default:
        return '';
    }
  }

  String _getLeftOneValue(int index) {
    switch (index) {
      case 0:
        return '3';
      case 1:
        return '50';
      case 2:
        return '120';
      default:
        return '';
    }
  }

  String _getLeftTwoTitle(int index) {
    switch (index) {
      case 0:
        return 'Is your target';
      case 1:
        return 'Is your target';
      case 2:
        return 'Is your target';
      default:
        return '';
    }
  }

  String _getLeftTwoValue(int index) {
    switch (index) {
      case 0:
        return '1';
      case 1:
        return '50';
      case 2:
        return '120';
      default:
        return '';
    }
  }

  Color _getGreenCardColor(int index) {
    switch (index) {
      case 0:
        return Colors.green; // Color for MTD
      case 1:
        return Colors.green; // Color for QTD
      case 2:
        return Colors.green; // Color for YTD
      default:
        return Colors.black; // Default color
    }
  }

  Color _getGreenCardColor1(int index) {
    switch (index) {
      case 0:
        return Colors.red; // Color for MTD
      case 1:
        return Colors.red; // Color for QTD
      case 2:
        return Colors.red; // Color for YTD
      default:
        return Colors.black; // Default color
    }
  }

  Color _getRedCardColor(int index) {
    switch (index) {
      case 0:
        return Colors.red; // Color for MTD
      case 1:
        return Colors.red; // Color for QTD
      case 2:
        return Colors.red; // Color for YTD
      default:
        return Colors.black; // Default color
    }
  }

  Color _getBlueCardColor(int index) {
    switch (index) {
      case 0:
        return Colors.red; // Color for MTD
      case 1:
        return Colors.red; // Color for QTD
      case 2:
        return Colors.red; // Color for YTD
      default:
        return Colors.black; // Default color
    }
  }

  String _getMiddleCardValue(int index) {
    switch (index) {
      case 0:
        return '8';
      case 1:
        return '40';
      case 2:
        return '100';
      default:
        return '';
    }
  }

  String _getRightOneCardTitle(int index) {
    switch (index) {
      case 0:
        return '45%';
      case 1:
        return '100';
      case 2:
        return '350';
      default:
        return '';
    }
  }

  String _getRightTwoCardTitle(int index) {
    switch (index) {
      case 0:
        return '25%';
      case 1:
        return '100';
      case 2:
        return '350';
      default:
        return '';
    }
  }

  String _getRightOneCardValue(int index) {
    switch (index) {
      case 0:
        return 'Test drive to retail ratio';
      case 1:
        return 'Test drive to retail ratio';
      case 2:
        return 'Test drive to retail ratio';
      default:
        return '';
    }
  }

  String _getRightTwoCardValue(int index) {
    switch (index) {
      case 0:
        return 'Digital enquiry to new order ratio';
      case 1:
        return 'Digital enquiry to new order ratio';
      case 2:
        return 'Digital enquiry to new order ratio';
      default:
        return '';
    }
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
  Widget _buildInfoCard(
      BuildContext context,
      String title1,
      String value1,
      String title2,
      String value2,
      double screenWidth,
      Color valueColor1,
      Color valueColor2) {
    // Accept second color
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spacing between rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value2,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value1,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Small Info Cards
  Widget _buildInfoCardSecond(
    BuildContext context,
    double screenWidth,
  ) {
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
          Expanded(
            child: Text(
              'Your contribution  to of dealership cancellations',
              // 'Your contribution (dealerShipCancellation) to  //'${dealerShipCancellation}' of dealership cancellations', //this is the way for calling this api
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              '20%',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: GoogleFonts.poppins(
                  color: Colors.red, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Large Info Card
  Widget _buildInfoCard2(BuildContext context, String title, String value,
      double screenWidth, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 30, fontWeight: FontWeight.w700, color: valueColor),
          ),
          // const SizedBox(height: 2),
          Text(
            value,
            style: AppFont.smallText(context),
          ),
        ],
      ),
    );
  }
}
