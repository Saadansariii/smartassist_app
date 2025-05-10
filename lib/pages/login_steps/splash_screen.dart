// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/route/route_name.dart';
// import 'package:smart_assist/pages/home_screens/home_screen.dart';
// import 'package:smart_assist/pages/login/login_page.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _aiFadeAnimation;
//   late Animation<double> _assistAndSmartFadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     // First animation: 'ai' fades in
//     _aiFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
//       ),
//     );

//     // Second animation: both 'smart' and 'ssst' fade in together after 'ai'
//     _assistAndSmartFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
//       ),
//     );

//     // Add listener to track animation status
//     _aiFadeAnimation.addListener(() {
//       print("Animation status: ${_controller.status}");
//     });

//     // Start animation after a delay
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _controller.forward();
//     });

//     //  Future.delayed(const Duration(milliseconds: 1500), () {
//     //    navigator.pushNamed(context , RoutesName.login);
//     // });

//     // Navigate after animation completion
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 2000), () {
//         Navigator.of(context).pushReplacementNamed(RoutesName.login);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 'smart' fades in with 'ssst'
//             FadeTransition(
//               opacity: _assistAndSmartFadeAnimation,
//               child: Text(
//                 'smart',
//                 style: GoogleFonts.poppins(
//                   fontSize: 40,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 'a' appears first (blue)
//                 FadeTransition(
//                   opacity: _aiFadeAnimation,
//                   child: Text(
//                     'a',
//                     style: GoogleFonts.poppins(
//                       fontSize: 40,
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 // 'ss' part - fades in with 'smart'
//                 FadeTransition(
//                   opacity: _assistAndSmartFadeAnimation,
//                   child: Text(
//                     'ss',
//                     style: GoogleFonts.poppins(
//                       fontSize: 40,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 // 'i' appears with 'a' (blue)
//                 FadeTransition(
//                   opacity: _aiFadeAnimation,
//                   child: Text(
//                     'i',
//                     style: GoogleFonts.poppins(
//                       fontSize: 40,
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 // 'st' part - fades in with 'smart'
//                 FadeTransition(
//                   opacity: _assistAndSmartFadeAnimation,
//                   child: Text(
//                     'st',
//                     style: GoogleFonts.poppins(
//                       fontSize: 40,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/route/route_name.dart';
import 'package:smart_assist/pages/login_steps/biometric_screen.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/utils/biometric_prefrence.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/token_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _aiFadeAnimation;
  late Animation<double> _assistAndSmartFadeAnimation;
  late Animation<double> _aiSizeAnimation;
  late Animation<Offset> _aPositionAnimation;
  late Animation<Offset> _iPositionAnimation;
  bool _mounted = true;

  // @override
  // void initState() {
  //   super.initState();

  //   _controller = AnimationController(
  //     duration: const Duration(milliseconds: 2000),
  //     vsync: this,
  //   );

  //   // AI fade in animation
  //   _aiFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
  //     ),
  //   );

  //   // AI size animation (starts big, gets smaller)
  //   _aiSizeAnimation = Tween<double>(begin: 80, end: 40).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
  //     ),
  //   );

  //   // 'a' position animation (moves from center to left side of 'assist')
  //   _aPositionAnimation = Tween<Offset>(
  //     begin: const Offset(-0.2, 0), // Start at center
  //     end: const Offset(-1.65, 0), // Move left
  //   ).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
  //     ),
  //   );

  //   // 'i' position animation (moves from center to right position within 'assist')
  //   _iPositionAnimation = Tween<Offset>(
  //     begin: const Offset(1, 0), // Start at center
  //     end: const Offset(1.50, 0), // Move right
  //   ).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
  //     ),
  //   );

  //   // Rest of text fade-in animation (after AI is positioned)
  //   _assistAndSmartFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
  //     CurvedAnimation(
  //       parent: _controller,
  //       curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
  //     ),
  //   );

  //   // Start animation after a delay
  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     _controller.forward();
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Future.delayed(const Duration(milliseconds: 3000), () {
  //       Navigator.of(context).pushReplacementNamed(RoutesName.home);
  //       // Navigator.of(context).pushReplacementNamed(RoutesName.login);
  //     });
  //   });

  //   // checkAuthStatus();
  // }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // AI fade in animation
    _aiFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // AI size animation (starts big, gets smaller)
    _aiSizeAnimation = Tween<double>(begin: 80, end: 40).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // 'a' position animation (moves from center to left side of 'assist')
    _aPositionAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0), // Start at center
      end: const Offset(-1.65, 0), // Move left
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
      ),
    );

    // 'i' position animation (moves from center to right position within 'assist')
    _iPositionAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // Start at center
      end: const Offset(1.50, 0), // Move right
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Rest of text fade-in animation (after AI is positioned)
    _assistAndSmartFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_mounted) {
        _controller.forward();
      }
    });

    // Start the authentication check after animations complete
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // checkAuthStatus();
        _initializeApp();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _controller.dispose();
    super.dispose();
  }

