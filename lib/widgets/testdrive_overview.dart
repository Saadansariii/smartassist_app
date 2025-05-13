import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
// import 'package:smart_assist/pages/home/single_details_pages/singleLead_followup.dart';
import 'dart:convert';

import 'package:smart_assist/utils/storage.dart';

class TestdriveOverview extends StatefulWidget {
  final String eventId;
  final String leadId;
  const TestdriveOverview(
      {super.key, required this.eventId, required this.leadId});

  @override
  State<TestdriveOverview> createState() => _TestdriveOverviewState();
}

class _TestdriveOverviewState extends State<TestdriveOverview> {
  // Define variables to hold the data
  bool _isHidden = false;
  String startTime = '';
  String distanceCovered = '';
  String mapImgUrl = '';
  bool isLoading = true;
  String potentialPurchase = '';
  String purchase_potential = '';
  String avg_rating = '';
  Map<String, dynamic> ratings = {};

  @override
  void initState() {
    super.initState();
    _fetchTestDriveData();
  }

  Future<void> _fetchTestDriveData() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse('https://dev.smartassistapp.in/api/events/${widget.eventId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded JSON:');
        print(const JsonEncoder.withIndent('  ').convert(data));
        setState(() {
          startTime = data['data']['duration'];
          distanceCovered = data['data']['distance'] + ' km';
          mapImgUrl = data['data']['map_img'] ?? '';
          potentialPurchase = data['data']['purchase_potential'];
          purchase_potential = data['data']['purchase_potential'];
          // avg_rating = data['data']['avg_rating'].toString();
          avg_rating = double.parse(data['data']['avg_rating'].toString())
              .toStringAsFixed(1);

          ratings = data['data']['drive_feedback'];
          isLoading = false;
        });
        print('this is sthe data');
        print(data);
      } else {
        setState(() {
          isLoading =
              false; // If there is an error, stop loading and show content
        });
        print(
            'Failed to fetch test drive data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if there is an error
      });
      // Handle different types of errors (network, JSON, etc.)
      print('Error fetching test drive data: $e');
      // Optionally, you can also show an error message to the user
    }
  }

  String formatTime(String startTime) {
    try {
      DateFormat inputFormat = DateFormat(
          "HH:mm"); // Assuming startTime is in "24-hour" format (e.g., "12:12")
      DateTime time = inputFormat.parse(startTime);
      DateFormat outputFormat =
          DateFormat("hh:mm a"); // Converts to 12-hour format with AM/PM
      return outputFormat.format(time);
    } catch (e) {
      return "Invalid time"; // Handle if input is not in the expected format
    }
  }

  String getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Below Average';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = formatTime(startTime);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Test Drive summary',
              style: AppFont.popupTitleWhite(context)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FollowupsDetails(leadId: widget.leadId)));
              // MaterialPageRoute(
              //     builder: (context) => FollowupsDetails(leadId: widget.leadId));
            },
          ),
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: AppColors.backgroundLightGrey,
                body: Container(
                  width: double.infinity, // ✅ Ensures full width
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLightGrey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Map

                          const SizedBox(height: 30),

                          // Your main display section
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(avg_rating,
                                                      style: AppFont
                                                          .popupTitleBlack(
                                                              context)),
                                                  const Icon(
                                                    Icons.star_rounded,
                                                    color: AppColors
                                                        .starBorderColor,
                                                    size: 20,
                                                  )
                                                ],
                                              ),
                                              Text(
                                                  getRatingLabel(
                                                      double.tryParse(
                                                              avg_rating) ??
                                                          0),
                                                  style: AppFont.mediumText14(
                                                      context)),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Potential of Purchase',
                                                  style: AppFont.dropDowmLabel(
                                                      context)),
                                              Text(potentialPurchase,
                                                  style:
                                                      AppFont.mediumText14blue(
                                                          context)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: [
                                          _buildRatingRow('Overall Ambience',
                                              ratings['ambience']),
                                          _buildRatingRow(
                                              'Features', ratings['features']),
                                          _buildRatingRow('Ride and Comfort',
                                              ratings['ride_comfort']),
                                          _buildRatingRow(
                                              'Quality', ratings['quality']),
                                          _buildRatingRow(
                                              'Dynamics', ratings['dynamics']),
                                          _buildRatingRow('Driving Experience',
                                              ratings['driving_experience']),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Start time
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: AppColors
                                                  .backgroundLightGrey),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              FontAwesomeIcons.clock,
                                              size: 20,
                                              color: AppColors.colorsBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Duration',
                                            style:
                                                AppFont.dropDowmLabel(context)),
                                        Text(startTime,
                                            style:
                                                AppFont.mediumText14(context)),
                                      ],
                                    ),
                                  ],
                                ),
                                // const SizedBox(width: 5),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: AppColors
                                                  .backgroundLightGrey),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              FontAwesomeIcons.locationDot,
                                              size: 20,
                                              color: AppColors.colorsBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Text('Distance covered',
                                              style: AppFont.mediumText14Black(
                                                  context)),
                                        ),
                                        Text(distanceCovered,
                                            style:
                                                AppFont.mediumText14(context)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        'Map',
                                        style:
                                            AppFont.popupTitleBlack16(context),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isHidden = !_isHidden;
                                          });
                                        },
                                        icon: Icon(
                                          _isHidden
                                              ? Icons
                                                  .keyboard_arrow_down_rounded
                                              : Icons.keyboard_arrow_up_rounded,
                                          size: 30, color: AppColors.fontColor,
                                          // style: AppFont.smallText(context),
                                        )),
                                  ],
                                ),
                                if (!_isHidden) ...[
                                  if (mapImgUrl.isNotEmpty)
                                    Column(
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: Image.network(mapImgUrl)),
                                      ],
                                    ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  // Helper method to build the rating rows
  // Widget _buildRatingRow(String label, int? rating) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text('$label: ', style: AppFont.dropDowmLabel(context)),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       IconTheme(
  //         data: IconThemeData(color: Colors.amber),
  //         child: Row(
  //           children: List.generate(5, (index) {
  //             return Icon(
  //               index < (rating ?? 0)
  //                   ? Icons.star_rounded
  //                   : Icons.star_outline_rounded,
  //               size: 30,
  //             );
  //           }),
  //         ),
  //       ),
  //     ],
  //   );
  // }

