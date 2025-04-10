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
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/route/route_name.dart';

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
      _controller.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.of(context).pushReplacementNamed(RoutesName.login);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
