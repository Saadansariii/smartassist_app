import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Leads extends StatefulWidget {
  final Map<String, dynamic> MtdData;
  final Map<String, dynamic> YtdData;
  final Map<String, dynamic> QtdData;
  const Leads(
      {super.key,
      required this.MtdData,
      required this.YtdData,
      required this.QtdData});

  @override
  State<Leads> createState() => _LeadsState();
}

class _LeadsState extends State<Leads> {
  // final selectedData = getSelectedData();

  int _childButtonIndex = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic> getSelectedData() {
    // print('this is data selected');
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
    // Get screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    final selectedData = getSelectedData();

    return Column(
      children: [
        // Top Row with Buttons and Enquiry Bank
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Buttons Container
              Container(
                width: screenWidth * 0.45,
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

              // Enquiry Bank Container
              Container(
                width: screenWidth * 0.42,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enquiry bank',
                      style: AppFont.smallText(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${getSelectedData()['enquiryBank'] ?? 0}',
                      style: AppFont.smallTextBold(context).copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // PageView for Slides
        SizedBox(
          height: 240,
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
    );
  }

  // First Slide
  Widget _buildFirstSlide(BuildContext context, double screenWidth) {
    final selectedData = getSelectedData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildInfoCard1(
                      context,
                      'Enquiries you have',
                      '${selectedData['newEnquiries'] ?? 0}',
                      screenWidth,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildInfoCard1(
                      context,
                      'Enquiries lost',
                      '${selectedData['lostEnquiries'] ?? 0}',
                      screenWidth,
                      Colors.red,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRightInfoCard(
                context,
                'You must pursue',
                'More enquiries to achieve your target',
                '${selectedData['enquiriesToAchieveTarget'] ?? 0}',
                screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Second Slide
  Widget _buildSecondSlide(BuildContext context, double screenWidth) {
    final selectedData = getSelectedData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Follow-ups recommended for order',
                    'Follow-ups done by you per lost enquiry',
                    '2',
                    '2',
                    // '${selectedData['enquiryBank'] ?? 0}',
                    screenWidth,
                    Colors.red,
                    Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Follow-ups done by you per lost digital enquiry',
                    'Follow-ups recommended for order',
                    '3',
                    '2',
                    screenWidth,
                    Colors.red,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildRightInfoCard2(
              context,
              'On an average, to take',
              'to convert an enquiry to order',
              '${selectedData['avgEnquiry'] ?? 0} days',
              screenWidth,
            ),
          ),
        ],
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
            color: isSelected ? Colors.blue : Colors.transparent,
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
            foregroundColor: isSelected ? Colors.blue : Colors.black,
            backgroundColor: Colors.transparent,
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

  Widget _buildInfoCard(
      BuildContext context,
      String title1,
      String title,
      String value,
      String value1,
      double screenWidth,
      Color valueColor,
      Color valueColor1) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // textAlign: TextAlign.center,
                maxLines: 4,
                value,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    softWrap: true,
                    // textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: AppFont.smallText10(context)),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                // textAlign: TextAlign.center,
                maxLines: 4,
                value1,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor1),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(title1,
                    softWrap: true,
                    // textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: AppFont.smallText10(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Info Card for Left Columns
  Widget _buildInfoCard1(BuildContext context, String title, String value,
      double screenWidth, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 4,
            value,
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w700, color: valueColor),
          ),
          const SizedBox(
            width: 10,
          ),
          // Using Container instead of Expanded for Title Text
          Expanded(
            child: Text(title,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700])),
          ),
          // The value text
        ],
      ),
    );
  }

  // Widget _buildInfoCard1(BuildContext context, String title, String value,
  //     double screenWidth, Color valueColor) {
  //   return Align(
  //     alignment: Alignment.center,
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.all(screenWidth * 0.04),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Container(
  //             decoration:
  //                 BoxDecoration(border: Border.all(color: Colors.transparent)),
  //             child: Expanded(
  //               child: Text(
  //                 title,
  //                 softWrap: true,
  //                 // textAlign: TextAlign.center,
  //                 overflow: TextOverflow.ellipsis,
  //                 maxLines: 4,
  //                 style: GoogleFonts.poppins(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w400,
  //                     color: Colors.grey[700]),
  //               ),
  //             ),
  //           ),
  //           // const SizedBox(height: 5),
  //           Text(
  //             softWrap: true,
  //             overflow: TextOverflow.ellipsis,
  //             textAlign: TextAlign.center,
  //             maxLines: 4,
  //             value,
  //             style: GoogleFonts.poppins(
  //                 fontSize: 24, fontWeight: FontWeight.w700, color: valueColor),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Right Info Card
  Widget _buildRightInfoCard(BuildContext context, String title, String head,
      String value, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700]),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.w700, color: Colors.blue),
          ),
          const SizedBox(height: 5),
          Text(
            head,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildRightInfoCard2(BuildContext context, String title, String head,
      String value, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.w700, color: Colors.blue),
          ),
          const SizedBox(height: 5),
          Text(
            head,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700]),
          ),
          // const SizedBox(height: 15),
          // const Align(
          //   alignment: Alignment.centerRight,
          //   child: Text(
          //     '⏰',
          //     style: TextStyle(fontSize: 20),
          //   ),
          // )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/font/font.dart';

// class Leads extends StatefulWidget {
//   const Leads({super.key});

//   @override
//   State<Leads> createState() => _LeadsState();
// }

