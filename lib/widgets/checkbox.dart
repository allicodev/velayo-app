import 'package:flutter/material.dart';

class CheckBox extends StatefulWidget {
  String title;
  Function(bool) onChanged;
  CheckBox({Key? key, required this.title, required this.onChanged})
      : super(key: key);

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  double _scaleTransformValue = 1;
  bool checked = false;

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
    return FittedBox(
      fit: BoxFit.contain,
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: GestureDetector(
          onTap: () {
            animationController.forward();
            Future.delayed(
              const Duration(milliseconds: 100),
              () => animationController.reverse(),
            );
            setState(() => checked = !checked);
            widget.onChanged(checked);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                      value: checked,
                      onChanged: (value) {
                        setState(() => checked = value!);
                        widget.onChanged(value!);
                      })),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 21.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
