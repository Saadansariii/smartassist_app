import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTeams extends StatefulWidget {
  const MyTeams({super.key});

  @override
  State<MyTeams> createState() => _MyTeamsState();
}

class _MyTeamsState extends State<MyTeams> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1380FE),
        title: Text(
          'My Team',
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }
}
