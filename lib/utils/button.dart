import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;

  const Button(this.text, {super.key, required TextStyle style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
