import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FabController extends GetxController {
  final RxBool isFabExpanded = false.obs;

  void toggleFab() {
    HapticFeedback.lightImpact();
    isFabExpanded.toggle();
  }

  void closeFab() {
    isFabExpanded.value = false;
  }
}
