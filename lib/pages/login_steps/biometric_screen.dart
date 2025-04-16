import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error; 
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/token_manager.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticating = false;
  String _authStatus = 'Not Authenticated';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    checkTokenAndAuthenticate();
  }

  Future<void> checkTokenAndAuthenticate() async {
    bool isValid = await TokenManager.isTokenValid();

    if (isValid) {
      // Token is valid, now check biometrics
      _checkBiometrics();
    } else {
      // Clear any invalid tokens and navigate to login
      await TokenManager.clearAuthData();
      Get.offAll(() => LoginPage(
            email: '',
            onLoginSuccess: () {},
          ));
    }
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        _authenticate();
      } else {
        setState(() {
          _authStatus = 'Device does not support biometrics or device security';
        });
        // Even if biometrics aren't available, you might want to have some fallback
        // Or prevent access altogether
      }
    } catch (e) {
      setState(() {
        _authStatus = 'Error checking biometrics: $e';
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      isAuthenticating = true;
      _authStatus = 'Authenticating...';
    });

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow any device authentication method
        ),
      );

      if (authenticated) {
        // Only proceed to home screen after successful biometric authentication
        await NotificationService.instance.initialize();
        Get.offAll(() => BottomNavigation());
      } else {
        setState(() {
          _authStatus = 'Authentication failed';
          isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        isAuthenticating = false;
        if (e.toString().contains(auth_error.notAvailable)) {
          _authStatus = 'Biometrics not available on this device';
        } else if (e.toString().contains(auth_error.notEnrolled)) {
          _authStatus = 'No biometrics enrolled on this device';
        } else {
          _authStatus = 'Error: $e';
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAuthenticating)
              const CircularProgressIndicator(
                color: Colors.blueAccent,
              )
            else
              Column(
                children: [
                  Text(
                    _authStatus,
                    style: TextStyle(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Authenticate'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
