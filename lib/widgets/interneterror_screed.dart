// lib/widgets/internet_error_widget.dart
import 'package:flutter/material.dart';

class InternetErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  final IconData icon;
  final Widget? customWidget;
  
  const InternetErrorWidget({
    Key? key,
    required this.onRetry,
    this.message = 'No internet connection',
    this.icon = Icons.signal_wifi_off,
    this.customWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customWidget ?? Icon(icon, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}