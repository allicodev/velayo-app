import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/screens/bills.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';
import 'package:velayo_flutterapp/widgets/radiogroup.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  final formKey = GlobalKey<FormState>();
  String type = "regular";

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: DropDownTextField(
                          clearOption: true,
                          clearIconProperty:
                              IconProperty(color: ACCENT_SECONDARY),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Provider is required";
                            }
                            return null;
                          },
                          listTextStyle: const TextStyle(fontSize: 21),
                          textFieldDecoration: textFieldStyle(
                              label: "Provider",
                              labelStyle: const TextStyle(fontSize: 25),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                          dropdownRadius: 5,
                          dropDownList: LOAD_PORTALS.map((e) {
                            return DropDownValueModel(
                              value: e.toLowerCase(),
                              name: e,
                            );
                          }).toList(),
                          onChanged: (val) {}),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          // onChanged: (val) => setState(() => searchedBiller = val),
                          maxLength: 10,
                          style: const TextStyle(fontSize: 21),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Phone Number is required";
                            }

                            if (!val.startsWith("9")) {
                              return "Phone number should start with 9";
                            }
                            return null;
                          },
                          decoration: textFieldStyle(
                              label: "Phone Number",
                              prefix: "+63",
                              labelStyle: const TextStyle(fontSize: 21),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                        )),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          // onChanged: (val) => setState(() => searchedBiller = val),
                          inputFormatters: [DecimalFormatter()],
                          style: const TextStyle(fontSize: 21),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Amount is required";
                            }
                            return null;
                          },
                          decoration: textFieldStyle(
                              label: "Amount",
                              prefix: PESO,
                              labelStyle: const TextStyle(fontSize: 21),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                        )),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: RadioGroup(
                        currentValue: type,
                        choices: const ["Regular", "Promo"],
                        onChange: (e) => setState(() => type = e),
                      ),
                    ),
                    if (type == "promo")
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          // onChanged: (val) => setState(() => searchedBiller = val),
                          style: const TextStyle(fontSize: 21),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Promo is required";
                            }
                            return null;
                          },
                          decoration: textFieldStyle(
                              label: "Promo",
                              labelStyle: const TextStyle(fontSize: 25),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                        ),
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
