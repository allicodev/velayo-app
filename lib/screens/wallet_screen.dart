import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/wallet/wallet_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/repository/models/wallet_model.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart' as _;
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/screens/error_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/checkbox.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class Wallets extends StatefulWidget {
  const Wallets({Key? key}) : super(key: key);

  @override
  State<Wallets> createState() => _WalletsState();
}

class _WalletsState extends State<Wallets> {
  final formKey = GlobalKey<FormState>();

  String searchedWallet = "";
  String selectedWallet = "";
  String selectedWalletType = "";
  bool includeFee = false;
  double amount = 0;
  Map<String, dynamic> inputData = {};

  updateInputDate(String key, dynamic value) {
    setState(() => inputData[key.toLowerCase().split(" ").join(("_"))] = value);
  }

  int getFee() {
    Wallet sWallet = BlocProvider.of<WalletBloc>(context)
        .state
        .wallets
        .firstWhere((e) => e.id == selectedWallet);

    if (selectedWalletType == "cash-in") {
      return (sWallet.cashinType == "fixed"
              ? sWallet.cashinFeeValue
              : amount * (sWallet.cashinFeeValue / 100))
          .ceil();
    } else {
      return sWallet.cashoutType == "fixed"
          ? sWallet.cashoutFeeValue.toInt()
          : (amount * (sWallet.cashoutFeeValue / 100)).ceil();
    }
  }

  double getTotal() {
    if (selectedWalletType == "cash-out" && includeFee) {
      return amount - getFee() < 0 ? 0 : amount - getFee();
    }
    if (includeFee) {
      return amount;
    } else {
      return amount + getFee();
    }
  }

  handleRequest() async {
    Wallet sWallet = BlocProvider.of<WalletBloc>(context)
        .state
        .wallets
        .firstWhere((e) => e.id == selectedWallet);
    int lastQueue = BlocProvider.of<UtilBloc>(context).state.lastQueue;

    Branch? currentBranch =
        BlocProvider.of<AppBloc>(context).state.selectedBranch;

    inputData["fee"] = "${getFee()}_money";
    RequestTransaction tran = RequestTransaction(
        type: "wallet",
        sub_type: "${sWallet.name} ${selectedWalletType.toUpperCase()}",
        transactionDetails: jsonEncode(inputData),
        fee: getFee().toDouble(),
        amount: amount,
        branchId: currentBranch?.id ?? "",
        walletId: sWallet.id ?? "",
        isOnlinePayment: false,
        queue: lastQueue + 1);

    BlocProvider.of<BillsBloc>(context).add(ReqTransaction(
        requestTransaction: tran,
        onDone: (data) {
          Map<String, dynamic> request = {
            "transactionId": data["_id"],
            "branchId": data["branchId"],
            "billingType": "wallet",
            "queue": data["queue"]
          };

          BlocProvider.of<UtilBloc>(context).add(NewQueue(
              request: request,
              branchId: data["branchId"],
              callback: (resp) async {
                if (resp) {
                  await Printer.printQueue(
                          BlocProvider.of<UtilBloc>(context).state.lastQueue)
                      .then((e) {
                    if (e) {
                      Navigator.pushNamed(context, '/request-success');
                    }
                  });
                }
              }));
        }));
  }

