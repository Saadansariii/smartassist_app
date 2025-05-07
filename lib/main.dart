// notification work here

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_assist/config/route/route.dart';
import 'package:smart_assist/config/route/route_name.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_assist/pages/navbar_page/my_teams.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/widgets/feedback.dart';
import 'package:smart_assist/widgets/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  await Hive.initFlutter(); // Initialize Hive after Firebase
  await NotificationService.instance.initialize(); // Initialize Notifications

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
          initialRoute: RoutesName.splashScreen,
          // home: Feedbackscreen(leadId: '', eventId: ''),
          onGenerateRoute: Routes.generateRoute,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFFFFF)),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       initialRoute: RoutesName.splashScreen, // uncomment
//       onGenerateRoute: Routes.generateRoute, // uncommment
// // home: HomeScreen(greeting: 'greeting', leadId: 'leadId'), //this line should be comment
//       // home: BottomNavigation(),
//       theme: ThemeData(
//         // buttonTheme: const ButtonThemeData(),
//         scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//         appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFFFFF)),
//       ),

//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
