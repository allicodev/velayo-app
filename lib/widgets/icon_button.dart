import 'package:flutter/material.dart';

enum MiscIconButtonType { circle, rectangle }

class MiscIconButton extends StatelessWidget {
  Icon icon;
  VoidCallback onPress;
  MiscIconButtonType shape;
  double? borderWidth;
  MiscIconButton(
      {Key? key,
      required this.icon,
      required this.onPress,
      this.shape = MiscIconButtonType.rectangle,
      this.borderWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = shape == MiscIconButtonType.rectangle
        ? BorderRadius.circular(4.0)
        : BorderRadius.circular(100.0);
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(width: borderWidth ?? 1, color: Colors.black38),
            borderRadius: borderRadius),
        child: InkWell(
          onTap: onPress,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}
