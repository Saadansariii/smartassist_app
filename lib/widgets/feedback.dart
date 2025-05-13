// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/config/component/font/font.dart';
// import 'package:smart_assist/pages/Leads/single_id_screens/single_leads.dart';

// class Feedbackscreen extends StatefulWidget {
//   // final String eventId;
//   const Feedbackscreen({super.key, v});

//   @override
//   State<Feedbackscreen> createState() => _FeedbackscreenState();
// }

// class _FeedbackscreenState extends State<Feedbackscreen> {
//   String _selectedType = '';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(
//             FontAwesomeIcons.angleLeft,
//             color: Colors.white,
//           ),
//         ),
//         title: Text('Feedback form', style: AppFont.appbarfontWhite(context)),
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Column(
//               children: [

//               ],
//             ),

//             Row(
//               children: [
//                 Expanded(
//                   child: _buildButtons(
//                     label: 'Potential of purchase',
//                     options: {
//                       "Definitely": "Definitely",
//                       "Very Likely": "Very Likely",
//                       "Likely": "Likely",
//                       "Not Likely": "Not Likely"
//                     },
//                     groupValue: _selectedType,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedType = value;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             elevation: 0,
//                             backgroundColor:
//                                 const Color.fromRGBO(217, 217, 217, 1),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5))),
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Cancel", style: AppFont.buttons(context))),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.colorsBlue,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5))),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     SingleLeadsById(leadId: '')));
//                       },
//                       child: Text("Submit", style: AppFont.buttons(context)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButtons({
//     required Map<String, String> options, // ✅ Short display & actual value
//     required String groupValue,
//     required String label,
//     required ValueChanged<String> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
//             child: Text(label, style: AppFont.dropDowmLabel(context)),
//           ),
//         ),
//         const SizedBox(height: 5),

//         // ✅ Wrap ensures buttons move to next line when needed
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0),
//           child: Wrap(
//             spacing: 5, // Space between buttons
//             runSpacing: 10, // Space between lines
//             children: options.keys.map((shortText) {
//               bool isSelected =
//                   groupValue == options[shortText]; // ✅ Compare actual value

//               return GestureDetector(
//                 onTap: () {
//                   onChanged(
//                       options[shortText]!); // ✅ Pass actual value on selection
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isSelected ? Colors.blue : Colors.black,
//                       width: .5,
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     // color: isSelected
//                     //     ? Colors.blue.withOpacity(0.2)
//                     //     : AppColors.innerContainerBg,
//                   ),
//                   child: Text(
//                     shortText, // ✅ Only show short text
//                     style: TextStyle(
//                       color: isSelected ? Colors.blue : Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),

//         const SizedBox(height: 5),
//       ],
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/home/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/home/single_id_screens/single_leads.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_assist/widgets/testdrive_overview.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Feedbackscreen extends StatefulWidget {
  final String eventId;
  final String leadId;
  const Feedbackscreen(
      {super.key, required this.leadId, required this.eventId});

  @override
  State<Feedbackscreen> createState() => _FeedbackscreenState();
}

