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
import 'package:smart_assist/widgets/timeline_view_calender.dart'; // Adjust your imports based on your actual page locations

class NavigationController extends GetxController {
  // Observable to track selected index in bottom navigation
  // final RxInt selectedIndex = 0.obs;
  var selectedIndex = 0.obs;

  // Define screens corresponding to the navigation items
  List<Widget> get screens => [
        HomeScreen(
          greeting: '',
          leadId: '',
        ), // Replace with your actual screen widget
        const MyTeams(), // Replace with your actual screen widget
        CalendarWithTimeline(
          leadName: '',
        ), // Replace with your actual screen widget
      ];

  @override
  void onInit() {
    super.onInit();
    _setInitialScreen();
  }

  Future<void> _setInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teamRole = prefs.getString('USER_ROLE');

    if (teamRole != null && teamRole.isNotEmpty) {
      selectedIndex.value = 1; // Teams screen
    } else {
      selectedIndex.value = 0; // Home screen
    }
  }

  // Method to set selected index for bottom navigation
  // void setSelectedIndex(int index) {
  //   selectedIndex.value = index;
  // }
}
