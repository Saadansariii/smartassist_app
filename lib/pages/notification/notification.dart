import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/pages/Leads/single_details_pages/singleLead_followup.dart';
import 'package:smart_assist/pages/home/single_details_pages/singleLead_followup.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/bottom_navigation.dart';
import 'package:smart_assist/utils/storage.dart';

class NotificationPage extends StatefulWidget {
  // final String leadId;
  const NotificationPage({
    super.key,
    // required this.leadId,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedButtonIndex = 0;
  List<dynamic> notifications = [];
  bool result = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    // fetchNotifications();
  }

  final Map<String, String> categoryMap = {
    'All': 'All',
    'Leads': 'leads',
    'Followups': 'followups',
    'Appointment': 'appointment',
    'Test drive': 'test drive',
  };

  final List<String> categories = [
    'All',
    'Leads',
    'Followups',
    'Appointment',
    'Test drive',
  ];

  Future<void> fetchNotifications({String? category}) async {
    final token = await Storage.getToken();
    String url = 'https://dev.smartassistapp.in/api/users/notifications/all';

    if (category != null && category != 'All') {
      String formattedCategory =
          category.replaceAll(' ', ''); // ✅ Remove spaces completely
      url += '?category=$formattedCategory';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Fetching notifications from URL: $url');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<dynamic> allNotifications = [];
        if (data['data']['unread'] != null &&
            data['data']['unread']['rows'] != null) {
          allNotifications.addAll(data['data']['unread']['rows']);
        }
        if (data['data']['read'] != null &&
            data['data']['read']['rows'] != null) {
          allNotifications.addAll(data['data']['read']['rows']);
        }

        print(data);
        setState(() {
          notifications = allNotifications;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchNotifications();
  // }

  // Mark notification as read
  // Mark notification as read

  Future<void> markAsRead(String notificationId) async {
    final token = await Storage.getToken();
    final url =
        'https://dev.smartassistapp.in/api/users/notifications/$notificationId'; // Ensure this URL is correct

    print(
        'Marking notification as read with URL: $url'); // Log the URL being used for debugging

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'read': true,
        }),
      );

      print(
          'Response status: ${response.statusCode}'); // Log status code for debugging

      if (response.statusCode == 200) {
        print('Successfully marked notification as read');
        setState(() {
          // Mark the notification as read and filter out all read notifications
          notifications = notifications.where((notification) {
            if (notification['data']['notification_id'] == notificationId) {
              notification['data']['read'] = true;
              return false; // Exclude this notification from the list
            }
            return true; // Keep all other notifications
          }).toList();
        });
      } else {
        print("Failed to mark as read: ${response.statusCode}");
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Widget _buildButton(String title, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * .034,
          decoration: BoxDecoration(
            border: _selectedButtonIndex == index
                ? Border.all(color: Colors.blue)
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xffF3F9FF),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                _selectedButtonIndex = index;
              });
              fetchNotifications(category: categoryMap[categories[index]]);
              // fetchNotifications(category: categories[index]);
            },
            child: Text(
              // title,
              categories[index],
              style: GoogleFonts.poppins(
                color: _selectedButtonIndex == index
                    ? Colors.blue
                    : AppColors.fontColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavigation(),
              ),
            );
          },
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(categories.length, (index) {
              return _buildButton(categories[index], index);
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 5, 0, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notification',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fontColor),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.isNotEmpty
                  ? notifications
                      .where((notification) => notification['read'] == false)
                      .length
                  : 0,
              itemBuilder: (context, index) {
                // Only show notifications that are unread
                final notification = notifications
                    .where((notification) => notification['read'] == false)
                    .toList()[index];

                bool isRead = notification['read'] ?? false;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        // onTap: () {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => FollowupsDetails(
                        //               leadId: notification['recordId'] ?? '')));
                        //   if (!isRead) {
                        //     markAsRead(notification['notification_id']);
                        //   }
                        //   // Refresh only if something changed
                        //   if (result == true) {
                        //     fetchNotifications(
                        //         category: categories[_selectedButtonIndex]);
                        //   }
                        // },

                        onTap: () async {
                          if (!isRead) {
                            await markAsRead(notification['notification_id']);
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowupsDetails(
                                leadId: notification['recordId'] ?? '',
                              ),
                            ),
                          );

                          // Refresh only if something changed
                          if (result == true) {
                            fetchNotifications(
                                category: categories[_selectedButtonIndex]);
                          }
                        },

                        child: Card(
                          color: isRead ? Colors.white : Colors.white,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          semanticContainer: false,
                          borderOnForeground: false,
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: Icon(
                              Icons.circle,
                              color: isRead ? Colors.grey : Colors.blue,
                              size: 10,
                            ),
                            title: Text(
                              notification['title'] ?? 'No Title',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              notification['body'] ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 0.1,
                      color: Colors.black,
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                );
              },
            ),
          )

          // Expanded(
          //   child: ListView.builder(
          //     itemCount: notifications.length,
          //     itemBuilder: (context, index) {
          // final notification = notifications[index];

          //       bool isRead = notification['read'] ?? false;

          //       return Column(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 10),
          //             child: GestureDetector(
          //               onTap: () {
          //                 Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) => FollowupsDetails(
          //                             leadId: notification['recordId'] ?? '')));
          //                 if (!isRead) {
          //                   markAsRead(notification['notification_id']);
          //                 }
          //               },
          //               child: Card(
          //                 color: isRead ? Colors.white : Colors.white,
          //                 shape: const RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.zero),
          //                 semanticContainer: false,
          //                 borderOnForeground: false,
          //                 elevation: 0,
          //                 margin: const EdgeInsets.symmetric(vertical: 2),
          //                 child: ListTile(
          //                   leading: Icon(
          //                     Icons.circle,
          //                     color: isRead ? Colors.grey : Colors.blue,
          //                     size: 10,
          //                   ),
          //                   title: Text(
          //                     notification['title'] ?? 'No Title',
          //                     style: GoogleFonts.poppins(
          //                         fontWeight: FontWeight.w600, fontSize: 14),
          //                   ),
          //                   subtitle: Text(
          //                     notification['body'] ?? '',
          //                     style: GoogleFonts.poppins(
          //                         fontSize: 12, fontWeight: FontWeight.w400),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //           const Divider(
          //             thickness: 0.1,
          //             color: Colors.black,
          //             indent: 10,
          //             endIndent: 10,
          //           ),
          //         ],
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
