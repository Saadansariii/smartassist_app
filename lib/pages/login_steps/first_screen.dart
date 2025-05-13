import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/pages/login_steps/second_screen.dart';
import 'package:smart_assist/services/email_srv.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/button.dart';
import 'package:smart_assist/utils/paragraph_text.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/utils/style_text.dart';

class EmailSetupScreen extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const EmailSetupScreen({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<EmailSetupScreen> createState() => _EmailSetupScreenState();
}

class _EmailSetupScreenState extends State<EmailSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Constants
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 10.0;
  static const double _borderRadius = 10.0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(_horizontalPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderImage(),
                    _buildTitleSection(),
                    _buildEmailInput(),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      child: Image.asset(
        'assets/login_img.png',
        width: 250,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: _verticalPadding),
          child: StyleText('Set Your Email'),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: ParagraphText(
            'In order to keep your account safe, you need to create a strong password.',
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
          child: Text(
            'Email',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.fontColor,
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _emailController,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xffF3F9FF),
            filled: true,
            hintText: 'Enter Email ID',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.fontColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0276FE),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 4,
          shadowColor: AppColors.colorsBlue.withOpacity(0.4),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Button(
                'Next Step',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleEmailVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await LeadsSrv.verifyEmail({
        "email": _emailController.text.trim(),
      });

      if (!mounted) return;

      if (response['isSuccess'] == true) {
        showSuccessMessage(context, message: 'Email Verified Successfully');
        _navigateToVerifyMail();
      } else {
        showErrorMessage(context,
            message: response['message'] ?? 'Check the Email');
      }
    } catch (error) {
      if (!mounted) return;
      showErrorMessage(
        context,
        message: 'Failed to verify email. Please try again later.',
      );
      debugPrint('Email verification error: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToVerifyMail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          email: _emailController.text.trim(),
          text: '',
        ),
      ),
    );
  }
}
















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/pages/login/second_screen.dart';
// import 'package:smart_assist/services/email_srv.dart';
// import 'package:smart_assist/utils/button.dart';
// import 'package:smart_assist/utils/paragraph_text.dart';
// import 'package:smart_assist/utils/snackbar_helper.dart';
// import 'package:smart_assist/utils/style_text.dart';

// class SetPwd extends StatefulWidget {
//   final TextStyle? style;
//   final String text;
//   const SetPwd({super.key, this.style, required this.text});

//   @override
//   State<SetPwd> createState() => _SetPwdState();
// }

// class _SetPwdState extends State<SetPwd> {
//   // Controllers for text fields
//   // final TextEditingController _passwordController = TextEditingController();
//   TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Center(
//         child: SafeArea(
//           // Adds safe area to prevent bottom inset issues
//           child: SingleChildScrollView(
//             // Allows scrolling when keyboard appears
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 child: Column( 
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     // Image
//                     Image.asset(
//                       'assets/login_img.png',
//                       width: 250,
//                     ),

//                     // Title
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       child: StyleText('Set Your Email'),
//                     ),

//                     // Subtitle
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                       child: ParagraphText(
//                         'In order to keep your account safe, you need to create a strong password.',
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                       ),
//                     ),

//                     // const Row(
//                     //   children: [
//                     //     Padding(
//                     //         padding: EdgeInsets.fromLTRB(6, 20, 0, 0),
//                     //         child: Text('Email'))
//                     //   ],
//                     // ),
//                     // // Password TextField
//                     // Padding(
//                     //   padding: const EdgeInsets.symmetric(vertical: 10),
//                     //   child: TextFormField(
//                     //     controller: emailController,
//                     //     decoration: InputDecoration(
//                     //       hintText: 'Enter Email ID',
//                     //       border: OutlineInputBorder(
//                     //         borderRadius: BorderRadius.circular(10),
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),

//                     Row(
//                       children: [
//                         SizedBox(
//                           height: 5,
//                           width: 5,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
//                           child: Text(
//                             'Email',
//                             style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColors.fontColor),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 5,
//                     ),
//                     // Password TextField
//                     TextField(
//                       style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black),
//                       // controller: _passwordController,
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         fillColor: Color(0xffF3F9FF),
//                         filled: true,
//                         hintText: 'Enter Email ID', // Only placeholder text
//                         // fillColor: Colors.grey,
//                         hintStyle: GoogleFonts.poppins(
//                             color: AppColors.fontColor,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400),
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),

//                     // Next Step Button
//                     // Padding(
//                     //   padding: const EdgeInsets.symmetric(vertical: 16),
//                     //   child: ElevatedButton(

//                     //     onPressed: verifyEmail,
//                     //     style: ElevatedButton.styleFrom(
//                     //       backgroundColor: const Color(0xFF0276FE),
//                     //       foregroundColor: Colors.white,
//                     //       minimumSize: const Size(double.infinity, 50),
//                     //       shape: RoundedRectangleBorder(
//                     //         borderRadius: BorderRadius.circular(10),
//                     //       ),
//                     //       elevation: 4,
//                     //       shadowColor: AppColors.colorsBlue.withOpacity(0.4),
//                     //     ),
//                     //     child:   Button('Next Step' ),
//                     //   ),
//                     // ),

//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: ElevatedButton(
//                         onPressed: verifyEmail,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0276FE),
//                           foregroundColor: Colors.white,
//                           minimumSize: const Size(double.infinity, 50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 4,
//                           shadowColor: AppColors.colorsBlue.withOpacity(0.4),
//                         ),
//                         child: Button(
//                           'Next Step',
//                           style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight:
//                                   FontWeight.w500), // Set font size here
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> verifyEmail() async {
//     final email = emailController.text;
//     final body = {"email": email};

//     try {
//       final response = await EmailService.verifyEmail(body);

//       if (response['isSuccess'] == true) {
//         print('API hit successful: ${response['data']}');
//         showSuccessMessage(context, message: 'Email Verified Successfully');

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VerifyMail(
//               email: emailController.text,
//               text: '',
//             ),
//           ),
//         );
//       } else {
//         print('API hit failed: ${response['data']}');
//         showErrorMessage(context, message: 'Check the Email');
//       }
//     } catch (error) {
//       // Handle unexpected errors
//       print('Unexpected error: $error');
//       showErrorMessage(context, message: 'Error during API call');
//     }
//   }
// }
