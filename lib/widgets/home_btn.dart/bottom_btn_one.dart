import 'package:flutter/material.dart';

class BottomBtnOne extends StatefulWidget {
  const BottomBtnOne({super.key});

  @override
  _BottomBtnOneState createState() => _BottomBtnOneState();
}

class _BottomBtnOneState extends State<BottomBtnOne> {
  int _leadButton = 0; // Initially set to 'Leads'
  int _selectedBtnIndex = 0; // This is to track selected button index
  final List<String> _buttonLabels = ['Leads', 'Test Drive', 'Orders'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE1EFFF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 40, // Set height for the container
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Row(
                  children: [
                    // Follow Ups Button
                    _buildResponsiveButton(
                      label: 'Leads',
                      index: 0,
                      onPressed: () {
                        setState(() {
                          _leadButton = 0; // Set Follow Ups as active
                          _selectedBtnIndex = 0;
                        });
                      },
                    ),

                    // Appointments Button
                    _buildResponsiveButton(
                      label: 'Test Drive',
                      index: 1,
                      onPressed: () {
                        setState(() {
                          _leadButton = 1; // Set Appointments as active
                          _selectedBtnIndex = 1;
                        });
                      },
                    ),

                    // Orders Button
                    _buildResponsiveButton(
                      label: 'Orderss',
                      index: 2,
                      onPressed: () {
                        setState(() {
                          _leadButton = 2; // Set Orders as active
                          _selectedBtnIndex = 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display the selected button label
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Selected: ${_buttonLabels[_selectedBtnIndex]}', // Show the selected button label
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable method to create buttons with responsive sizes
  Widget _buildResponsiveButton({
    required String label,
    required int index,
    required VoidCallback onPressed,
  }) {
    double buttonWidth = MediaQuery.of(context).size.width /
        4; // Adjust width based on screen size

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: _leadButton == index
              ? const Color(0xFF1380FE) // Active color (blue)
              : Colors.transparent, // No background for inactive buttons
          foregroundColor: _leadButton == index
              ? Colors.white // Active text color (white)
              : Colors.black, // Inactive text color (black)
          minimumSize: Size(buttonWidth, 40), // Adjust button size
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
