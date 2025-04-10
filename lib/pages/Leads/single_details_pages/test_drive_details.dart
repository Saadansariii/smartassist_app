// import 'package:flutter/material.dart'; 
// import 'package:smart_assist/utils/bottom_navigation.dart';
// import 'package:smart_assist/widgets/details/testdrive_details.dart';
// import 'package:smart_assist/widgets/timeline/timeline_tasks.dart'; 
// import 'package:smart_assist/widgets/timeline/timeline_nine_wid.dart'; 
// import 'package:smart_assist/widgets/timeline/timeline_events.dart'; 
// import 'package:smart_assist/widgets/timeline/timeline_ten_wid.dart'; 

// class TestDriveDetails extends StatefulWidget {
//   const TestDriveDetails({super.key});

//   @override
//   State<TestDriveDetails> createState() => _TestDriveDetailsState();
// }

// class _TestDriveDetailsState extends State<TestDriveDetails> {
//   List<Map<String, dynamic>> allEvents = []; // ✅ Define allEvents
//   List<Map<String, dynamic>> allTestDrive = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 239, 235, 235),
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => BottomNavigation()));
//           },
//           icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
//         ),
//         backgroundColor: Colors.blue,
//         title: const Text(
//           'Test Drive Details',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.search, color: Colors.white),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.add, color: Colors.white),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             const TestdriveDetailsWidget(),
//             const SizedBox(height: 30),
//             // Second widget
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const TimelineTenWid(),
//                   const SizedBox(
//                     height: 10,
//                   ),

//                   // timeline 2 Tira
//                   TimelineNineWid(testDrive: allTestDrive),
//                   // 22oct
//                   TimelineEightWid(events: allEvents),
//                   // first column first
//                   TimelineSevenWid(
//                     events: allEvents,
//                   ),
// //                   const TimelineSixWid(),
// //                   const TimelineFiveWid(),
// //                   // third
// //                   const TimelineFourWid(),
// // // add
// //                   const TimelineOneWidget(),
// //                   const TimelineTwoWid(),
// //                   const TimelineTheeWid()
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
