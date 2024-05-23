import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velayo_flutterapp/screens/bills.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class ShopeeCollectScreen extends StatefulWidget {
  const ShopeeCollectScreen({super.key});

  @override
  State<ShopeeCollectScreen> createState() => _ShopeeCollectScreenState();
}

class _ShopeeCollectScreenState extends State<ShopeeCollectScreen> {
  final formKey = GlobalKey<FormState>();
  String type = "regular";
  int numOfParcel = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 15),
      child: Center(
        child: SizedBox(
          width: 700,
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        // onChanged: (val) => setState(() => searchedBiller = val),
                        style: const TextStyle(fontSize: 21),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                        decoration: textFieldStyle(
                            label: "Name",
                            labelStyle: const TextStyle(fontSize: 25),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 210,
                            margin: const EdgeInsets.only(right: 10),
                            child: TextFormField(
                              onChanged: (val) => setState(() =>
                                  numOfParcel = val == "" ? 0 : int.parse(val)),
                              inputFormatters: [
                                FilteringTextInputFormatter(RegExp("[0-9]"),
                                    allow: true),
                                TextInputFormatter.withFunction(
                                    (TextEditingValue oldValue,
                                        TextEditingValue newValue) {
                                  final newValueText = newValue.text;
                                  if (newValueText.length > 1 &&
                                      newValueText[0].trim() == '0') {
                                    newValue = FilteringTextInputFormatter.deny(
                                      RegExp(r'^0+'),
                                    ).formatEditUpdate(oldValue, newValue);
                                    if (newValue.text.isEmpty) {
                                      return oldValue;
                                    }
                                  }
                                  if (newValueText.isNotEmpty) {
                                    return int.tryParse(newValueText) != null
                                        ? newValue
                                        : oldValue;
                                  }
                                  return newValue;
                                })
                              ],
                              style: const TextStyle(fontSize: 21),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Number of Parcel is required";
                                }
                                return null;
                              },
                              decoration: textFieldStyle(
                                  label: "Number of Parcel",
                                  labelStyle: const TextStyle(fontSize: 18),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  backgroundColor:
                                      ACCENT_PRIMARY.withOpacity(.03)),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              // onChanged: (val) => setState(() => searchedBiller = val),
                              inputFormatters: [DecimalFormatter()],
                              style: const TextStyle(fontSize: 21),
                              decoration: textFieldStyle(
                                  label: "Amount",
                                  prefix: PESO,
                                  labelStyle: const TextStyle(fontSize: 21),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  backgroundColor:
                                      ACCENT_PRIMARY.withOpacity(.03)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (numOfParcel != 0)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.57,
                        width: 150,
                        child: ListView(
                            children: List.generate(
                                numOfParcel,
                                (index) => Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        // onChanged: (val) => setState(() => searchedBiller = val),
                                        maxLength: 6,
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return "Pin #${index + 1} is required";
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 25, letterSpacing: 5),
                                        decoration: textFieldStyle(
                                          label: "Collection Pin #${index + 1}",
                                          labelStyle:
                                              const TextStyle(fontSize: 15),
                                          counterText: "",
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 20),
                                          backgroundColor:
                                              ACCENT_PRIMARY.withOpacity(.03),
                                        ),
                                      ),
                                    ))),
                      )
                  ],
                ),
              ),
              Button(
                  label: "SUBMIT",
                  padding: const EdgeInsets.all(20),
                  backgroundColor: ACCENT_SECONDARY,
                  fontSize: 25,
                  margin: const EdgeInsets.only(top: 10.0),
                  onPress: () {
                    if (formKey.currentState!.validate()) {}
                  })
            ],
          ),
        ),
      ),
    );
  }
}
