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
  String _authStatus = 'Verifying your identity';
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    // _checkBiometrics();  //uncooment
    // checkTokenAndAuthenticate(); 
    _authenticate();
  }

  @override
  void dispose() {
    _mounted = false; // Set mounted flag to false when disposed
    super.dispose();
  }

   Future<void> _authenticate() async {
    if (!_mounted) return;
    
    setState(() {
      isAuthenticating = true;
    });
    
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      if (!_mounted) return;
      
      if (!canCheckBiometrics) {
        setState(() {
          _authStatus = 'Device does not support biometrics';
        });
        // If biometrics not available, proceed to home after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (!_mounted) return;
        _proceedToHome();
        return;
      }
      
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (!_mounted) return;
      
      if (authenticated) {
        _proceedToHome();
      } else {
        setState(() {
          _authStatus = 'Authentication failed. Please try again.';
          isAuthenticating = false;
        });
        // Add a retry button in the UI
      }
    } catch (e) {
      if (!_mounted) return;
      setState(() {
        isAuthenticating = false;
        
        if (e.toString().contains(auth_error.notAvailable)) {
          _authStatus = 'Biometrics not available';
          // Proceed to home after showing the message briefly
          Future.delayed(const Duration(seconds: 2), () {
            if (_mounted) _proceedToHome();
          });
        } else if (e.toString().contains(auth_error.notEnrolled)) {
          _authStatus = 'No biometrics enrolled on this device';
          // Proceed to home after showing the message briefly
          Future.delayed(const Duration(seconds: 2), () {
            if (_mounted) _proceedToHome();
          });
        } else {
          _authStatus = 'Error: $e';
        }
      });
    }
  }
  
  void _proceedToHome() async {
    await NotificationService.instance.initialize();
    Get.offAll(() => BottomNavigation());
  }

  // Future<void> checkTokenAndAuthenticate() async {
  //   bool isValid = await TokenManager.isTokenValid();

  //   if (!_mounted) return; // Check if still mounted before proceeding

  //   if (isValid) {
  //     // Token is valid, now check biometrics
  //     _checkBiometrics();
  //   } else {
  //     // Clear any invalid tokens and navigate to login
  //     await TokenManager.clearAuthData();
  //     if (_mounted) {
  //       // Check again before navigation
  //       Get.offAll(() => LoginPage(
  //             email: '',
  //             onLoginSuccess: () {},
  //           ));
  //     }
  //   }
  // }

  // Future<void> _checkBiometrics() async {
  //   if (!_mounted) return; // Check if still mounted

  //   bool canCheckBiometrics;
  //   try {
  //     canCheckBiometrics = await auth.canCheckBiometrics;

  //     if (!_mounted) return; // Check again after async operation

  //     if (canCheckBiometrics) {
  //       _authenticate();
  //     } else {
  //       setState(() {
  //         _authStatus = 'Device does not support biometrics or device security';
  //       });
  //     }
  //   } catch (e) {
  //     if (!_mounted) return;

  //     setState(() {
  //       _authStatus = 'Error checking biometrics: $e';
  //     });
  //   }
  // }

  // Future<void> _authenticate() async {
  //   if (!_mounted) return;

  //   setState(() {
  //     isAuthenticating = true;
  //     _authStatus = 'Authenticating...';
  //   });

  //   bool authenticated = false;
  //   try {
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'Please authenticate to access the app',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //         biometricOnly: false,
  //       ),
  //     );

  //     if (!_mounted) return; // Check if still mounted after authentication

  //     if (authenticated) {
  //       // Initialize notifications and navigate to home
  //       await NotificationService.instance.initialize();
  //       Get.offAll(() => BottomNavigation());
  //     } else {
  //       setState(() {
  //         _authStatus = 'Authentication failed';
  //         isAuthenticating = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (!_mounted) return;

  //     setState(() {
  //       isAuthenticating = false;
  //       if (e.toString().contains(auth_error.notAvailable)) {
  //         _authStatus = 'Biometrics not available on this device';
  //       } else if (e.toString().contains(auth_error.notEnrolled)) {
  //         _authStatus = 'No biometrics enrolled on this device';
  //       } else {
  //         _authStatus = 'Error: $e';
  //       }
  //     });
  //   }
  // }

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
