import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TestdriveDetailsWidget extends StatefulWidget {
  const TestdriveDetailsWidget({super.key});

  @override
  State<TestdriveDetailsWidget> createState() => _TestdriveDetailsWidgetState();
}

class _TestdriveDetailsWidgetState extends State<TestdriveDetailsWidget> {
  final List<Map<String, String>> details = [
    {
      'image': 'assets/whatsappicon.png',
      'title': 'WhatsApp Number',
      'subtitle': '367364746838'
    },
    {
      'image': 'assets/mail.png',
      'title': 'Email',
      'subtitle': 'Tira@gmail.com'
    },
    {
      'image': 'assets/companybag.png',
      'title': 'Company',
      'subtitle': 'Land Rover'
    },
    {
      'image': 'assets/location.png',
      'title': 'Address',
      'subtitle': 'Kanchpada, Malad West, India - 400064'
    },
    {
      'image': 'assets/caricon.png',
      'title': 'Car',
      'subtitle': 'Range Rover Evoque'
    },
    {
      'image': 'assets/calandericon.png',
      'title': 'Date',
      'subtitle': '2024-08-01'
    },
    // {'image': 'assets/time.png', 'title': 'Time', 'subtitle': '12:48'},
  ];

  Widget buildDetailRow(
      String imagePath, String title, String subtitle, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 30, height: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0x8F423F3F))),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 1),
                if (!isLast)
                  const Divider(
                      color: Color.fromARGB(255, 231, 230, 230), thickness: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(Icons.person),
            // const CircleAvatar(
            //   radius: 40,
            //   // backgroundImage: AssetImage('assets/profile.png'),
            // ),
            const SizedBox(height: 3),
            Text('Tira',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2E2E30))),
            // Iterate over the details list and pass the correct 'isLast' value
            for (int i = 0; i < details.length; i++)
              buildDetailRow(
                details[i]['image']!,
                details[i]['title']!,
                details[i]['subtitle']!,
                i == details.length - 1, // Last item check
              ),
          ],
        ),
      ),
    );
  }
}
