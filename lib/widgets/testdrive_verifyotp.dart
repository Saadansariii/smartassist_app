import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/login_steps/first_screen.dart';
import 'package:smart_assist/pages/login_steps/last_screen.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/button.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:smart_assist/utils/style_text.dart';
import 'package:smart_assist/widgets/license_varification.dart';

class TestdriveVerifyotp extends StatefulWidget {
  static const int _otpLength = 6;
  final String eventId;
  final String email;
  final String text;
  final TextStyle? style;

  const TestdriveVerifyotp({
    super.key,
    required this.email,
    required this.text,
    this.style,
    required this.eventId,
  });

  @override
  State<TestdriveVerifyotp> createState() => _TestdriveVerifyotpState();
}

class _TestdriveVerifyotpState extends State<TestdriveVerifyotp> {
  final List<TextEditingController> _controllers = List.generate(
      TestdriveVerifyotp._otpLength, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(TestdriveVerifyotp._otpLength, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResendingOTP = false;
  int _resendTimer = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back, color: Colors.black),
      //   onPressed: () => Navigator.pop(context),
      // ),
      // ),
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeaderImage(),
                  _buildTitle(),
                  _buildEmailInfo(),
                  const SizedBox(height: 20),
                  _buildOTPFields(),
                  const SizedBox(height: 20),
                  _buildResendOption(),
                  Row(
                    children: [
                      Expanded(
                        child: _cancelButton(),
                      ),
                      Expanded(
                        child: _buildVerifyButton(),
                      )
                      // _buildVerifyButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Image.asset(
        'assets/car.png',
        width: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Start Test drive',
        style: AppFont.popupTitle(context),
      ),
    );
  }

  Widget _buildEmailInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Text(
        textAlign: TextAlign.center,
        'Enter OTP sent to ${widget.email} to continue',
        style: AppFont.mediumText14(context),
      ),
    );
  }

  Widget _buildOTPFields() {
    // Calculate the available width for OTP fields
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 32; // Subtract horizontal padding
    final spacing = 8.0;
    // Calculate field width based on available space
    final fieldWidth =
        (availableWidth - (spacing * (TestdriveVerifyotp._otpLength - 1))) /
            TestdriveVerifyotp._otpLength;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            TestdriveVerifyotp._otpLength,
            (index) => Container(
              margin: EdgeInsets.only(
                right: index < TestdriveVerifyotp._otpLength - 1 ? spacing : 0,
              ),
              width: fieldWidth.clamp(35, 45),
              height: 50,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                onChanged: (value) => _handleOTPInput(value, index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendOption() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "Didn't receive the code? ",
        style: AppFont.mediumText14(context),
        children: [
          TextSpan(
            text: _resendTimer > 0 ? 'Resend in ${_resendTimer}s' : 'Resend',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _resendTimer > 0 ? Colors.grey : AppColors.colorsBlue,
              decoration: _resendTimer > 0 ? null : TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = _resendTimer > 0 ? null : _handleResendOTP,
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          // _handleVerification;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PassportVarification(eventId: widget.eventId)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0276FE),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Button(
                'Verify',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _cancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.containerPopBg,
          foregroundColor: AppColors.fontColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Button(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleOTPInput(String value, int index) {
    if (value.isNotEmpty && index < TestdriveVerifyotp._otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleResendOTP() async {
    if (_isResendingOTP) return;

    setState(() => _isResendingOTP = true);

    try {
      // Implement your resend OTP logic here
      // await OtpSrv.resendOTP({"email": widget.email});

      if (!mounted) return;

      setState(() => _resendTimer = 30);
      _startResendTimer();

      showSuccessMessage(context, message: 'OTP resent successfully');
    } catch (error) {
      if (!mounted) return;
      showErrorMessage(context, message: 'Failed to resend OTP');
      debugPrint('Resend OTP error: $error');
    } finally {
      if (mounted) {
        setState(() => _isResendingOTP = false);
      }
    }
  }

  // Future<void> _handleVerification() async {
  //   final otpString = _controllers.map((controller) => controller.text).join();

  //   if (otpString.length != TestdriveVerifyotp._otpLength) {
  //     showErrorMessage(context, message: 'Please enter all digits');
  //     return;
  //   }

  //   if (int.tryParse(otpString) == null) {
  //     showErrorMessage(context, message: 'Please enter valid digits');
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final response = await LeadsSrv.verifyOtp({
  //       "otp": int.parse(otpString),
  //       "email": widget.email,
  //     });

  //     if (!mounted) return;

  //     if (response['isSuccess'] == true) {
  //       // Extract the message from the nested data structure if available
  //       final responseData = response['data'];
  //       final successMessage =
  //           responseData?['message'] ?? 'Email verified successfully';

  //       showSuccessMessage(context, message: successMessage);
  //       _navigateToPasswordScreen();
  //     } else {
  //       // Get error message from the proper location in the response
  //       final errorMessage = response['data']?['message'] ??
  //           response['message'] ??
  //           'Invalid OTP. Please try again.';

  //       showErrorMessage(context, message: errorMessage);
  //     }
  //   } catch (error) {
  //     if (!mounted) return;
  //     showErrorMessage(
  //       context,
  //       message: 'Verification failed. Please try again.',
  //     );
  //     debugPrint('OTP verification error: $error');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  _handleVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PassportVarification(eventId: widget.eventId),
      ),
    );
  }

  void _navigateToPasswordScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PassportVarification(eventId: widget.eventId),
      ),
    );
  }
}
