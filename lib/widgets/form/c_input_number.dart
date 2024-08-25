import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';

class CInputNumber extends StatelessWidget {
  Function(String) onChanged;
  int? maxLength;
  TextStyle? style;
  String? Function(String?)? validator;
  InputDecoration? decoration;
  List<TextInputFormatter>? inputFormatters;
  bool? isMainAmount;
  double? fee;

  CInputNumber(
      {Key? key,
      required this.onChanged,
      this.maxLength,
      this.style,
      this.validator,
      this.decoration,
      this.inputFormatters,
      this.isMainAmount,
      this.fee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            style: style,
            validator: validator,
            decoration: decoration),
        if (isMainAmount ?? false)
          Text("+$PESO${NumberFormat('#,###').format(fee).toString()} (fee)",
              style: const TextStyle(fontSize: 18.0))
      ],
    );
  }
}
