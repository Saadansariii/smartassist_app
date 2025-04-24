import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/pages/Calendar/calender.dart';
import 'package:smart_assist/pages/Leads/home_screen.dart';
import 'package:smart_assist/pages/Leads/opportunity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:smart_assist/pages/navbar_page/my_teams.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/widgets/timeline_view_calender.dart';
import 'package:table_calendar/table_calendar.dart';

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
// class NavigationController extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//   final RxBool isFabExpanded = false.obs;
//   final screens = [
//     const HomeScreen(greeting: '', leadId: ''),
//     const Opportunity(leadId: ''),
//     // const MyTeams(),
//     const Calender(leadId: '', leadName: ''),
//     // TimelineView(selectedDate: selectedDate, appointments: appointments, onDateSelected: onDateSelected)
//   ];
// }

// ✅ Navigation Controller
// ✅ Navigation Controller for Calendar Integration
class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isFabExpanded = false.obs;

  // Add selected date and appointments as observable properties
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList appointments = [].obs;
  final RxList tasks = [].obs;
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  // Method to fetch initial data
  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchAppointments(selectedDate.value),
      fetchTasks(selectedDate.value)
    ]);
  }

  // Method to fetch appointments
  Future<void> fetchAppointments(DateTime date) async {
    try {
      final data = await LeadsSrv.fetchAppointments(date);
      appointments.value = data;
    } catch (e) {
      print('Error fetching appointments: $e');
      appointments.value = []; // Set to empty list on error
    }
  }

  // Method to fetch tasks
  Future<void> fetchTasks(DateTime date) async {
    try {
      final data = await LeadsSrv.fetchtasks(date);
      tasks.value = data;
    } catch (e) {
      print('Error fetching tasks: $e');
      tasks.value = []; // Set to empty list on error
    }
  }

  // Method to handle date selection
  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    fetchAppointments(date);
    fetchTasks(date);
  }

  // Use a getter for screens to ensure it always uses current values
  List<Widget> get screens => [
        const HomeScreen(greeting: '', leadId: ''),
        const Opportunity(leadId: ''),
        // Replace Calendar with CalendarWithTimeline widget
        // const Calender(leadId: '', leadName: ''),
        CalendarWithTimeline(
          leadId: '',
          leadName: '',
        ),
      ];
}
