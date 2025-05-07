import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // For progress bars
import 'package:get/get.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smart_assist/utils/storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String? name, email, location, mobile, userRole;
  double rating = 0.0;
  double professionalism = 0.0;
  double efficiency = 0.0;
  double responseTime = 0.0;
  double productKnowledge = 0.0;

  // Fetch profile data from API
  Future<void> fetchProfileData() async {
    final token = await Storage.getToken();
    final response = await http.get(
        Uri.parse('https://api.smartassistapp.in/api/users/show-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        name = data['data']['name'];
        email = data['data']['email'];
        location = data['data']['dealer_location'];
        mobile = data['data']['phone'];
        userRole = data['data']['user_role'];
        rating = data['data']['rating'] != null
            ? data['data']['rating'].toDouble()
            : 0.0;

        // Convert evaluation scores from 0-10 scale to 0.0-1.0 percentages
        final evaluation = data['data']['evaluation'];
        if (evaluation != null) {
          professionalism = evaluation['professionalism'] != null
              ? evaluation['professionalism'] / 10
              : 0.0;
          efficiency = evaluation['efficiency'] != null
              ? evaluation['efficiency'] / 10
              : 0.0;
          responseTime = evaluation['responseTime'] != null
              ? evaluation['responseTime'] / 10
              : 0.0;
          productKnowledge = evaluation['productKnowledge'] != null
              ? evaluation['productKnowledge'] / 10
              : 0.0;
        }

        isLoading = false;
      });
    } else {
      // Handle the error
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch profile data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.white,
          ),
        ),
        title: Text('Profile', style: AppFont.appbarfontWhite(context)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          NetworkImage('https://www.example.com/profile.jpg'),
                      child: Icon(
                        Icons.person,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name ?? '', style: AppFont.popupTitleBlack(context)),
                    Text(userRole ?? 'User',
                        style: AppFont.mediumText14(context)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: index < rating
                              ? AppColors.starColorsYellow
                              : Colors.grey,
                          size: 38,
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text('(45 reviews)', style: AppFont.mediumText14(context)),
                    const SizedBox(height: 10),
                    // Profile details (Email, Location, Mobile)
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.backgroundLightGrey,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileItem('Email', email ?? ''),
                              const SizedBox(
                                height: 10,
                              ),
                              _buildProfileItem('Location', location ?? ''),
                              const SizedBox(
                                height: 10,
                              ),
                              _buildProfileItem('Mobile', mobile ?? '')
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Evaluation Progress Bars
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.backgroundLightGrey,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 15),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Evaluation',
                                    style: AppFont.popupTitleBlack16(context)),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            _buildEvaluationProgress(
                                'Professionalism', professionalism),
                            const SizedBox(
                              height: 5,
                            ),
                            _buildEvaluationProgress(
                                'Efficiency of service call handling',
                                efficiency),
                            const SizedBox(
                              height: 5,
                            ),
                            _buildEvaluationProgress(
                                'Response time of service calls', responseTime),
                            const SizedBox(
                              height: 5,
                            ),
                            _buildEvaluationProgress(
                                'Product Knowledge & Brand Representation',
                                productKnowledge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
                softWrap: true,
                maxLines: 3,
                label,
                style: AppFont.mediumText14(context))),
        const SizedBox(height: 5),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
                softWrap: true,
                maxLines: 3,
                value,
                style: AppFont.dropDowmLabel(context))),
      ],
    );
  }

  Widget _buildEvaluationProgress(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(label, style: AppFont.dropDowmLabel(context)),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getGradientForProgress(percentage).last),
            softWrap: true,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          lineHeight: 14.0,
          percent: percentage,
          backgroundColor: Colors.grey[200]!,
          barRadius: const Radius.circular(8),
          linearGradient: LinearGradient(
            colors: _getGradientForProgress(percentage),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  List<Color> _getGradientForProgress(double percentage) {
    if (percentage >= 0.8) {
      return [
        Color.fromRGBO(255, 237, 215, 0.9),
        Color.fromRGBO(83, 157, 243, 1),
        Color.fromRGBO(144, 109, 250, 1),
      ];
    } else if (percentage >= 0.6) {
      return [
        Color.fromRGBO(229, 208, 210, 1),
        Color.fromRGBO(255, 150, 165, 1),
        Color.fromRGBO(255, 122, 113, 1),
      ];
    } else if (percentage >= 0.3) {
      return [
        Color.fromRGBO(254, 221, 176, 1),
        Color.fromRGBO(144, 109, 250, 1),
        // Color.fromRGBO(255, 237, 215, 0.9),
        Color.fromRGBO(255, 122, 113, 1),
      ];
    } else {
      return [
        Color.fromRGBO(182, 247, 249, 1),
        Color.fromRGBO(168, 230, 251, 1),
        Color.fromRGBO(196, 201, 255, 1),
      ];
    }
  }

  // List<Color> _getGradientForProgress(double percentage) {
  //   if (percentage >= 0.8) {
  //     return [
  //       Color.fromRGBO(255, 237, 215, 0.9),
  //       Color.fromRGBO(83, 157, 243, 1),
  //       Color.fromRGBO(144, 109, 250, 1),
  //     ];
  //   } else if (percentage >= 0.6) {
  //     return [
  //       Color.fromRGBO(254, 221, 176, 1),
  //       Color.fromRGBO(144, 109, 250, 1),
  //       Color.fromRGBO(255, 237, 215, 0.9),
  //     ];
  //   } else if (percentage >= 0.5) {
  //     return [
  //       Color.fromRGBO(229, 208, 210, 1),
  //       Color.fromRGBO(255, 150, 165, 1),
  //       Color.fromRGBO(255, 122, 113, 1),
  //     ];
  //   } else {
  //     return [
  //       Color.fromRGBO(182, 247, 249, 1),
  //       Color.fromRGBO(168, 230, 251, 1),
  //       Color.fromRGBO(196, 201, 255, 1),
  //     ];
  //   }
  // }
}
