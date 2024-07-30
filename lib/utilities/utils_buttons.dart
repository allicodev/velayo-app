import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UtilsButtonOverride extends StatefulWidget {
  Widget child;
  Function callback;
  UtilsButtonOverride({Key? key, required this.child, required this.callback})
      : super(key: key);

  @override
  State<UtilsButtonOverride> createState() => _UtilsButtonOverride();
}

class _UtilsButtonOverride extends State<UtilsButtonOverride> {
  Timer? _timer;
  int pressCounter = 0;

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      canRequestFocus: true,
      onKey: (data, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.audioVolumeUp)) {
          print("Volume up");

          _timer?.cancel();
          if (++pressCounter == 3) {
            widget.callback();
          }

          _timer = Timer(const Duration(seconds: 1), () {
            pressCounter = 0;
          });

          setState(() {});
          return KeyEventResult.handled;
        }
        if (event.isKeyPressed(LogicalKeyboardKey.audioVolumeDown)) {
          print("Volume down");

          _timer?.cancel();
          if (++pressCounter == 3) {
            widget.callback();
          }

          _timer = Timer(const Duration(seconds: 1), () {
            pressCounter = 0;
          });

          setState(() {});
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
