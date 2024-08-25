import 'package:flutter/material.dart';

class CInput extends StatelessWidget {
  Function(String) onChanged;
  int? maxLength;
  TextStyle? style;
  String? Function(String?)? validator;
  InputDecoration? decoration;

  CInput(
      {Key? key,
      required this.onChanged,
      this.maxLength,
      this.style,
      this.validator,
      this.decoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 21),
      validator: validator,
      decoration: decoration,
    );
  }
}
