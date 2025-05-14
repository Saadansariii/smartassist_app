import 'package:flutter/material.dart';
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

    // Make sure data exists, otherwise return empty map
    return periodData['data'] ?? {};
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
                        'Orders with you',
                        '${selectedData['orders'] ?? 0}',
                        'Is your target',
                        '${selectedData['orderTarget'] ?? 0}',
                        screenWidth,
                        Colors.green,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: _buildInfoCardSecond(
                          context,
                          screenWidth,
                          selectedData,
                        ),
                      ),
                    ),
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
                          '${selectedData['TestDriveToRetail'] ?? 0}%',
                          'Test drive to retail ratio',
                          screenWidth,
                          Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      // 🔹 Ensure both cards take equal space
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: _buildInfoCard2(
                          context,
                          '${selectedData['digitalEnquiryToOrderRatio'] ?? 0}%',
                          'Digital enquiry to new order ratio',
                          screenWidth,
                          Colors.red,
                        ),
                      ),
                    ),
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
    Map<String, dynamic> selectedData,
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
              'Your contribution to of dealership cancellations',
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
              '${selectedData['contributionToDealershipmsg'] ?? 0}%',
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
          Text(
            value,
            style: AppFont.smallText(context),
          ),
        ],
      ),
    );
  }
}
