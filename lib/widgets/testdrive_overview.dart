import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smart_assist/utils/storage.dart';

class TestdriveOverview extends StatefulWidget {
  final String eventId;
  final String leadId;
  const TestdriveOverview(
      {super.key, required this.eventId, required this.leadId});

  @override
  State<TestdriveOverview> createState() => _TestdriveOverviewState();
}

class _TestdriveOverviewState extends State<TestdriveOverview> {
  // Define variables to hold the data

  String startTime = '';
  String distanceCovered = '';
  String mapImgUrl = '';
  bool isLoading = false;
  String potentialPurchase = '';
  Map<String, dynamic> ratings = {};

  @override
  void initState() {
    super.initState();
    _fetchTestDriveData();
  }

  Future<void> _fetchTestDriveData() async {
    // final url = Uri.parse(
    //     'https://api.smartassistapp.in/api/events/7cf0f7e5-d10d-492a-80e8-54bb6e575605');
    final token = await Storage.getToken();
    final response = await http.get(
        Uri.parse('https://api.smartassistapp.in/api/events/${widget.eventId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
    // final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        startTime = data['data']['start_time'];
        distanceCovered = data['data']['distance'] + ' km';
        mapImgUrl = data['data']['map_img'] ?? '';
        potentialPurchase = data['data']['purchase_potential'];
        ratings = data['data']['drive_feedback'];
      });
    } else {
      print('Failed to fetch test drive data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Drive Summary'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map image
                    if (mapImgUrl.isNotEmpty) Image.network(mapImgUrl),

                    SizedBox(height: 20),

                    // Start time
                    Text('Start Time: $startTime',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),

                    // Distance covered
                    SizedBox(height: 10),
                    Text('Distance covered: $distanceCovered',
                        style: TextStyle(fontSize: 16)),

                    // Ratings
                    SizedBox(height: 20),
                    Text('Ratings:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _buildRatingRow('Overall Ambience', ratings['ambience']),
                    _buildRatingRow('Features', ratings['features']),
                    _buildRatingRow(
                        'Ride and Comfort', ratings['ride_comfort']),
                    _buildRatingRow('Quality', ratings['quality']),
                    _buildRatingRow('Dynamics', ratings['dynamics']),
                    _buildRatingRow(
                        'Driving Experience', ratings['driving_experience']),

                    // Potential of purchase
                    SizedBox(height: 20),
                    Text('Potential of Purchase: $potentialPurchase',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build the rating rows
  Widget _buildRatingRow(String label, int? rating) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 14)),
        IconTheme(
          data: IconThemeData(color: Colors.orange),
          child: Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (rating ?? 0) ? Icons.star : Icons.star_border,
                size: 18,
              );
            }),
          ),
        ),
      ],
    );
  }
}
