// biometric_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/utils/biometric_prefrence.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';

class BiometricScreen extends StatefulWidget {
  final bool isFirstTime;

  const BiometricScreen(
      {super.key,
      this.isFirstTime =
          false // Flag to indicate if this is the first time after login
      });

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticating = false;
  String _authStatus = 'Verifying your identity';
  bool _mounted = true;
  bool _canCheckBiometrics = false;
  bool _showBiometricChoice = false;
  bool _useBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    BiometricPreference.printAllPreferences(); // For debugging
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    if (!_mounted) return;

    try {
      // Check if device supports biometrics
      _canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      print("Device supports biometrics: $_canCheckBiometrics");
      print("Available biometrics: $availableBiometrics");

      if (!_mounted) return;

      // If first time after login, show the biometric choice
      if (widget.isFirstTime && _canCheckBiometrics) {
        // Check if we've already prompted before
        bool hasPrompted = await BiometricPreference.getHasPromptedBiometric();

        if (!hasPrompted) {
          setState(() {
            _showBiometricChoice = true;
          });
          // Mark that we've prompted the user
          await BiometricPreference.setHasPromptedBiometric(true);
        } else {
          // We've already prompted before, check the preference
          bool useBiometric = await BiometricPreference.getUseBiometric();
          if (useBiometric) {
            setState(() {
              _useBiometric = true;
            });
            // Small delay before authentication prompt
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_mounted) {
                _authenticate();
              }
            });
          } else {
            // User previously declined, go directly to home
            _proceedToHome();
          }
        }
      } else {
        // Not first time - check saved preference and authenticate if needed
        bool useBiometric = await BiometricPreference.getUseBiometric();

        if (!_mounted) return;

        print("useBiometric from preferences: $useBiometric");

        if (useBiometric && _canCheckBiometrics) {
          setState(() {
            _useBiometric = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_mounted) {
              _authenticate();
            }
          });
        } else {
          // Skip biometric and go directly to home
          _proceedToHome();
        }
      }
    } catch (e) {
      if (!_mounted) return;

      print("Error checking biometrics: $e");
      // On error, proceed to home
      _proceedToHome();
    }
  }

  Future<void> _authenticate() async {
    if (!_mounted) return;

    setState(() {
      isAuthenticating = true;
      _authStatus = 'Verifying your identity';
    });

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!_mounted) return;

      if (authenticated) {
        print("Authentication successful");
        _proceedToHome();
      } else {
        print("Authentication failed");
        setState(() {
          _authStatus = 'Authentication failed. Please try again.';
          isAuthenticating = false;
        });
      }
    } catch (e) {
      if (!_mounted) return;

      print("Biometric error: $e");
      setState(() {
        isAuthenticating = false;
        _authStatus = 'Error: $e';
      });

      // If there's an error with biometrics, give option to proceed anyway
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            textAlign: TextAlign.center,
            'Biometric Error',
            style: AppFont.popupTitleWhite(context),
          ),
        ),
        content: const Text(
            'There was a problem with biometric authentication. Would you like to proceed with password login?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _skipAndLogin();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Try authentication again
              _authenticate();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _proceedToHome() async {
    try {
      await NotificationService.instance.initialize();
      print("Proceeding to home screen");
    } catch (e) {
      print("Error initializing notifications: $e");
    }

    if (_mounted) {
      Get.offAll(() => BottomNavigation());
    }
  }

  void _enableBiometric(bool enable) async {
    print("Setting biometric preference to: $enable");
    await BiometricPreference.setUseBiometric(enable);
    // This will also set hasMadeBiometricChoice to true

    if (!_mounted) return;

    if (enable) {
      setState(() {
        _showBiometricChoice = false;
        _useBiometric = true;
      });
      _authenticate();
    } else {
      _proceedToHome();
    }
  }

  void _skipAndLogin() async {
    // Navigate to login screen
    if (_mounted) {
      Get.offAll(() => LoginPage(
            onLoginSuccess: () {
              Get.off(() => BottomNavigation());
            },
            email: '',
          ));
    }
  }

  Widget _buildBiometricChoiceUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fingerprint,
            size: 80.w,
            color: Colors.blue,
          ),
          SizedBox(height: 24.h),
          Text('Enable Biometric Authentication?',
              textAlign: TextAlign.center,
              style: AppFont.popupTitleWhite(context)),
          SizedBox(height: 16.h),
          Text(
            'Use your fingerprint or face ID to quickly and securely access the app next time.',
            style: AppFont.dropDowmLabelLightcolors(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48.h),
          ElevatedButton(
            onPressed: () => _enableBiometric(true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Enable',
              style: AppFont.dropDowmLabel(context),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => _enableBiometric(false),
            child: Text('Not Now',
                style: AppFont.dropDowmLabelLightcolors(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationUI() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fingerprint,
            size: 80.w,
            color: isAuthenticating ? Colors.blue : Colors.white,
          ),
          SizedBox(height: 24.h),
          Text(
            _authStatus,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (isAuthenticating)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          else
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: _skipAndLogin,
            child: Text('Use Password Instead',
                style: AppFont.dropDowmLabel(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            textAlign: TextAlign.center,
            _showBiometricChoice ? 'Setup Biometrics' : 'Authentication',
            style: AppFont.popupTitleWhite(context),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _showBiometricChoice
            ? _buildBiometricChoiceUI()
            : _buildAuthenticationUI(),
      ),
    );
  }
}
