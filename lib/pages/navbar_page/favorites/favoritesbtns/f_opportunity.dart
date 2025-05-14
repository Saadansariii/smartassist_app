import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_assist/utils/storage.dart';

class FOpportunity extends StatefulWidget {
  const FOpportunity({super.key});

  @override
  State<FOpportunity> createState() => _FOpportunityState();
}

class _FOpportunityState extends State<FOpportunity> {
  bool isLoading = true;
  List<dynamic> upcomingTasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasksData();
  }

  Future<void> fetchTasksData() async {
    final token = await Storage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://dev.smartassistapp.in/api/favourites/opps/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          upcomingTasks =
              data['data']['rows'] ?? []; // Store only upcoming tasks
          isLoading = false;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTasksList(upcomingTasks), // Only upcoming tasks
        ],
      ),
    );
  }

  Widget _buildTasksList(List<dynamic> tasks) {
    // Check if both lists are empty and show "No data found"
    if (upcomingTasks.isEmpty) {
      return const Center(
        child: Text('No data found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        var task = tasks[index];
        return TaskItem(
          name: task['name'] ?? 'No Name',
          date: task['due_date'] ?? 'No Date',
          vehicle: task['PMI'] ?? 'Discovery Sport',
          leadId: task['lead_id'] ?? '',
          taskId: task['task_id'] ?? '',
          isFavorite: task['favourite'] ?? false,
          onFavoriteToggled: fetchTasksData,
        );
      },
    );
  }
}

// ---------------- TASK ITEM ----------------
class TaskItem extends StatefulWidget {
  final String name;
  final String date;
  final String vehicle;
  final String leadId;
  final String taskId;
  final bool isFavorite;
  final VoidCallback onFavoriteToggled;

  const TaskItem({
    super.key,
    required this.name,
    required this.date,
    required this.vehicle,
    required this.leadId,
    required this.taskId,
    required this.isFavorite,
    required this.onFavoriteToggled,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final token = await Storage.getToken();
    try {
      final response = await http.put(
        Uri.parse(
          'https://dev.smartassistapp.in/api/favourites/mark-fav/task/${widget.taskId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskId': widget.taskId, 'favourite': !isFav}),
      );

      if (response.statusCode == 200) {
        setState(() => isFav = !isFav);
        widget.onFavoriteToggled();
      }
    } catch (e) {
      print('Error updating favorite status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              width: 8.0,
              color: Colors.green, // ✅ Always green for upcoming tasks
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? Colors.amber : Colors.grey,
                size: 40,
              ),
              onPressed: _toggleFavorite,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.blue, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        widget.date,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.vehicle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                if (widget.leadId.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/followup-details',
                    arguments: widget.leadId,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
