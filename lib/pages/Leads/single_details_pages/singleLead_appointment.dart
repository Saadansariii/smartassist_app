// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/services/leads_srv.dart';

// class AppointmentUpcoming extends StatefulWidget {
//   final String leadId;
//   const AppointmentUpcoming({
//     super.key,
//     required this.leadId,
//   });

//   @override
//   State<AppointmentUpcoming> createState() => _AppointmentUpcomingState();
// }

// class _AppointmentUpcomingState extends State<AppointmentUpcoming> {
//   // Placeholder data
//   String phoneNumber = '';
//   String email = '';
//   String status = '';
//   String company = '';
//   String address = '';
//   String assign = '';

//   int _activeButtonIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchSingleIdData(widget.leadId); // Fetch data when widget is initialized
//   }

//   Future<void> fetchSingleIdData(String leadId) async {
//     try {
//       final leadData = await LeadsSrv.singleFollowupsById(leadId);
//       setState(() {
//         phoneNumber = leadData['mobile'] ?? 'N/A';
//         email = leadData['lead_email'] ?? 'N/A';
//         status = leadData['status'] ?? 'N/A';
//         company = leadData['company'] ?? 'N/A';
//         address = leadData['address'] ?? 'N/A';
//         assign = leadData['assigned_to'] ?? 'N/A';
//       });
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }

//   // Helper method to build ContactRow widget
//   Widget _buildContactRow(
//       {required IconData icon,
//       required String title,
//       required String subtitle}) {
//     return ContactRow(
//       icon: icon,
//       title: title,
//       subtitle: subtitle,
//       eventId: widget.leadId,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Events Details',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w400,
//             color: Color.fromARGB(255, 134, 134, 134),
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.grey),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 // Main Container with Flexbox Layout
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 247, 243, 243),
//                     border: Border.all(color: Colors.black.withOpacity(0.2)),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Left Side - Contact Details
//                       Expanded(
//                         flex: 2,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildContactRow(
//                                 icon: Icons.phone,
//                                 title: 'Phone Number',
//                                 subtitle: phoneNumber),
//                             _buildContactRow(
//                                 icon: Icons.email,
//                                 title: 'Email',
//                                 subtitle: email),
//                             _buildContactRow(
//                                 icon: Icons.local_post_office_outlined,
//                                 title: 'Company',
//                                 subtitle: status),
//                             _buildContactRow(
//                                 icon: Icons.location_on,
//                                 title: 'Address',
//                                 subtitle: address),
//                           ],
//                         ),
//                       ),
//                       // Right Side - Profile (Centered)
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.person, size: 50),
//                             SizedBox(height: 8),
//                             Text(
//                               assign,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/whatsapp.png',
//                                   width: 30,
//                                   height: 30,
//                                   semanticLabel: 'WhatsApp Icon',
//                                 ),
//                                 SizedBox(width: 10),
//                                 Image.asset(
//                                   'assets/redirect_msg.png',
//                                   width: 30,
//                                   height: 30,
//                                   semanticLabel: 'Redirect Message Icon',
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20), // Spacer
//                 // History Section
//                 Text(
//                   'History',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Text(
//                     'No History available Now..!',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ContactRow extends StatefulWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String eventId;

//   const ContactRow({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.eventId, // Pass taskId here
//   });

//   @override
//   State<ContactRow> createState() => _ContactRowState();
// }

// class _ContactRowState extends State<ContactRow> {
//   String phoneNumber = 'Loading...';
//   String email = 'Loading...';
//   String status = 'Loading...';
//   String company = 'Loading...';
//   String address = 'Loading...';
//   String assign = 'Loading...';

//   @override
//   void initState() {
//     super.initState();
//     fetchSingleIdData(widget.eventId); // Fetch data when widget is initialized
//   }

//   Future<void> fetchSingleIdData(String eventId) async {
//     try {
//       final leadData = await LeadsSrv.singleAppointmentById(eventId);
//       setState(() {
//         phoneNumber = leadData['mobile'] ?? 'N/A';
//         email = leadData['lead_email'] ?? 'N/A';
//         status = leadData['status'] ?? 'N/A';
//         company = leadData['company'] ?? 'N/A';
//         address = leadData['address'] ?? 'N/A';
//         assign = leadData['assigned_to'] ?? 'N/A';
//       });
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(
//             widget.icon,
//             size: 30,
//             color: Colors.blue,
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               Text(
//                 widget.subtitle,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
