import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart' as _;
import 'package:velayo_flutterapp/repository/models/bills_model.dart';
import 'package:velayo_flutterapp/screens/widgets/error_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  final formKey = GlobalKey<FormState>();

  String searchedBiller = "";
  String selectedBiller = "";

  // ! bad code! bad! bad! bad!
  bool checked = false;

  Widget showBillsList(List<_.Bill> bills) {
    var _bills = [...bills];

    if (searchedBiller != "") {
      _bills.removeWhere(
          (e) => !e.name.toLowerCase().contains(searchedBiller.toLowerCase()));
    } else {
      _bills = bills;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SELECT BILLER",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  onChanged: (val) => setState(() => searchedBiller = val),
                  decoration: textFieldStyle(
                      label: "Search Biller",
                      prefixIcon: const Icon(Icons.search),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                ),
              ),
            ],
          ),
          const Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 16 / 9,
              crossAxisCount: 4,
            ),
            itemCount: _bills.length,
            itemBuilder: (context, index) => Column(
              children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () =>
                        setState(() => selectedBiller = _bills[index].id ?? ""),
                    hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Image is here",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _bills[index].name,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showSelectedBiller(List<_.Bill> bills) {
    Bill selectedBill = bills.firstWhere((e) => e.id == selectedBiller);
    List<_.FormField>? formFields = selectedBill.formField;

    // ? "input", "number", "textarea", "checkbox", "select"
    Widget generateForm(_.FormField f) {
      switch (f.type) {
        case "input":
          return TextFormField(
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: const TextStyle(fontSize: 21),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
                label: f.name,
                labelStyle: const TextStyle(fontSize: 25),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
          );
        case "number":
          return TextFormField(
            inputFormatters: [
              if (f.inputNumberOption?.isMoney ?? false)
                DecimalFormatter()
              else
                FilteringTextInputFormatter.digitsOnly
            ],
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: TextStyle(
                fontSize: f.inputNumberOption?.isMoney ?? false ? 25 : null),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
              label: f.name,
              prefix: f.inputNumberOption?.isMoney ?? false ? PESO : null,
              labelStyle: const TextStyle(fontSize: 25),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              backgroundColor: ACCENT_PRIMARY.withOpacity(.03),
            ),
          );
        case "textarea":
          return TextFormField(
            minLines: f.textareaOption?.minRow ?? 1,
            maxLines: f.textareaOption?.maxRow ?? 9999,
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: const TextStyle(fontSize: 21),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
                label: f.name,
                labelStyle: const TextStyle(fontSize: 25),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
          );
        case "checkbox":
          return Row(
            children: [
              Checkbox(
                  value: checked,
                  onChanged: (value) => setState(() => checked = value!)),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(f.name),
              ),
            ],
          );
        case "select":
          return DropDownTextField(
              clearOption: true,
              clearIconProperty: IconProperty(color: ACCENT_SECONDARY),
              textFieldDecoration: textFieldStyle(
                  label: f.name,
                  labelStyle: const TextStyle(fontSize: 25),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
              dropdownRadius: 5,
              dropDownList: f.selectOption!.items!.map((e) {
                return DropDownValueModel(
                  value: e['value'],
                  name: e['name'] ?? "",
                );
              }).toList(),
              validator: (val) {
                if (val!.isEmpty) {
                  return "${f.name} is required";
                }
                return null;
              },
              onChanged: (val) {});
        default:
          return Container();
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Button(
            label: "BACK",
            icon: Icons.chevron_left_rounded,
            textColor: Colors.black45,
            width: 120,
            onPress: () => setState(() => selectedBiller = ""),
          ),
          if (formFields != null && formFields.isNotEmpty)
            Center(
              child: SizedBox(
                width: 700,
                child: Column(
                  children: [
                    Text(
                      selectedBill.name,
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w700),
                    ),
                    Form(
                        key: formKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Column(
                              children: List.generate(
                                  formFields.length,
                                  (index) => Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      child: generateForm(formFields[index]))),
                            ))),
                    Button(
                        label: "SUBMIT",
                        padding: const EdgeInsets.all(20),
                        backgroundColor: ACCENT_SECONDARY,
                        fontSize: 25,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        onPress: () {
                          if (formKey.currentState!.validate()) {}
                        })
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Text("There are no Field Forms added on this Biller"),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillsBloc, BillState>(builder: (context, state) {
      return state.status.isSuccess
          ? selectedBiller != ""
              ? showSelectedBiller(state.bills)
              : showBillsList(state.bills)
          : state.status.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.8,
                  margin: const EdgeInsets.only(top: 15),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : state.status.isError
                  ? const ErrorScreen(title: "Fetching Bills Error")
                  : const SizedBox();
    });
  }
}

class DecimalFormatter extends TextInputFormatter {
  final int decimalDigits;

  DecimalFormatter({this.decimalDigits = 2}) : assert(decimalDigits >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText;

    if (decimalDigits == 0) {
      newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    } else {
      newText = newValue.text.replaceAll(RegExp('[^0-9\.]'), '');
    }

    if (newText.contains('.')) {
      //in case if user's first input is "."
      if (newText.trim() == '.') {
        return newValue.copyWith(
          text: '0.',
          selection: const TextSelection.collapsed(offset: 2),
        );
      }
      //in case if user tries to input multiple "."s or tries to input
      //more than the decimal place
      else if ((newText.split(".").length > 2) ||
          (newText.split(".")[1].length > decimalDigits)) {
        return oldValue;
      } else {
        return newValue;
      }
    }

    //in case if input is empty or zero
    if (newText.trim() == '' || newText.trim() == '0') {
      return newValue.copyWith(text: '');
    } else if (int.parse(newText) < 1) {
      return newValue.copyWith(text: '');
    }

    double newDouble = double.parse(newText);
    var selectionIndexFromTheRight =
        newValue.text.length - newValue.selection.end;

    String newString = NumberFormat("#,##0.##").format(newDouble);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: newString.length - selectionIndexFromTheRight,
      ),
    );
  }
}
