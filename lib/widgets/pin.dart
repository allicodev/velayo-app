import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class Pin extends StatefulWidget {
  int length;
  void Function(String) onComplete;
  void Function(String)? onChange;
  bool disabled;
  bool autoFocus;
  FocusNode? focus;
  Pin(
      {Key? key,
      required this.length,
      required this.onComplete,
      this.disabled = false,
      this.autoFocus = true,
      this.focus,
      this.onChange})
      : super(key: key);

  @override
  State<Pin> createState() => _FilledRoundedPinPutState();
}

class _FilledRoundedPinPutState extends State<Pin> {
  final controller = TextEditingController();
  late FocusNode focusNode;
  int length = 4;
  bool isDisabled = false;
  bool autoFocus = true;

  @override
  void initState() {
    setState(() {
      length = widget.length;
      isDisabled = widget.disabled;
      focusNode = widget.focus ?? FocusNode();
      autoFocus = widget.autoFocus;
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return SizedBox(
      height: 68,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        autofocus: autoFocus,
        obscureText: true,
        enableSuggestions: false,
        enabled: !isDisabled,
        onChanged: widget.onChange,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onCompleted: (pin) {
          widget.onComplete(pin);
        },
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
