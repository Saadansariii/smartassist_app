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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/Leads/single_id_screens/single_leads.dart';

class Feedbackscreen extends StatefulWidget {
  // final String eventId;
  final String leadId;
  const Feedbackscreen({super.key, required this.leadId});

  @override
  State<Feedbackscreen> createState() => _FeedbackscreenState();
}

class _FeedbackscreenState extends State<Feedbackscreen> {
  String _selectedType = '';

  // Maps to store ratings for each category
  Map<String, int> ratings = {
    'Overall Ambience': 0,
    'Features': 0,
    'Ride and comfort': 0,
    'Quality': 0,
    'Dynamics': 0,
    'Driving Experience': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
        ),
        title: Text('Feedback form', style: AppFont.appbarfontWhite(context)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Rate your driving experience',
                  style: AppFont.popupTitleBlack16(context)),
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

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                'Potential of purchase',
                style: AppFont.popupTitleBlack16(context),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: _buildButtons(
                    label: '',
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    // SingleLeadsById(leadId: widget.leadId)
                                    FollowupsDetails(leadId: widget.leadId)));
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
                  color: index < rating ? Colors.amber : Colors.grey,
                  size: 38,
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
