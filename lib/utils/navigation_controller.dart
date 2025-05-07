// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:smart_assist/pages/Leads/home_screen.dart';
// import 'package:smart_assist/pages/navbar_page/my_teams.dart';
// import 'package:smart_assist/pages/Calendar/calender.dart';
// import 'package:smart_assist/widgets/timeline_view_calender.dart'; // Adjust your imports based on your actual page locations

// class NavigationController extends GetxController {
//   // Observable to track selected index in bottom navigation
//   final RxInt selectedIndex = 0.obs;

//   // Define screens corresponding to the navigation items
//   List<Widget> get screens => [
//         HomeScreen(
//           greeting: '',
//           leadId: '',
//         ), // Replace with your actual screen widget
//         const MyTeams(), // Replace with your actual screen widget
//         CalendarWithTimeline(
//           leadName: '',
//         ), // Replace with your actual screen widget
//       ];

//   // Method to set selected index for bottom navigation
//   void setSelectedIndex(int index) {
//     selectedIndex.value = index;
//   }
// }

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/pages/Leads/home_screen.dart';
import 'package:smart_assist/pages/navbar_page/my_teams.dart';
import 'package:smart_assist/pages/Calendar/calender.dart';
import 'package:smart_assist/utils/token_manager.dart';
import 'package:smart_assist/widgets/myteam.dart';
import 'package:smart_assist/widgets/timeline_view_calender.dart'; // Adjust your imports based on your actual page locations

// class NavigationController extends GetxController {
//   // Observable to track selected index in bottom navigation
//   // final RxInt selectedIndex = 0.obs;
//   var selectedIndex = 0.obs;
//   var userRole = ''.obs; // Observable to track user role

// Define screens corresponding to the navigation items
//   List<Widget> get screens => [
//         HomeScreen(
//           greeting: '',
//           leadId: '',
//         ), // Replace with your actual screen widget
//         const MyTeams(), // Replace with your actual screen widget
//         CalendarWithTimeline(
//           leadName: '',
//         ), // Replace with your actual screen widget
//       ];

//   @override
//   void onInit() {
//     super.onInit();
//     _setInitialScreen();
//   }

//   Future<void> _setInitialScreen() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? teamRole = prefs.getString('USER_ROLE');

//     if (teamRole != null && teamRole.isNotEmpty) {
//       selectedIndex.value = 1; // Teams screen
//     } else {
//       selectedIndex.value = 0; // Home screen
//     }
//   }

// }

// NavigationController.dart - Fixed navigation based on user role
class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var userRole = ''.obs; // Observable to track user role

  // Define screens corresponding to the navigation items
  List<Widget> get screens {
    // Base screens that everyone sees
    List<Widget> baseScreens = [
      HomeScreen(
        greeting: '',
        leadId: '',
      ),
      // MyTeams screen is conditionally included below
      CalendarWithTimeline(
        leadName: '',
      ),
    ];

    // Insert MyTeams screen at index 1 only for SM role
    if (userRole.value == "SM") {
      baseScreens.insert(1, const MyTeams());
    }

    return baseScreens;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await TokenManager.getUserRole();
    userRole.value = role ?? '';
    _setInitialScreen();
  }

  void _setInitialScreen() {
    // For SM users, we can set default to teams screen if desired
    if (userRole.value == "SM") {
      selectedIndex.value = 1; // Teams screen
    } else {
      selectedIndex.value = 0; // Home screen
    }
  }
}