// class _LeadsState extends State<Leads> {
//   int _childButtonIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     // Get screen width and height for responsiveness
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Column(
//       children: [
//         // Row with Buttons and Enquiry Bank
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Buttons with Fixed Width
//               Container(
//                 width: screenWidth * 0.45, // Adjust width if needed
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Row(
//                   children: [
//                     _buildButton('MTD', 0),
//                     _buildButton('QTD', 1),
//                     _buildButton('YTD', 2),
//                   ],
//                 ),
//               ),

//               // Enquiry Bank
//               Container(
//                 width: MediaQuery.of(context).size.width * .42,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   mainAxisSize: MainAxisSize.min, // Keep it compact
//                   children: [
//                     Text(
//                       'Enquiry bank',
//                       style: AppFont.smallText(context),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       '137',
//                       style: AppFont.smallTextBold(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 10),

//         IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment:
//                 CrossAxisAlignment.stretch, // Ensures same height
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   margin: const EdgeInsets.only(left: 10),
//                   child: Column(
//                     children: [
//                       _buildInfoCard(
//                         context,
//                         _getLeftCardTitle(_childButtonIndex),
//                         _getLeftCardValue(_childButtonIndex),
//                         screenWidth,
//                         _getGreenCardColor(_childButtonIndex),
//                       ),
//                       const SizedBox(height: 10),
//                       _buildInfoCard(
//                         context,
//                         _getMiddleCardTitle(_childButtonIndex),
//                         _getMiddleCardValue(_childButtonIndex),
//                         screenWidth,
//                         _getRedCardColor(_childButtonIndex),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                   flex: 1,
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 10),
//                     child: _buildInfoCard2(
//                       context,
//                       _getRightCardTitle(_childButtonIndex),
//                       _getRightCardValue(_childButtonIndex),
//                       screenWidth,
//                     ),
//                   )),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//       ],
//     );
//   }
//   // Button Builder
//   Widget _buildButton(String text, int index) {
//     bool isSelected = _childButtonIndex == index;

//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected
//                 ? Colors.blue
//                 : Colors.transparent, // Only selected has blue border
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: TextButton(
//           onPressed: () {
//             setState(() {
//               _childButtonIndex = index;
//             });
//           },
//           style: TextButton.styleFrom(
//             foregroundColor: isSelected
//                 ? Colors.blue
//                 : Colors.black, // Selected text blue, others black
//             backgroundColor: Colors.transparent, // No background color change
//             padding: const EdgeInsets.symmetric(vertical: 5),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           child: Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: isSelected ? Colors.blue : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Small Info Cards
//   Widget _buildInfoCard(BuildContext context, String title, String value,
//       double screenWidth, Color valueColor) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//                 fontSize: 30, fontWeight: FontWeight.w700, color: valueColor),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               title,
//               softWrap: true,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 4,
//               style: GoogleFonts.poppins(
//                   fontSize: 14, fontWeight: FontWeight.w400),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Large Info Card
//   Widget _buildInfoCard2(
//       BuildContext context, String title, String value, double screenWidth) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.inter(
//                 fontSize: 30, fontWeight: FontWeight.w700, color: Colors.blue),
//           ),
//           // const SizedBox(height: 2),
//           Text(
//             value,
//             style: AppFont.dropDowmLabel(context),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           const Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 textAlign: TextAlign.center,
//                 '😍',
//                 style:
//                     TextStyle(fontSize: 20, fontFamily: 'YourAppleEmojiFont'),
//               ))
//         ],
//       ),
//     );
//   }

//   // Dynamic Titles and Values for Each Selected Button
//   String _getLeftCardTitle(int index) {
//     switch (index) {
//       case 0:
//         return 'Current month new enquiries';
//       case 1:
//         return 'Current quarter new enquiries';
//       case 2:
//         return 'Current year new enquiries';
//       default:
//         return '';
//     }
//   }

//   String _getLeftCardValue(int index) {
//     switch (index) {
//       case 0:
//         return '5';
//       case 1:
//         return '50';
//       case 2:
//         return '120';
//       default:
//         return '';
//     }
//   }

//   Color _getGreenCardColor(int index) {
//     switch (index) {
//       case 0:
//         return Colors.green; // Color for MTD
//       case 1:
//         return Colors.green; // Color for QTD
//       case 2:
//         return Colors.green; // Color for YTD
//       default:
//         return Colors.black; // Default color
//     }
//   }

//   Color _getRedCardColor(int index) {
//     switch (index) {
//       case 0:
//         return Colors.red; // Color for MTD
//       case 1:
//         return Colors.red; // Color for QTD
//       case 2:
//         return Colors.red; // Color for YTD
//       default:
//         return Colors.black; // Default color
//     }
//   }

//   String _getMiddleCardTitle(int index) {
//     switch (index) {
//       case 0:
//         return 'Enquiries lost';
//       case 1:
//         return 'Enquiries lost';
//       case 2:
//         return 'Enquiries lost';
//       default:
//         return '';
//     }
//   }

//   String _getMiddleCardValue(int index) {
//     switch (index) {
//       case 0:
//         return '8';
//       case 1:
//         return '40';
//       case 2:
//         return '100';
//       default:
//         return '';
//     }
//   }

//   String _getRightCardTitle(int index) {
//     switch (index) {
//       case 0:
//         return '45';
//       case 1:
//         return '100';
//       case 2:
//         return '350';
//       default:
//         return '';
//     }
//   }

//   String _getRightCardValue(int index) {
//     switch (index) {
//       case 0:
//         return 'More Enquiry to achieve your target';
//       case 1:
//         return 'More Enquiry to achieve your target';
//       case 2:
//         return 'More Enquiry to achieve your target';
//       default:
//         return '';
//     }
//   }
// }
