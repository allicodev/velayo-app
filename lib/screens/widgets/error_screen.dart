import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  const ErrorScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
