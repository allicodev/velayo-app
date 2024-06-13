import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class PinUpdate extends StatelessWidget {
  const PinUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode focus1 = FocusNode();
    FocusNode focus2 = FocusNode();

    const style = TextStyle(fontFamily: "abel", fontSize: 22);

    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("OLD PIN", style: style),
              Pin(
                  length: 6,
                  onComplete: (pin) {
                    focus1.nextFocus();
                  }),
              const SizedBox(height: 25),
              const Text("NEW PIN", style: style),
              Pin(
                  length: 6,
                  focus: focus1,
                  onComplete: (pin) {
                    focus2.requestFocus();
                  }),
              const SizedBox(height: 25),
              const Text("CONFIRM PIN", style: style),
              Pin(length: 6, focus: focus2, onComplete: (pin) {}),
            ],
          ),
        )));
  }
}
