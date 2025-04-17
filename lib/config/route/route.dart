import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:smart_assist/config/route/route_name.dart';
import 'package:smart_assist/pages/login_steps/biometric_screen.dart';
import 'package:smart_assist/pages/login_steps/login_page.dart';
import 'package:smart_assist/pages/login_steps/splash_screen.dart';
import 'package:smart_assist/utils/bottom_navigation.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      // case RoutesName.biometricScreen:
      //   return MaterialPageRoute(
      //     builder: (context) => const BiometricScreen(),
      //   );
//comment this
      case RoutesName.home1:
        return MaterialPageRoute(
          builder: (context) => BottomNavigation(),
        );

      //this
      case RoutesName.login:
        return MaterialPageRoute(
          builder: (context) => LoginPage(
            onLoginSuccess: () {
              Get.off(() => BottomNavigation());
            },
            email: '',
          ),
        );
      // case RoutesName.home:
      //   return MaterialPageRoute(builder: (context) => const ());
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('no route matched'),
            ),
          ),
        );
    }
  }
}
