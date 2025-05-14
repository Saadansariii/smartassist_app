import 'package:flutter/material.dart';

class InternetErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  final String description;
  final IconData icon;
  final Widget? customWidget;

  const InternetErrorWidget({
    Key? key,
    required this.onRetry,
    this.message = 'No Internet Connection',
    this.description = 'Please check your connection and try again',
    this.icon = Icons.wifi_off_rounded,
    this.customWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const blueColor = Color(0xFF2196F3);
    const lightBlueColor = Color(0xFFBBDEFB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: lightBlueColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: customWidget ??
                Icon(
                  icon,
                  size: 72,
                  color: blueColor,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.refresh_rounded),
                SizedBox(width: 8),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
