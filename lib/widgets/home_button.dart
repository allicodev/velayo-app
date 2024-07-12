import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';

class HomeButton extends StatefulWidget {
  final HomeButtonValues value;
  final Function onClick;
  final bool isSelected;
  HomeButton(
      {Key? key,
      required this.value,
      required this.onClick,
      required this.isSelected})
      : super(key: key);

  @override
  State<HomeButton> createState() => _HomeButton();
}

class _HomeButton extends State<HomeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  int inputQuantity = 1;
  double _scaleTransformValue = 1;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scaleTransformValue,
      child: Material(
        color: widget.isSelected ? ACCENT_SECONDARY : ACCENT_PRIMARY,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            animationController.forward();
            Future.delayed(
              const Duration(milliseconds: 100),
              () => animationController.reverse(),
            );

            widget.onClick();
          },
          hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (widget.value.icon != null)
                //   Icon(
                //     widget.value.icon,
                //     size: 34.0,
                //     color: Colors.white,
                //   ),
                Text(
                  widget.value.title,
                  style: const TextStyle(
                      fontSize: 23.0,
                      fontFamily: 'Abel',
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}
