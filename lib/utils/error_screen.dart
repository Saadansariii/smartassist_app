import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:get/get.dart'; // Make sure to import get

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Session expired please log in again.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              if (error.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Use Get.offAll to navigate and remove all previous routes
                  Get.offAll(
                    () => LoginPage(
                      email: '',
                      onLoginSuccess: () {},
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Login again',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
