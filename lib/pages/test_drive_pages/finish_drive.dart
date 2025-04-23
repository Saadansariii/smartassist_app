// import 'package:flutter/material.dart';
// import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
// import 'package:smart_assist/pages/Leads/single_details_pages/test_drive_details.dart';
// import 'package:smart_assist/pages/test_drive_pages/drive_end.dart';

// class FinishDrive extends StatelessWidget {
//   const FinishDrive({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const DriveEnd()));
//               },
//               icon: const Icon(
//                 Icons.arrow_back_ios_outlined,
//                 color: Colors.white,
//               )),
//           backgroundColor: Colors.blue,
//           title: const Text(
//             'Test Drive Started ',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Center(
//                   child: Image.asset(
//                     'assets/car.png',
//                     width: 200,
//                     height: 200,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE8F3FF), // Light blue background
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start, // Align text to the start
//                       children: [
//                         // First Row: From
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text(
//                                 'From :',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 'Kanchpada Mumbai',
//                                 style: TextStyle(),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Divider(
//                           thickness: 0.1,
//                           color: Colors.grey,
//                           indent: 16,
//                           endIndent: 16,
//                         ),

//                         // Second Row: To
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text(
//                                 'To :',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 'Marine Lines',
//                                 style: TextStyle(),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Divider(
//                           thickness: 0.1,
//                           color: Colors.grey,
//                           indent: 16,
//                           endIndent: 16,
//                         ),

//                         // Third Row: Start Time
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text(
//                                 'Start Time :',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 '11:55 AM',
//                                 style: TextStyle(),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Divider(
//                           thickness: 0.1,
//                           color: Colors.grey,
//                           indent: 16,
//                           endIndent: 16,
//                         ),

//                         // Fourth Row: End Time
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text(
//                                 'End Time :',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 '1:00 PM',
//                                 style: TextStyle(),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Divider(
//                           thickness: 0.1,
//                           color: Colors.grey,
//                           indent: 16,
//                           endIndent: 16,
//                         ),

//                         // Fifth Row: Total Time
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 10.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Text(
//                                 'Total Time :',
//                                 style: TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               Text(
//                                 '30 min',
//                                 style: TextStyle(),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 70,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         height: 45,
//                         width: 150,
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: TextButton(
//                           // onPressed: () {
//                           //   Navigator.push(
//                           //     context,
//                           //     MaterialPageRoute(
//                           //         builder: (context) => TestDriveDetails()),
//                           //   );
//                           // },
//                           onPressed: () {  },
//                           child: const Text(
//                             'Finish',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ]),
//         ));
//   }
// }