// splash screen
  Future<void> _initializeApp() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    if (!_mounted) return;

    checkAuthStatus();
  }

 Future<void> checkAuthStatus() async {
    if (!_mounted) return;

    try {
      // Debug preferences
      await BiometricPreference.printAllPreferences();

      // Check if user has a valid token
      bool isTokenValid = await TokenManager.isTokenValid();
      print("Token is valid: $isTokenValid");

      if (!_mounted) return;

      if (isTokenValid) {
        // Check biometric preference
        bool useBiometric = await BiometricPreference.getUseBiometric();
        bool hasMadeBiometricChoice = await BiometricPreference.getHasMadeBiometricChoice();
        
        print("Has made biometric choice: $hasMadeBiometricChoice");
        print("Use biometric: $useBiometric");

        if (!_mounted) return;

        if (useBiometric) {
          // If biometric is enabled, go to biometric verification screen
          Get.offAllNamed(RoutesName.biometricScreen);
        } else if (hasMadeBiometricChoice) {
          // User explicitly declined biometrics (clicked "Not Now"), always go to login
          Get.offAllNamed(RoutesName.login);
        } else {
          // First time login, show biometric setup once
          Get.offAllNamed(RoutesName.biometricScreen,
              arguments: {'isFirstTime': true});
        }
      } else {
        // If no token or invalid token, go to login screen
        await TokenManager.clearAuthData();
        // Also reset biometric preferences on logout/token expiry
        await BiometricPreference.resetBiometricPreferences();
        if (!_mounted) return;

        Get.offAllNamed(RoutesName.login);
      }
    } catch (e) {
      // If there's any error in token checking, default to login
      if (_mounted) {
        print("Error checking auth status: $e");
        Get.offAllNamed(RoutesName.login);
      }
    }
  }

  // Future<void> checkAuthStatus() async {
  //   if (!_mounted) return;

  //   try {
  //     // Debug preferences
  //     await BiometricPreference.printAllPreferences();

  //     // Check if user has a valid token
  //     bool isTokenValid = await TokenManager.isTokenValid();
  //     print("Token is valid: $isTokenValid");

  //     if (!_mounted) return;

  //     if (isTokenValid) {
  //       // Check if user has made a choice about biometrics
  //       bool hasMadeBiometricChoice =
  //           await BiometricPreference.getHasMadeBiometricChoice();

  //       // Token is valid, check biometric preference
  //       bool useBiometric = await BiometricPreference.getUseBiometric();
  //       print("Has made biometric choice: $hasMadeBiometricChoice");
  //       print("Use biometric: $useBiometric");

  //       if (!_mounted) return;

  //       if (useBiometric) {
  //         // If biometric is enabled, go to biometric screen
  //         Get.offAllNamed(RoutesName.biometricScreen);
  //       } else if (hasMadeBiometricChoice) {
  //         // If user has explicitly declined biometrics, go directly to home
  //         Get.offAllNamed(RoutesName.home);
  //       } else {
  //         // No choice has been made yet about biometrics
  //         Get.offAllNamed(RoutesName.biometricScreen,
  //             arguments: {'isFirstTime': true});
  //       }
  //     } else {
  //       // If no token or invalid token, go to login screen
  //       await TokenManager.clearAuthData();
  //       // Also reset biometric preferences on logout/token expiry
  //       await BiometricPreference.resetBiometricPreferences();
  //       if (!_mounted) return;

  //       Get.offAllNamed(RoutesName.login);
  //     }
  //   } catch (e) {
  //     // If there's any error in token checking, default to login
  //     if (_mounted) {
  //       print("Error checking auth status: $e");
  //       Get.offAllNamed(RoutesName.login);
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 'smart' appears first
            FadeTransition(
              opacity: _assistAndSmartFadeAnimation,
              child: Text(
                'smart',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Stack(
              alignment: Alignment.center,
              children: [
                // 'assist' base text with invisible placeholders
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: 0, // Placeholder for 'a'
                      child: Text(
                        'a',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _assistAndSmartFadeAnimation,
                      child: Text(
                        'ss',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0, // Placeholder for 'i'
                      child: Text(
                        'i',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _assistAndSmartFadeAnimation,
                      child: Text(
                        'st',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Moving 'a'
                SlideTransition(
                  position: _aPositionAnimation,
                  child: FadeTransition(
                    opacity: _aiFadeAnimation,
                    child: AnimatedBuilder(
                      animation: _aiSizeAnimation,
                      builder: (context, child) {
                        return Text(
                          'a',
                          style: GoogleFonts.poppins(
                            fontSize: _aiSizeAnimation.value,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Moving 'i'
                SlideTransition(
                  position: _iPositionAnimation,
                  child: FadeTransition(
                    opacity: _aiFadeAnimation,
                    child: AnimatedBuilder(
                      animation: _aiSizeAnimation,
                      builder: (context, child) {
                        return Text(
                          'i',
                          style: GoogleFonts.poppins(
                            fontSize: _aiSizeAnimation.value,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
