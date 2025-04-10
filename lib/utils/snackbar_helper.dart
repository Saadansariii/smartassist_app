import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, {required String message}) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showSuccessMessage(BuildContext context, {required String message}) {
  final snackBar = SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
