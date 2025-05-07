// import 'package:flutter/material.dart';
// import 'package:smart_assist/pages/Leads/home_screen.dart';
// import 'package:smart_assist/pages/test_drive_pages/drive_start.dart';
// import 'package:smart_assist/utils/bottom_navigation.dart';
// import 'package:smart_assist/utils/button.dart';

// class VerifyOtp extends StatefulWidget {
//   const VerifyOtp({super.key});

//   @override
//   State<VerifyOtp> createState() => _VerifyOtpState();
// }

// class _VerifyOtpState extends State<VerifyOtp> {
//   final int _otpLength = 6; // Number of OTP digits
//   final List<TextEditingController> _controllers =
//       List.generate(6, (index) => TextEditingController());

//   @override
//   void dispose() {
//     // Dispose controllers to prevent memory leaks
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => BottomNavigation()));
//             },
//             icon: const Icon(
//               Icons.arrow_back_ios_outlined,
//               color: Colors.white,
//             )),
//         backgroundColor: Colors.blue,
//         title: const Text(
//           'Test Drive',
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
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: Image.asset(
//                 'assets/car.png',
//                 width: 200,
//                 height: 200,
//               ),
//             ),
//             const SizedBox(height: 15),
//             const Text(
//               'Start Test Drive',
//               style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 24,
//                   fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 15),
//             const Text(
//               'Enter OTP sent to user\n@gmail.com to continue',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontWeight: FontWeight.w200,
//                 fontSize: 16,
//                 color: Color.fromARGB(255, 122, 122, 122),
//               ),
//             ),

//             const SizedBox(height: 25),
//             // OTP Input Boxes
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(_otpLength, (index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                   width: 45,
//                   child: TextField(
//                     controller: _controllers[index],
//                     keyboardType: TextInputType.number,
//                     textAlign: TextAlign.center,
//                     maxLength: 1,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     decoration: const InputDecoration(
//                       counterText: '',
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       if (value.isNotEmpty && index < _otpLength - 1) {
//                         FocusScope.of(context).nextFocus(); // Move to next box
//                       } else if (value.isEmpty && index > 0) {
//                         FocusScope.of(context).previousFocus(); // Move back
//                       }
//                     },
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 15),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     const Text("Didn't received the code ?"),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Add resend OTP logic here
//                       },
//                       style: ElevatedButton.styleFrom(
//                         elevation: 0, // No shadow
//                         backgroundColor:
//                             Colors.transparent, // Transparent background
//                         shadowColor: Colors.transparent, // No shadow color
//                         padding: EdgeInsets.zero, // Removes default padding
//                       ),
//                       child: const Text(
//                         'Resend',
//                         style: TextStyle(
//                             color: Colors.blue, // Blue text like a link
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             decoration: TextDecoration.underline,
//                             decorationColor: Colors.blue),
//                       ),
//                     )
//                   ],
//                 )
//               ],
//             ),
//             const SizedBox(height: 15),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: 45,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(
//                             255, 202, 200, 200), // Changed to red for cancel
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: TextButton(
//                         onPressed: () {},
//                         child: const Text('Cancel',
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Container(
//                       height: 45,
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => DriveStart()));
//                         },
//                         child: const Text('Verify',
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
