import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/services/set_pwd_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/utils/style_text.dart';

class ForgetPasswordSetups extends StatefulWidget {
  final String email;
  final String text;
  final TextStyle? style;

  const ForgetPasswordSetups({
    super.key,
    required this.email,
    required this.text,
    this.style,
  });

  @override
  State<ForgetPasswordSetups> createState() => _ForgetPasswordSetupsState();
}

class _ForgetPasswordSetupsState extends State<ForgetPasswordSetups>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/login_img.png',
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: StyleText('Set Your Password')),
                  const SizedBox(height: 8),
                  Text(
                    textAlign: TextAlign.center,
                    'In order to keep your account safe you need to create a strong password',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.fontColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
          child: Text(
            'New Password',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            fillColor: const Color(0xffF3F9FF),
            filled: true,
            hintText: 'Enter new password',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.hintTextColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.fontColor,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: AppColors.colorsBlue, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Please enter a password';
          //   }
          //   if (!_hasMinLength ||
          //       !_hasUppercase ||
          //       !_hasLowercase ||
          //       !_hasDigit ||
          //       !_hasSpecialChar) {
          //     return 'Password does not meet requirements';
          //   }
          //   return null;
          // },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
          child: Text(
            'Confirm Password',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            fillColor: const Color(0xffF3F9FF),
            filled: true,
            hintText: 'Confirm your password',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.hintTextColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.fontColor,
              ),
              onPressed: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.colorsBlue, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorsBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Set Password',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     resizeToAvoidBottomInset: true, // Prevents bottom overflow

  //     body: Center(
  //       child: SafeArea(
  //         // Adds safe area to prevent bottom inset issues
  //         child: SingleChildScrollView(
  //           // Allows scrolling when keyboard appears
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Form(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   // Image
  //                   Image.asset(
  //                     'assets/loginbro.png',
  //                     width: 250,
  //                   ),

  //                   // Title
  //                   const Padding(
  //                     padding: EdgeInsets.symmetric(vertical: 10),
  //                     child: StyleText('Set Your Password'),
  //                   ),

  //                   // Subtitle
  //                   const Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //                     child: ParagraphText(
  //                       'In order to keep your account safe, you need to create a strong password.',
  //                       textAlign: TextAlign.center,
  //                       maxLines: 2,
  //                     ),
  //                   ),

  //                   // const Row(
  //                   //   children: [
  //                   //     Padding(
  //                   //         padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
  //                   //         child: Text('Password'))
  //                   //   ],
  //                   // ),
  //                   // // Password TextField
  //                   // Padding(
  //                   //   padding: const EdgeInsets.symmetric(vertical: 10),
  //                   //   child: TextField(
  //                   //     // controller: _passwordController,
  //                   //     controller: newPwdController,
  //                   //     obscureText: _isPasswordObscured,
  //                   //     decoration: InputDecoration(
  //                   //       hintText:
  //                   //           'Enter your password', // Only placeholder text
  //                   //       fillColor: Colors.grey,
  //                   //       suffixIcon: IconButton(
  //                   //         icon: Icon(
  //                   //           _isPasswordObscured
  //                   //               ? Icons.visibility_off
  //                   //               : Icons.visibility,
  //                   //         ),
  //                   //         onPressed: () {
  //                   //           setState(() {
  //                   //             _isPasswordObscured = !_isPasswordObscured;
  //                   //           });
  //                   //         },
  //                   //       ),
  //                   //       border: OutlineInputBorder(
  //                   //         borderRadius: BorderRadius.circular(10),
  //                   //       ),
  //                   //     ),
  //                   //   ),
  //                   // ),

  //                   Row(
  //                     children: [
  //                      const SizedBox(
  //                         height: 5,
  //                         width: 5,
  //                       ),
  //                       Text(
  //                         'Password',
  //                         style: GoogleFonts.poppins(
  //                             fontSize: 14, fontWeight: FontWeight.w500),
  //                       )
  //                     ],
  //                   ),
  //                 const  SizedBox(
  //                     height: 5,
  //                   ),
  //                   // Password TextField
  //                   TextField(
  //                     obscureText: _isPasswordObscured1,
  //                     style: GoogleFonts.poppins(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                         color: Colors.black),
  //                     // controller: _passwordController,
  //                     controller: newPwdController,
  //                     decoration: InputDecoration(
  //                       fillColor: const Color(0xffF3F9FF),
  //                       filled: true,
  //                       hintText: 'Password', // Only placeholder text
  //                       hintStyle: const TextStyle(color: Colors.grey),
  //                       // fillColor: Colors.grey,
  //                       suffixIcon: IconButton(
  //                         icon: Icon(_isPasswordObscured1
  //                             ? Icons.visibility_off_outlined
  //                             : Icons.visibility_outlined),
  //                         onPressed: () {
  //                           setState(() {
  //                             _isPasswordObscured1 = !_isPasswordObscured1;
  //                           });
  //                         },
  //                       ),
  //                       border: OutlineInputBorder(
  //                         borderSide: BorderSide.none,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),

  //                   // const Row(
  //                   //   children: [
  //                   //     Padding(
  //                   //         padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
  //                   //         child: Text('Confirm Password'))
  //                   //   ],
  //                   // ),

  //                   // Padding(
  //                   //   padding: const EdgeInsets.symmetric(vertical: 10),
  //                   //   child: TextFormField(
  //                   //     controller: confirmPwdController,
  //                   //     obscureText: _isPasswordObscured,
  //                   //     decoration: InputDecoration(
  //                   //       hintText: 'Enter Confirm Password',
  //                   //       suffixIcon: IconButton(
  //                   //         icon: Icon(_isPasswordObscured
  //                   //             ? Icons.visibility_off
  //                   //             : Icons.visibility),
  //                   //         onPressed: () {
  //                   //           setState(() {
  //                   //             _isPasswordObscured = !_isPasswordObscured;
  //                   //           });
  //                   //         },
  //                   //       ),
  //                   //       border: OutlineInputBorder(
  //                   //         borderRadius: BorderRadius.circular(10),
  //                   //       ),
  //                   //     ),
  //                   //   ),
  //                   // ),

  //                  const SizedBox(
  //                     height: 20,
  //                   ),
  //                   Row(
  //                     children: [
  //                     const  SizedBox(
  //                         height: 5,
  //                         width: 5,
  //                       ),
  //                       Text(
  //                         'Confirm Password',
  //                         style: GoogleFonts.poppins(
  //                             fontSize: 14, fontWeight: FontWeight.w500),
  //                       )
  //                     ],
  //                   ),
  //                 const  SizedBox(
  //                     height: 5,
  //                   ),
  //                   // Password TextField
  //                   TextField(
  //                     obscureText: _isPasswordObscured2,
  //                     style: GoogleFonts.poppins(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                         color: Colors.black),
  //                     controller: confirmPwdController,
  //                     decoration: InputDecoration(
  //                       fillColor: const Color(0xffF3F9FF),
  //                       filled: true,
  //                       hintText: 'Confirm Password', // Only placeholder text
  //                       hintStyle: const TextStyle(color: Colors.grey),
  //                       // fillColor: Colors.grey,
  //                       suffixIcon: IconButton(
  //                         icon: Icon(_isPasswordObscured2
  //                             ? Icons.visibility_off_outlined
  //                             : Icons.visibility_outlined),
  //                         onPressed: () {
  //                           setState(() {
  //                             _isPasswordObscured2 = !_isPasswordObscured2;
  //                           });
  //                         },
  //                       ),
  //                       border: OutlineInputBorder(
  //                         borderSide: BorderSide.none,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),

  //                   // Next Step Button
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                     child: ElevatedButton(
  //                       onPressed: submitBtn,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF0276FE),
  //                         foregroundColor: Colors.white,
  //                         minimumSize: const Size(double.infinity, 50),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                       child: const Button('Next Step', style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> _handleSubmit() async {
    final newPwd = _passwordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();

    // Check if fields are empty
    if (newPwd.isEmpty || confirmPwd.isEmpty) {
      showErrorMessage(context, message: 'Please fill in all fields');
      return;
    }

    // Validate password matching
    if (newPwd != confirmPwd) {
      showErrorMessage(context, message: 'Passwords do not match');
      return;
    }

    final deviceToken = await FirebaseMessaging.instance.getToken();

    // Check if the token is available
    if (deviceToken == null) {
      print('Failed to retrieve device token');
      showErrorMessage(context, message: 'Failed to retrieve device token');
      return;
    }

    // Prepare the body with email, new password, confirm password, and device token
    final body = {
      "email": widget.email,
      "newPwd": newPwd,
      "confirmPwd": confirmPwd,
      "device_token": deviceToken,
    };

    try {
      final response = await LeadsSrv.setNewPwd(body);
      print('API Response: $response');

      if (response['isSuccess'] == true) {
        // Extract data from the nested structure
        final responseData = response['data'];
        final message =
            responseData['message'] ?? 'Password reset successfully';
        final tokenData = responseData['data'];

        if (tokenData != null && tokenData['token'] != null) {
          final token = tokenData['token'];
          // Store token if needed
          // await FlutterSecureStorage().write(key: 'auth_token', value: token);

          // Get user info if needed - check structure carefully
          if (tokenData['updateUserPwd'] != null &&
              tokenData['updateUserPwd'].length > 1 &&
              tokenData['updateUserPwd'][1] != null &&
              tokenData['updateUserPwd'][1].isNotEmpty) {
            final userData = tokenData['updateUserPwd'][1][0];
            // Use userData if needed
            print('User name: ${userData['name']}');
          }
        }

        // Show success message
        // ignore: use_build_context_synchronously
        showSuccessMessage(context, message: message);

        // Navigate to LoginPage
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              email: '',
              onLoginSuccess: () {},
            ),
          ),
        );
      } else {
        // Get error message from API response if available
        final errorMessage =
            response['data']?['message'] ?? 'Failed to create password';

        // ignore: use_build_context_synchronously
        showErrorMessage(context, message: errorMessage);
      }
    } catch (error) {
      print('Error during password creation: $error');
      // ignore: use_build_context_synchronously
      showErrorMessage(context,
          message: 'Error during API call: ${error.toString()}');
    }
  }

  // Future<void> _handleSubmit() async {

  //   final newPwd = _passwordController.text.trim();
  //   final confirmPwd = _confirmPasswordController.text.trim();

  //   // Check if fields are empty
  //   if (newPwd.isEmpty || confirmPwd.isEmpty) {
  //     showErrorMessage(context, message: 'Please fill in all fields');
  //     return;
  //   }

  //   // Optional: Add further validation, like password length or matching passwords
  //   if (newPwd != confirmPwd) {
  //     showErrorMessage(context, message: 'Passwords do not match');
  //     return;
  //   }

  //   final deviceToken = await FirebaseMessaging.instance.getToken();

  //   // Check if the token is available
  //   if (deviceToken == null) {
  //     // ignore: avoid_print
  //     print('Failed to retrieve device token');
  //     return;
  //   }

  //   // Prepare the body with email, new password, confirm password, and device token
  //   final body = {
  //     "email": widget.email,
  //     "newPwd": newPwd,
  //     "confirmPwd": confirmPwd,
  //     "device_token": deviceToken,
  //   };

  //   try {
  //     final response = await LeadsSrv.setPwd(body);

  //     // ignore: avoid_print
  //     print('API Response: $response');

  //     if (response['isSuccess'] == true) {
  //       // ignore: use_build_context_synchronously
  //       showSuccessMessage(context, message: 'Email Verified Successfully');

  //       // Navigate to LoginPage
  //       Navigator.push(
  //         // ignore: use_build_context_synchronously
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => LoginPage(
  //             email: '',
  //             onLoginSuccess: () {},
  //           ),
  //         ),
  //       );
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showErrorMessage(context, message: 'Check the Email or OTP');
  //     }
  //   } catch (error) {
  //     // ignore: use_build_context_synchronously
  //     showErrorMessage(context, message: 'Error during API call');
  //   }
  // }
}
