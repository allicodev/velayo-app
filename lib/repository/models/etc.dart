// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class HomeButtonValues {
  String title;
  String? description;
  IconData? icon;
  Function? onClick;

  HomeButtonValues(
      {required this.title, this.description, this.onClick, this.icon});
}

class BranchItemUpdate {
  String id;
  int count;
  BranchItemUpdate({
    required this.id,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'count': count,
    };
  }

  String toJson() => json.encode(toMap());
}
