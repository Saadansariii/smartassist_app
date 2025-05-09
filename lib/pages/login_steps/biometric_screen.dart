// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth/error_codes.dart' as auth_error;
// import 'package:smart_assist/config/route/route_name.dart';
// import 'package:smart_assist/services/notifacation_srv.dart';

// class BiometricScreen extends StatefulWidget {

//   const BiometricScreen({super.key});

//   @override
//   State<BiometricScreen> createState() => _BiometricScreenState();
// }

// class _BiometricScreenState extends State<BiometricScreen> {
//   final LocalAuthentication auth = LocalAuthentication();
//   bool isAuthenticating = false;
//   String _authStatus = 'Verifying your identity';
//   bool _mounted = true;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (_mounted) {
//         _authenticate();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _mounted = false; // Set mounted flag to false when disposed
//     super.dispose();
//   }

//   Future<void> _authenticate() async {
//     if (!_mounted) return;

//     setState(() {
//       isAuthenticating = true;
//     });

//     bool canCheckBiometrics;
//     try {
//       canCheckBiometrics = await auth.canCheckBiometrics;
//       if (!_mounted) return;

//       if (!canCheckBiometrics) {
//         setState(() {
//           _authStatus = 'Device does not support biometrics';
//         });
//         // If biometrics not available, proceed to home after a short delay
//         await Future.delayed(const Duration(seconds: 2));
//         if (!_mounted) return;
//         _proceedToHome();
//         return;
//       }

//       bool authenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to access the app',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false,
//         ),
//       );

//       if (!_mounted) return;

//       if (authenticated) {
//         _proceedToHome();
//       } else {
//         setState(() {
//           _authStatus = 'Authentication failed. Please try again.';
//           isAuthenticating = false;
//         });
//       }
//     } catch (e) {
//       if (!_mounted) return;

//       print("Biometric error: $e");
//       setState(() {
//         isAuthenticating = false;

//         if (e.toString().contains('NotAvailable')) {
//           _authStatus = 'Biometrics not available';
//           Future.delayed(const Duration(seconds: 2), () {
//             if (_mounted) _proceedToHome();
//           });
//         } else if (e.toString().contains('NotEnrolled')) {
//           _authStatus = 'No biometrics enrolled on this device';
//           Future.delayed(const Duration(seconds: 2), () {
//             if (_mounted) _proceedToHome();
//           });
//         } else {
//           _authStatus = 'Error: $e';
//         }
//       });
//     }
//   }

//   void _proceedToHome() async {
//     try {
//       await NotificationService.instance.initialize();
//     } catch (e) {
//       print("Error initializing notifications: $e");
//     }

//     if (_mounted) {
//       Navigator.of(context).pushReplacementNamed(RoutesName.home);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Authentication'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (isAuthenticating)
//               const CircularProgressIndicator(
//                 color: Colors.blueAccent,
//               )
//             else
//               Column(
//                 children: [
//                   Text(
//                     _authStatus,
//                     style: TextStyle(fontSize: 18.sp),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20.h),
//                   ElevatedButton(
//                     onPressed: _authenticate,
//                     child: const Text('Authenticate'),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// biometric_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/config/route/route_name.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/utils/biometric_prefrence.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
// Add this import
// import 'package:your_package_name/biometric_preference.dart';

class BiometricScreen extends StatefulWidget {
  final bool isFirstTime;

