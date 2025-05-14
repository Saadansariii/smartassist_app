import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FabController extends GetxController {
  final RxBool isFabExpanded = false.obs;
  var isFabDisabled = false.obs; // Variable to track disabled state

  void toggleFab() {
    // Only toggle if the FAB is not disabled
    if (!isFabDisabled.value) {
      HapticFeedback.lightImpact();
      isFabExpanded
          .toggle(); // This already toggles the value, don't need to do it twice
    }
  }

  // Method to disable FAB temporarily
  void temporarilyDisableFab() {
    isFabDisabled.value = true;

    // Make sure FAB is closed when disabled
    isFabExpanded.value = false;

    // Enable after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      isFabDisabled.value = false;
    });
  }

  void closeFab() {
    isFabExpanded.value = false;
  }
}
