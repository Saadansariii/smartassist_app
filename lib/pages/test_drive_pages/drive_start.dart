// import 'package:flutter/material.dart';
// import 'package:smart_assist/pages/Leads/home_screen.dart';
// import 'package:smart_assist/pages/test_drive_pages/drive_end.dart';
// import 'package:smart_assist/pages/test_drive_pages/verify_otp.dart';

// class DriveStart extends StatelessWidget {
//   const DriveStart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const VerifyOtp()));
//               },
//               icon: const Icon(
//                 Icons.arrow_back_ios_outlined,
//                 color: Colors.white,
//               )),
//           backgroundColor: Colors.blue,
//           title: const Text(
//             'Test Drive Started',
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
//                 Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                         child: Container(
//                             width: double.infinity,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 209, 237,
//                                   252), // Changed to red for cancel
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 150,
//                                   child: const Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Row(
//                                         children: [Text('from :')],
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [Text('Start Time :')],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 //  Padding(
//                                 //     padding: const EdgeInsets.symmetric(
//                                 //         horizontal: 10.0),
//                                 //     child: Container(
//                                 //       width: 100,
//                                 //       decoration: const BoxDecoration(
//                                 //         border: Border(
//                                 //           bottom: BorderSide(
//                                 //             color: Colors.black, // Border color
//                                 //             width: 1.0, // Border thickness
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     ),
//                                 //   ),

//                                 Container(
//                                   width: 150,
//                                   child: const Column(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceEvenly,
//                                     crossAxisAlignment: CrossAxisAlignment
//                                         .start, // Align content to the start
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment
//                                             .start, // Align text to the start
//                                         children: [Text('Kachpada Mumbai')],
//                                       ),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment
//                                             .start, // Align text to the start
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [Text('7:30 AM')],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             )),
//                       ),
//                     ]),
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
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => DriveEnd()),
//                             );
//                           },
//                           child: const Text(
//                             'End Test Drive',
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
