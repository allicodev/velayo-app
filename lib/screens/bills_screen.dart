import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart' as _;
import 'package:velayo_flutterapp/repository/models/bills_model.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/screens/error_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/checkbox.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  Map<String, dynamic> inputData = {};
  Map<String, dynamic> onlinePaymentInput = {
    "portal": "",
    "receiverName": "",
    "recieverNum": ""
  };

  String searchedBiller = "";
  String selectedBiller = "";
  double amount = 0;
  bool _isHovered = false;

  bool isOnlinePay = false;

  updateInputDate(String key, dynamic value) {
    setState(() => inputData[key.toLowerCase().split(" ").join(("_"))] = value);
  }

  double getFee() {
    Bill selectedBill = BlocProvider.of<BillsBloc>(context)
        .state
        .bills
        .firstWhere((e) => e.id == selectedBiller);
    if (selectedBiller != "") {
      if (amount / selectedBill.threshold > 0) {
        int multiplier = (amount / selectedBill.threshold).floor();
        return selectedBill.fee + selectedBill.additionalFee * multiplier;
      } else {
        return selectedBill.fee;
      }
    } else {
      return 0;
    }
  }

  handleRequest() async {
    Bill selectedBill = BlocProvider.of<BillsBloc>(context)
        .state
        .bills
        .firstWhere((e) => e.id == selectedBiller);
    Branch? currentBranch =
        BlocProvider.of<AppBloc>(context).state.selectedBranch;
    int lastQueue = BlocProvider.of<UtilBloc>(context).state.lastQueue;

    inputData["fee"] = "${getFee()}_money";
    RequestTransaction tran = RequestTransaction(
        type: "bills",
        sub_type: selectedBill.name,
        transactionDetails: jsonEncode(inputData),
        fee: getFee(),
        amount: amount,
        branchId: currentBranch?.id ?? "",
        billerId: selectedBill.id ?? "",
        isOnlinePayment: isOnlinePay,
        queue: lastQueue + 1);

    if (isOnlinePay) {
      tran.portal = onlinePaymentInput["portal"];
      tran.receiverName = onlinePaymentInput["receiverName"];
      tran.recieverNum = onlinePaymentInput["recieverNum"];
    }

    BlocProvider.of<BillsBloc>(context).add(ReqTransaction(
        requestTransaction: tran,
        onDone: (data) {
          Map<String, dynamic> request = {
            "transactionId": data["_id"],
            "branchId": data["branchId"],
            "billingType": "bills",
            "queue": data["queue"]
          };

          BlocProvider.of<UtilBloc>(context).add(NewQueue(
              request: request,
              branchId: data["branchId"],
              callback: (resp) {}));
        }));
  }

  @override
  Widget build(BuildContext context) {
    final billBloc = context.read<BillsBloc>();
    final appBloc = context.read<AppBloc>();
    final utilBloc = context.watch<UtilBloc>();

    Widget onlinePaymentForm() {
      return Form(
        key: formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["portal"] = val),
              style: const TextStyle(fontSize: 21),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Portal is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label: "Portal (Payment Wallet Used)",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelStyle: const TextStyle(fontSize: 21.0),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["receiverName"] = val),
              style: const TextStyle(fontSize: 21),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Sender Name is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label:
                      "Sender Name (Payees name of payment wallet being sent)",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelStyle: const TextStyle(fontSize: 21.0),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["recieverNum"] = val),
              style: const TextStyle(fontSize: 21),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Sender Number is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label: "Sender Number/Account Number",
                  labelStyle: const TextStyle(fontSize: 21.0),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            )
          ],
        ),
      );
    }

    Widget showBillsList(List<_.Bill> bills) {
      var _bills = [...bills];

      if (searchedBiller != "") {
        _bills.removeWhere((e) =>
            !e.name.toLowerCase().contains(searchedBiller.toLowerCase()));
      } else {
        _bills = bills;
      }

      return Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SELECT BILLER",
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
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
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1 / 1,
                      crossAxisCount: 4,
                    ),
                    itemCount: _bills.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => setState(
                                () => selectedBiller = _bills[index].id ?? ""),
                            hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 100,
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
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget showSelectedBiller(List<_.Bill> bills) {
      Bill selectedBill = bills.firstWhere((e) => e.id == selectedBiller);
      List<_.FormField>? formFields = selectedBill.formField;

      Widget generateForm(_.FormField f) {
        switch (f.type) {
          case "input":
            return Stack(
              children: [
                TextFormField(
                  onChanged: (val) => updateInputDate(f.name, val),
                  maxLength: f.inputOption?.maxLength,
                  style: const TextStyle(fontSize: 21),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "${f.name} is required";
                    }

                    if (f.inputOption?.minLength != null &&
                        val.length < f.inputOption!.minLength!) {
                      return "${f.name} has a minimum length of ${f.inputOption!.minLength}";
                    }

                    return null;
                  },
                  decoration: textFieldStyle(
                      label: f.name,
                      labelStyle: const TextStyle(fontSize: 21.0),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                ),
              ],
            );
          case "number":
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  onChanged: (val) {
                    if (val != "") {
                      updateInputDate(
                          f.name,
                          (f.inputNumberOption?.isMoney ?? false) ||
                                  (f.inputNumberOption!.mainAmount ?? false)
                              ? "${int.parse(val.split(",").join())}_money"
                              : int.parse(val.split(",").join()).toString());
                      if (f.inputNumberOption?.mainAmount ?? false) {
                        setState(
                            () => amount = double.parse(val.split(",").join()));
                      }
                    } else {
                      setState(() => amount = 0);
                    }
                  },
                  inputFormatters: [
                    if (f.inputNumberOption?.isMoney ?? false)
                      DecimalFormatter()
                    else
                      FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: f.inputOption?.maxLength,
                  style: TextStyle(
                      fontSize:
                          f.inputNumberOption?.isMoney ?? false ? 21 : null),
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
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    backgroundColor: ACCENT_PRIMARY.withOpacity(.03),
                  ),
                ),
                if (f.inputNumberOption?.mainAmount ?? false)
                  Text(
                      "+$PESO${NumberFormat('#,###').format(getFee()).toString()} (fee)",
                      style: const TextStyle(fontSize: 18.0))
              ],
            );
          case "textarea":
            return TextFormField(
              onChanged: (val) => updateInputDate(f.name, val),
              minLines: f.textareaOption?.minRow ?? 1,
              maxLines: f.textareaOption?.maxRow ?? 9999,
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
            return CheckBox(
              title: f.name,
              onChanged: (val) => updateInputDate(f.name, val),
            );
          case "select":
            return DropDownTextField(
                clearOption: true,
                clearIconProperty: IconProperty(color: ACCENT_SECONDARY),
                textFieldDecoration: textFieldStyle(
                    label: f.name,
                    labelStyle: const TextStyle(fontSize: 21.0),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                onChanged: (val) =>
                    updateInputDate(f.name, (val as DropDownValueModel).value));
          default:
            return Container();
        }
      }

      return Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.78,
          margin: const EdgeInsets.only(top: 15),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (formFields != null && formFields.isNotEmpty)
                        Center(
                          child: SizedBox(
                            width: 700,
                            child: Column(
                              children: [
                                Text(
                                  selectedBill.name,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                Form(
                                    key: formKey,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...List.generate(
                                                formFields.length,
                                                (index) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: generateForm(
                                                        formFields[index]))),
                                            const SizedBox(height: 10.0),
                                            CheckBox(
                                                title: "Pay Online",
                                                onChanged: (val) => setState(
                                                    () => isOnlinePay = val)),
                                            if (isOnlinePay) ...[
                                              const SizedBox(height: 15.0),
                                              onlinePaymentForm()
                                            ],
                                            const SizedBox(height: 10.0),
                                            const Divider(),
                                            const SizedBox(height: 20.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Text("TOTAL",
                                                    style: TextStyle(
                                                        fontSize: 18.0)),
                                                const SizedBox(width: 10.0),
                                                const Text("•",
                                                    style: TextStyle(
                                                        fontSize: 18.0)),
                                                const SizedBox(width: 10.0),
                                                Text(
                                                    "$PESO${NumberFormat('#,###').format(amount + getFee())}",
                                                    style: const TextStyle(
                                                        fontSize: 18.0))
                                              ],
                                            )
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                              "There are no Field Forms added on this Biller"),
                        )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                child: Button(
                  label: "BACK",
                  fontSize: 21.0,
                  textColor: Colors.black87,
                  backgroundColor: Colors.white,
                  borderColor: Colors.black45,
                  icon: Icons.chevron_left_rounded,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  onPress: () => setState(() {
                    selectedBiller = "";
                    amount = 0;
                  }),
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Button(
                      isLoading: billBloc.state.requestStatus.isLoading,
                      label: "REQUEST",
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      backgroundColor: ACCENT_SECONDARY,
                      borderColor: Colors.transparent,
                      fontSize: 21.0,
                      onPress: () {
                        if (formKey.currentState!.validate()) {
                          if (isOnlinePay &&
                              formKey2.currentState!.validate()) {}
                          handleRequest();
                        }
                      })),
            ],
          ),
        ),
      );
    }

    return BlocListener<BillsBloc, BillState>(
      listener: (context, state) async {
        if (state.requestStatus.isError) {
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: "Server if offline",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 1));
        }

        if (state.requestStatus.isSuccess) {
          await Printer.printQueue(utilBloc.state.lastQueue).then((e) {
            if (e) {
              Navigator.pushNamed(context, '/request-success');
            }
          });
        }
      },
      child: appBloc.state.selectedBranch == null
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.75,
              child: const Center(
                child: Text(
                  "No Branch Selected",
                  style: TextStyle(color: Colors.black45, fontSize: 28.0),
                ),
              ),
            )
          : BlocBuilder<BillsBloc, BillState>(builder: (context, state) {
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
            }),
    );
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
