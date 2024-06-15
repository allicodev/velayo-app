import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class PinUpdate extends StatefulWidget {
  const PinUpdate({super.key});

  @override
  State<PinUpdate> createState() => _PinSlideState();
}

class _PinSlideState extends State<PinUpdate> {
  bool _isOn = false;
  bool isValidating = false;

  Key key = const ValueKey("key1");
  Key key2 = const ValueKey("key2");
  Key key3 = const ValueKey("key3");

  TextStyle style = const TextStyle(fontFamily: "abel", fontSize: 22);

  String? pin1;
  String? pin2;
  Map<String, dynamic> error = {"show": false, "description": ""};

  @override
  Widget build(BuildContext context) {
    checkIfError() {
      if (pin1 != null && pin2 != null) {
        if (pin1 != pin2) {
          setState(() => error = {
                "show": true,
                "description":
                    "Pins are not match. Please provide a correct one."
              });
        } else {
          setState(() => error = {"show": false, "description": ""});
        }
      }
    }

    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isOn
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              if (error["show"])
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.all(16.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.redAccent.shade200,
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Text(error["description"],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontFamily: 'abel')),
                                ),
                              Text("NEW PIN", style: style),
                              Pin(
                                  length: 6,
                                  key: key2,
                                  onComplete: (val) {
                                    setState(() => pin1 = val);
                                  }),
                              const SizedBox(height: 25),
                              Text("CONFIRMATION PIN", style: style),
                              Pin(
                                  length: 6,
                                  key: key3,
                                  autoFocus: false,
                                  onComplete: (val) {
                                    setState(() => pin2 = val);
                                    checkIfError();
                                  }),
                              const SizedBox(height: 25),
                              Button(
                                  label: "UPDATE",
                                  textColor: Colors.black,
                                  height: 70,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  onPress: error["show"] ||
                                          pin1 == null ||
                                          pin2 == null
                                      ? null
                                      : () {})
                            ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isValidating
                                ? Row(
                                    children: [
                                      Text("Validating...", style: style),
                                      const SizedBox(width: 10),
                                      const SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ))
                                    ],
                                  )
                                : Text("Enter OLD PIN", style: style),
                            Pin(
                                length: 6,
                                key: key,
                                onComplete: (val) {
                                  setState(() => isValidating = true);

                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    setState(() => _isOn = true);
                                  });
                                }),
                          ],
                        ),
                ))));
  }
}