  @override
  Widget build(BuildContext context) {
    final billBloc = context.read<BillsBloc>();
    final appBloc = context.read<AppBloc>();

    Widget showWalletList(List<Wallet> wallets) {
      var _wallets = [...wallets];

      if (searchedWallet != "") {
        _wallets.removeWhere((e) =>
            !e.name.toLowerCase().contains(searchedWallet.toLowerCase()));
      } else {
        _wallets = wallets;
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
                  "SELECT WALLET",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    onChanged: (val) => setState(() => searchedWallet = val),
                    decoration: textFieldStyle(
                        label: "Search Wallet",
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1 / 1,
                    crossAxisCount: 4,
                  ),
                  itemCount: _wallets.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => setState(
                              () => selectedWallet = _wallets[index].id ?? ""),
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
                        _wallets[index].name,
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
      );
    }

    Widget showSelectedWalletType(Wallet _wallet) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.only(top: 30),
        child: Row(children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Material(
              color: (_wallet.cashInFormField?.isNotEmpty ?? false)
                  ? Colors.transparent
                  : Colors.black12,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: (_wallet.cashInFormField?.isNotEmpty ?? false)
                    ? () => setState(() => selectedWalletType = "cash-in")
                    : null,
                hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 70,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "CASH IN ${(_wallet.cashInFormField?.isNotEmpty ?? false) ? "" : "\n(Disabled)"}",
                      style: TextStyle(
                          fontSize:
                              (_wallet.cashInFormField?.isNotEmpty ?? false)
                                  ? 25.0
                                  : 18.0,
                          fontWeight: FontWeight.w500,
                          color: (_wallet.cashInFormField?.isNotEmpty ?? false)
                              ? Colors.black
                              : Colors.black45.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                ? Colors.transparent
                : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                  ? () => setState(() => selectedWalletType = "cash-out")
                  : null,
              hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 70,
                width: 150,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(
                  "CASH OUT ${(_wallet.cashOutFormField?.isNotEmpty ?? false) ? "" : "\n(Disabled)"}",
                  style: TextStyle(
                      fontSize: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                          ? 25.0
                          : 18.0,
                      fontWeight: FontWeight.w500,
                      color: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                          ? Colors.black
                          : Colors.black45.withOpacity(0.5)),
                )),
              ),
            ),
          )
        ]),
      );
    }

    Widget showSelectedWallet(List<Wallet> wallets) {
      Wallet _selectedWallet =
          wallets.firstWhere((e) => e.id == selectedWallet);
      List<_.FormField>? formFields = selectedWalletType == "cash-in"
          ? _selectedWallet.cashInFormField
          : _selectedWallet.cashOutFormField;

      Widget generateForm(_.FormField f) {
        switch (f.type) {
          case "input":
            return TextFormField(
              onChanged: (val) => updateInputDate(f.name, val),
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
                  labelStyle: const TextStyle(fontSize: 21),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            );
          case "number":
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  inputFormatters: [
                    if (f.inputNumberOption?.isMoney ?? false)
                      DecimalFormatter()
                    else
                      FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (val) {
                    if (val != "") {
                      updateInputDate(
                          f.name,
                          (f.inputNumberOption?.isMoney ?? false) ||
                                  (f.inputNumberOption!.mainAmount ?? false)
                              ? "${int.parse(val.split(",").join())}_money"
                              : int.parse(val.split(",").join()).toString());
                      amount = double.parse(val.split(",").join());
                    } else {
                      amount = 0;
                    }

                    setState(() {});
                  },
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
              minLines: f.textareaOption?.minRow ?? 1,
              maxLines: f.textareaOption?.maxRow ?? 9999,
              onChanged: (val) => updateInputDate(f.name, val),
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
                  labelStyle: const TextStyle(fontSize: 21),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                validator: (val) {
                  if (val!.isEmpty) {
                    return "${f.name} is required";
                  }
                  return null;
                },
                textFieldDecoration: textFieldStyle(
                    label: f.name,
                    labelStyle: const TextStyle(fontSize: 21),
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
                      if (formFields != null &&
                          formFields.isNotEmpty &&
                          selectedWalletType != "")
                        Center(
                          child: SizedBox(
                            width: 700,
                            child: Column(
                              children: [
                                Text(
                                  "${_selectedWallet.name.toUpperCase()} ${selectedWalletType.toUpperCase()}",
                                  style: const TextStyle(
                                      fontSize: 36,
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
                                                title: "Include Fee",
                                                onChanged: (val) => setState(
                                                    () => includeFee = val)),
                                            const SizedBox(height: 10.0),
                                            const Divider(),
                                            const SizedBox(height: 10.0),
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
                                                    "$PESO${NumberFormat('#,###').format(getTotal())}",
                                                    style: const TextStyle(
                                                        fontSize: 18.0))
                                              ],
                                            )
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        ),
                      if ((_selectedWallet.cashInFormField?.isEmpty ?? false) &&
                          (_selectedWallet.cashOutFormField?.isEmpty ?? false))
                        const Center(
                          child: Text(
                              "There are no Field Forms added on this Wallet"),
                        )
                      else if (selectedWalletType == "")
                        showSelectedWalletType(_selectedWallet)
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: Button(
                    label: "BACK",
                    fontSize: 21,
                    icon: Icons.chevron_left_rounded,
                    textColor: Colors.black87,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    onPress: () => setState(() {
                      selectedWallet = "";
                      selectedWalletType = "";
                      amount = 0;
                    }),
                  )),
              if (formFields != null &&
                  formFields.isNotEmpty &&
                  selectedWalletType != "")
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Button(
                        label: appBloc.state.isBTConnected
                            ? "REQUEST"
                            : "PRINTER NOT CONNECTED",
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        backgroundColor: ACCENT_SECONDARY,
                        borderColor: Colors.transparent,
                        isLoading: billBloc.state.requestStatus.isLoading,
                        fontSize: 21,
                        onPress: appBloc.state.isBTConnected
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  handleRequest();
                                }
                              }
                            : null)),
            ],
          ),
        ),
      );
    }

    return BlocListener<BillsBloc, BillState>(
      listener: (context, state) {
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
          Navigator.pushNamed(context, '/request-success');
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
          : BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
              return state.status.isSuccess
                  ? selectedWallet != ""
                      ? showSelectedWallet(state.wallets)
                      : showWalletList(state.wallets)
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
                          ? const ErrorScreen(title: "Fetching Wallets Error")
                          : const SizedBox();
            }),
    );
  }
}