class _FeedbackscreenState extends State<Feedbackscreen> {
  String _selectedType = '';
  String _selectedDateType = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Maps to store ratings for each category
  Map<String, int> ratings = {
    'Overall Ambience': 0,
    'Features': 0,
    'Ride and comfort': 0,
    'Quality': 0,
    'Dynamics': 0,
    'Driving Experience': 0,
  };

  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
        showErrorMessage(context,
            message: 'Speech recognition error: ${errorNotification.errorMsg}');
      },
    );
    if (!available) {
      showErrorMessage(context,
          message: 'Speech recognition not available on this device');
    }
  }

  // Toggle listening
  void _toggleListening(TextEditingController controller) async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> submitFeedback() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? spId = prefs.getString('user_id');
      final url = Uri.parse(
          'https://dev.smartassistapp.in/api/events/submit-feedback/${widget.eventId}');
      final token = await Storage.getToken();

      // Create the request body
      final requestBody = {
        'sp_id': spId,
        'purchase_potential': _selectedType,
        'feedback_comments': descriptionController.text,
        "drive_feedback": {
          'ambience': ratings['Overall Ambience'],
          'features': ratings['Features'],
          'ride_comfort': ratings['Ride and comfort'],
          'quality': ratings['Quality'],
          'dynamics': ratings['Dynamics'],
          'driving_experience': ratings['Driving Experience'],
        },
        'time_frame': _selectedDateType
      };

      // Print the data to console for debugging
      print('Submitting feedback data:');
      print(requestBody);

      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestBody));

      // Print the response
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Success handling
        print('Feedback submitted successfully');
        Get.snackbar(
          'Success',
          'Feedback submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TestdriveOverview(
              leadId: widget.leadId,
              eventId: widget.eventId,
            ),
          ),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TestdriveOverview(
        //         leadId: widget.leadId, eventId: widget.eventId),
        //   ),
        // );
      } else {
        // Error handling
        // print('Failed to submit feedback');
        Get.snackbar(
          'Error',
          'Failed to submit feedback',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Exception handling
      print('Exception occurred: ${e.toString()}');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontBlack,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              // Expanded TextField that adjusts height
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines:
                      null, // This allows the TextField to expand vertically based on content
                  minLines: 1, // Minimum 1 line of height
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              // Microphone icon with speech recognition
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _toggleListening(controller),
                  icon: Icon(
                    _isListening
                        ? FontAwesomeIcons.stop
                        : FontAwesomeIcons.microphone,
                    color: _isListening ? Colors.red : AppColors.fontColor,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () => Get.back(),
        //   icon: const Icon(
        //     FontAwesomeIcons.angleLeft,
        //     color: Colors.white,
        //   ),
        // ),
        title: Text('Test drive Feedback form',
            style: AppFont.appbarfontblack(context)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'On a scale of 1 to 5, 1 begin the lowest and being the highest, how would you rate us on Driving Experience?',
                  style: AppFont.mediumText14Black(context)),
            ),

            // Star rating section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ratings.keys
                  .map((category) => _buildStarRating(
                        category: category,
                        rating: ratings[category]!,
                        onRatingChanged: (rating) {
                          setState(() {
                            ratings[category] = rating;
                          });
                        },
                      ))
                  .toList(),
            ),

            const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            //   child: Text(
            //     'Potential of purchase',
            //     style: AppFont.mediumText14Black(context),
            //   ),
            // ),

            Row(
              children: [
                Expanded(
                  child: _buildButtons(
                    label: 'Potential of purchase',
                    options: {
                      "Definitely": "Definitely",
                      "Very Likely": "Very Likely",
                      "Likely": "Likely",
                      "Not Likely": "Not Likely"
                    },
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            // const SizedBox(
            //   height: 10,
            // ),

            // Padding(
            //   padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            //   child: Text(
            //     'Time frame',
            //     style: AppFont.mediumText14Black(context),
            //   ),
            // ),
            Row(
              children: [
                Expanded(
                  child: _buildButtons(
                    label: 'Time frame',
                    options: {
                      "15 days": "15 days",
                      "15 days - 3 month": "15 days - 3 month",
                      "3 - 6 months": "3 - 6 months",
                      "6 months": "6 months"
                    },
                    groupValue: _selectedDateType,
                    onChanged: (value) {
                      setState(() {
                        _selectedDateType = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildTextField(
                  label: 'Comments:',
                  controller: descriptionController,
                  hint: 'Add Comments'),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                const Color.fromRGBO(217, 217, 217, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: AppFont.buttons(context))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorsBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () {
                        submitFeedback();
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             // SingleLeadsById(leadId: widget.leadId)
                        //             FollowupsDetails(leadId: widget.leadId)));
                      },
                      child: Text("Submit", style: AppFont.buttons(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Star rating widget
  Widget _buildStarRating({
    required String category,
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            category,
            style: AppFont.dropDowmLabel(context),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color:
                      index < rating ? AppColors.starBorderColor : Colors.grey,
                  size: 30,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons({
    required Map<String, String> options,
    required String groupValue,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
              child: Text(label, style: AppFont.dropDowmLabel(context)),
            ),
          ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            children: options.keys.map((shortText) {
              bool isSelected = groupValue == options[shortText];

              return GestureDetector(
                onTap: () {
                  onChanged(options[shortText]!);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        // width: 1,
                        strokeAlign: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? Colors.blue : Colors.white,
                  ),
                  child: Text(
                    shortText,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.fontColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