  const BiometricScreen({
    super.key,
    this.isFirstTime = false // Flag to indicate if this is the first time after login
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
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      
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
        title: const Text('Biometric Error'),
        content: const Text('There was a problem with biometric authentication. Would you like to proceed with password login?'),
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
          Text(
            'Enable Biometric Authentication?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            'Use your fingerprint or face ID to quickly and securely access the app next time.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
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
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => _enableBiometric(false),
            child: Text(
              'Not Now',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
              ),
            ),
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
            child: Text(
              'Use Password Instead',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.sp,
              ),
            ),
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
        title: Text(
          _showBiometricChoice ? 'Setup Biometrics' : 'Authentication',
          style: TextStyle(color: Colors.white),
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

// class BiometricScreen extends StatefulWidget {
//   final bool isFirstTime;

//   const BiometricScreen(
//       {super.key,
//       this.isFirstTime =
//           false // Flag to indicate if this is the first time after login
//       });

//   @override
//   State<BiometricScreen> createState() => _BiometricScreenState();
// }

// class _BiometricScreenState extends State<BiometricScreen> {
//   final LocalAuthentication auth = LocalAuthentication();
//   bool isAuthenticating = false;
//   String _authStatus = 'Verifying your identity';
//   bool _mounted = true;
//   bool _canCheckBiometrics = false;
//   bool _showBiometricChoice = false;
//   bool _useBiometric = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkBiometricAvailability();
//     _debugPreferences();
//   }

//   @override
//   void dispose() {
//     _mounted = false;
//     super.dispose();
//   }

//   Future<void> _checkBiometricAvailability() async {
//     if (!_mounted) return;

//     try {
//       // Check if device supports biometrics
//       _canCheckBiometrics = await auth.canCheckBiometrics;

//       if (!_mounted) return;

//       print(
//           "isFirstTime: ${widget.isFirstTime}, canCheckBiometrics: $_canCheckBiometrics");

//       // If first time after login, show the biometric choice
//       if (widget.isFirstTime && _canCheckBiometrics) {
//         setState(() {
//           _showBiometricChoice = true;
//         });
//       } else {
//         // Not first time - check saved preference and authenticate if needed
//         bool useBiometric = await BiometricPreference.getUseBiometric();

//         if (!_mounted) return;

//         print("useBiometric from preferences: $useBiometric");

//         if (useBiometric && _canCheckBiometrics) {
//           setState(() {
//             _useBiometric = true;
//           });
//           Future.delayed(const Duration(milliseconds: 500), () {
//             if (_mounted) {
//               _authenticate();
//             }
//           });
//         } else {
//           // Skip biometric and go directly to home
//           _proceedToHome();
//         }
//       }
//     } catch (e) {
//       if (!_mounted) return;

//       print("Error checking biometrics: $e");
//       // On error, proceed to home
//       _proceedToHome();
//     }
//   }

//   Future<void> _authenticate() async {
//     if (!_mounted) return;

//     setState(() {
//       isAuthenticating = true;
//       _authStatus = 'Verifying your identity';
//     });

//     try {
//       bool authenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to access the app',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false,
//         ),
//       );

//       if (!_mounted) return;

//       if (authenticated) {
//         print("Authentication successful");
//         _proceedToHome();
//       } else {
//         print("Authentication failed");
//         setState(() {
//           _authStatus = 'Authentication failed. Please try again.';
//           isAuthenticating = false;
//         });
//       }
//     } catch (e) {
//       if (!_mounted) return;

//       print("Biometric error: $e");
//       setState(() {
//         isAuthenticating = false;
//         _authStatus = 'Error: $e';
//       });
//     }
//   }

//   void _proceedToHome() async {
//     try {
//       await NotificationService.instance.initialize();
//       print("Proceeding to home screen");
//     } catch (e) {
//       print("Error initializing notifications: $e");
//     }

//     if (_mounted) {
//       Get.offAll(() => BottomNavigation());
//     }
//   }

//   void _enableBiometric(bool enable) async {
//     print("Setting biometric preference to: $enable");
//     await BiometricPreference.setUseBiometric(enable);

//     if (!_mounted) return;

//     if (enable) {
//       setState(() {
//         _showBiometricChoice = false;
//         _useBiometric = true;
//       });
//       _authenticate();
//     } else {
//       _proceedToHome();
//     }
//   }

//   void _skipAndLogin() async {
//     // Navigate to login screen
//     if (_mounted) {
//       Get.offAll(() => LoginPage(
//             onLoginSuccess: () {
//               Get.off(() => BottomNavigation());
//             },
//             email: '',
//           ));
//     }
//   }

//   // Add this to your BiometricScreen class to debug
//   Future<void> _debugPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys();
//     print("All SharedPreferences keys: $keys");

//     bool? useBiometric = prefs.getBool('use_biometric');
//     print("Current use_biometric value: $useBiometric");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Authentication'),
//       ),
//       body: Center(
//         child: _showBiometricChoice
//             ? _buildBiometricChoiceUI()
//             : _buildAuthenticationUI(),
//       ),
//     );
//   }

//   Widget _buildBiometricChoiceUI() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.fingerprint,
//             size: 80.sp,
//             color: Colors.blueAccent,
//           ),
//           SizedBox(height: 20.h),
//           Text(
//             'Would you like to enable biometric authentication?',
//             style: TextStyle(fontSize: 20.sp),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             'This will allow you to quickly access the app using your fingerprint or face ID',
//             style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 40.h),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => _enableBiometric(true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 padding: EdgeInsets.symmetric(vertical: 15.h),
//               ),
//               child: Text('Enable Biometric',
//                   style: TextStyle(fontSize: 18.sp, color: Colors.white)),
//             ),
//           ),
//           SizedBox(height: 15.h),
//           SizedBox(
//             width: double.infinity,
//             child: TextButton(
//               onPressed: () => _enableBiometric(false),
//               child: Text('Skip for now',
//                   style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAuthenticationUI() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (isAuthenticating)
//           const CircularProgressIndicator(
//             color: Colors.blueAccent,
//           )
//         else
//           Column(
//             children: [
//               Text(
//                 _authStatus,
//                 style: TextStyle(fontSize: 18.sp),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20.h),
//               ElevatedButton(
//                 onPressed: _authenticate,
//                 child: const Text('Authenticate'),
//               ),
//               SizedBox(height: 10.h),
//               TextButton(
//                 onPressed: _skipAndLogin,
//                 child: const Text('Use Password Instead'),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }
