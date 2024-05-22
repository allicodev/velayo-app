import 'package:flutter/material.dart';

class HomeButtonValues {
  String title;
  String? description;
  IconData? icon;
  Function? onClick;

  HomeButtonValues(
      {required this.title, this.description, this.onClick, this.icon});
}
