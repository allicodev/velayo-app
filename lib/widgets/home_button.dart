import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';

class HomeButton extends StatelessWidget {
  final HomeButtonValues value;
  final Function onClick;
  final bool isSelected;
  const HomeButton(
      {Key? key,
      required this.value,
      required this.onClick,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ACCENT_SECONDARY : ACCENT_PRIMARY,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => isSelected ? null : onClick(),
        hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (value.icon != null)
                Icon(
                  value.icon,
                  size: 50.0,
                  color: Colors.white,
                ),
              Text(
                value.title,
                style: const TextStyle(
                    fontSize: 36.0, fontFamily: 'Abel', color: Colors.white),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
