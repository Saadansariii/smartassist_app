import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/pages/Calendar/calender.dart';
import 'package:smart_assist/pages/Leads/home_screen.dart';
import 'package:smart_assist/pages/Leads/opportunity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key});

  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.selectedIndex.value]),
        ],
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(controller), // ✅ Ensure this is included
    );
  }
}

// ✅ Bottom Navigation Bar
Widget _buildBottomNavigationBar(NavigationController controller) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        )
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Enquiry',
                  index: 0,
                  isIcon: true,
                  isImg: false,
                  controller: controller),
              // SizedBox(width: 10), // Space for the FAB
              _buildNavItem(
                  isImg: true,
                  isIcon: false,
                  img: Image.asset(
                    'assets/calendar.png',
                    fit: BoxFit.contain,
                  ),
                  label: 'Calendar',
                  index: 2,
                  controller: controller),
            ],
          ),
        ),
      ),
    ),
  );
}

// ✅ Bottom Navigation Bar Item
Widget _buildNavItem({
  Image? img, // made nullable
  IconData? icon, // made nullable
  required String label,
  required int index,
  required NavigationController controller,
  required bool isImg,
  required bool isIcon,
}) {
  final isSelected = controller.selectedIndex.value == index;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        controller.selectedIndex.value = index;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.2 : 1.0,
              child: isImg && img != null
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? AppColors.colorsBlue
                              : AppColors.iconGrey,
                          BlendMode.srcIn,
                        ),
                        child: img,
                      ),
                    )
                  : isIcon && icon != null
                      ? Icon(
                          icon,
                          color: isSelected
                              ? AppColors.colorsBlue
                              : AppColors.iconGrey,
                          size: 22,
                        )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.colorsBlue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ✅ Navigation Controller
class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isFabExpanded = false.obs;
  final screens = [
    const HomeScreen(greeting: '', leadId: ''),
    const Opportunity(leadId: ''),
    const Calender(leadId: '', leadName: ''),
  ];
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_assist/config/component/color/colors.dart';
// import 'package:smart_assist/pages/calenderPages/calender.dart';
// import 'package:smart_assist/pages/home_screens/home_screen.dart';
// import 'package:smart_assist/pages/home_screens/opportunity.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:smart_assist/widgets/home_btn.dart/popups_model/appointment_popup.dart';
// import 'package:smart_assist/widgets/home_btn.dart/popups_model/create_followups/create_Followups_popups.dart';
// import 'package:smart_assist/widgets/home_btn.dart/popups_model/create_leads.dart';

// class BottomNavigation extends StatelessWidget {
//   BottomNavigation({super.key});

//   final NavigationController controller = Get.put(NavigationController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Obx(() => controller.screens[controller.selectedIndex.value]),

//           // Draggable Floating Popup
//           Obx(() => controller.isFabExpanded.value
//               ? _buildDraggablePopupMenu(controller, context)
//               : const SizedBox.shrink()),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton:
//           Obx(() => _buildFloatingActionButton(controller, context)),
//       bottomNavigationBar: _buildBottomNavigationBar(controller),
//     );
//   }
// }

// // ✅ Floating Action Button (FAB)
// Widget _buildFloatingActionButton(
//     NavigationController controller, BuildContext context) {
//   return GestureDetector(
//     onLongPress: () {
//       HapticFeedback.lightImpact();
//       controller.isFabExpanded.value = true;
//     },
//     child: Container(
//       width: MediaQuery.of(context).size.width * .18,
//       height: MediaQuery.of(context).size.height * .1,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white, width: 2),
//         color: AppColors.colorsBlue,
//         shape: BoxShape.circle,
//       ),
//       child: Center(
//         child: Icon(
//           controller.isFabExpanded.value ? Icons.close : Icons.add,
//           color: Colors.white,
//           size: 30,
//         ),
//       ),
//     ),
//   );
// }

// // ✅ Draggable Popup Menu
// Widget _buildDraggablePopupMenu(
//     NavigationController controller, BuildContext context) {
//   return Positioned.fill(
//     child: Stack(
//       alignment: Alignment.center,
//       children: [
//         GestureDetector(
//           onTap: () => controller.isFabExpanded.value = false,
//           child: Container(
//             color: Colors.black.withOpacity(0.7),
//           ),
//         ),

//         // Draggable Menu Item
//         Draggable<String>(
//           data: "popup",
//           feedback: _buildPopupMenu(context),
//           child: _buildPopupMenu(context),
//           childWhenDragging: const SizedBox.shrink(),
//           onDragEnd: (details) {
//             controller.isFabExpanded.value = false;
//           },
//         ),

//         // Drop Targets for Popup Items
//         _buildDragTarget(
//             controller,
//             "Appointment",
//             Icons.calendar_month_outlined,
//             -130,
//             120,
//             () => _showAppointmentPopup(context)),
//         _buildDragTarget(controller, "Lead", Icons.people_alt_rounded, -65, 40,
//             () => _showLeadPopup(context)),
//         _buildDragTarget(controller, "Followup", Icons.call, 5, 40,
//             () => _showFollowupPopup(context)),
//       ],
//     ),
//   );
// }

// // ✅ Draggable Popup Menu Items
// Widget _buildPopupMenu(BuildContext context) {
//   return Material(
//     color: Colors.transparent,
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _popupItem(Icons.calendar_month_outlined, "Appointment"),
//         _popupItem(Icons.people_alt_rounded, "Lead"),
//         _popupItem(Icons.call, "Followup"),
//       ],
//     ),
//   );
// }

// Widget _popupItem(IconData icon, String label) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(30),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.blue, size: 24),
//         const SizedBox(width: 10),
//         Text(label, style: GoogleFonts.poppins(fontSize: 14)),
//       ],
//     ),
//   );
// }

// // ✅ Drag Target for Popup Menu Items
// Widget _buildDragTarget(NavigationController controller, String label,
//     IconData icon, double dx, double dy, Function() onTap) {
//   return Positioned(
//     left: MediaQuery.of(controller.screens[0].context!).size.width / 2 + dx,
//     top: MediaQuery.of(controller.screens[0].context!).size.height / 2 + dy,
//     child: DragTarget<String>(
//       builder: (context, candidateData, rejectedData) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: candidateData.isNotEmpty
//                     ? Colors.blue.withOpacity(0.5)
//                     : Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Icon(icon, color: Colors.blue, size: 24),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         );
//       },
//       onAccept: (data) {
//         if (data == "popup") {
//           onTap();
//         }
//       },
//     ),
//   );
// }

// // ✅ Functions to Show Popups
// void _showLeadPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const CreateLeads(),
//         ),
//       );
//     },
//   );
// }

// void _showFollowupPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const CreateFollowupsPopups(),
//         ),
//       );
//     },
//   );
// }

// void _showAppointmentPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const AppointmentPopup(),
//         ),
//       );
//     },
//   );
// }

// // ✅ Navigation Controller
// class NavigationController extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//   final RxBool isFabExpanded = false.obs;
//   final screens = [
//     const HomeScreen(greeting: '', leadId: ''),
//     const Opportunity(leadId: ''),
//     const Calender(leadId: '', leadName: ''),
//   ];
// }