// Helper method to build the rating row with stars and emojis

  Widget _buildRatingRow(String label, int? rating) {
    // List of emojis corresponding to each rating level
    final List<String> emojiRatings = [
      '😔', // For 1 star
      '🙁', // For 2 stars
      '🙂', // For 3 stars
      '😃', // For 4 stars
      '😍', // For 5 stars
    ];

    // // Ensure that rating falls within a valid range (1 to 5)
    // int validRating = (rating ?? 0).clamp(1, 5);

    // Fix rating properly
    int validRating =
        (rating != null && rating >= 1 && rating <= 5) ? rating : 0;

    // Calculate the percentage for the progress bar
    double percentage = (validRating / 5.0); // rating out of 5 stars

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rating label
          Text('$label', style: AppFont.smallText(context)),

          // const Row(
          //   children: [
          //     Icon(
          //       Icons.star_rounded,
          //       size: 20,
          //       color: Colors.amber,
          //     )
          //   ],
          // ),
          // The progress line using LinearPercentIndicator
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: LinearPercentIndicator(
                  lineHeight: 8.0, // Height of the progress line
                  percent: percentage, // Fill percentage
                  backgroundColor:
                      Colors.grey[300]!, // Background color for the line
                  progressColor:
                      Colors.amber, // Color for the filled portion of the line
                  barRadius: Radius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child:
                    Text(' $validRating', style: AppFont.mediumText14(context)),
              ),
            ],
          ),

          // Emoji corresponding to the rating level
          // Padding(
          //   padding: const EdgeInsets.only(left: 0),
          //   child: Text(
          //     emojiRatings[
          //         validRating - 1], // Adjust emoji index based on rating
          //     style: const TextStyle(fontSize: 15),
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.only(left: 0),
          //   child: Text(
          //     validRating > 0
          //         ? emojiRatings[validRating - 1]
          //         : '', // ✅ Safe check
          //     style: const TextStyle(fontSize: 15),
          //   ),
          // ),

          // Static stars (5 stars)
        ],
      ),
    );
  }
}
