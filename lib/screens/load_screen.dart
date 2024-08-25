import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/repository/models/settings_model.dart';
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
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
  bool disabled = false;
  String type = "regular";
  String selectedProvider = "";
  String phoneNum = "";
  String promo = "";
  double amount = 0;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();

    final appBloc = BlocProvider.of<AppBloc>(context);
    BlocProvider.of<AppBloc>(context).add(GetSettings());

    // handle bluetooth status change
    bluetooth.onStateChanged().listen((_state) {
      switch (_state) {
        case BlueThermalPrinter.CONNECTED:
          appBloc.add(UpdateBluetooth(isConnected: true));
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Bluetooth Connected",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 1));
          break;
        case BlueThermalPrinter.DISCONNECTED:
        case BlueThermalPrinter.STATE_OFF:
          appBloc.add(UpdateBluetooth(isConnected: false));
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: "Bluetooth is Disconnected",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 1));
          break;
        case BlueThermalPrinter.STATE_ON:
          if (!appBloc.state.isBTConnected) {
            showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.success(
                  message: "Bluetooth is turned on",
                ),
                snackBarPosition: SnackBarPosition.bottom,
                animationDuration: const Duration(milliseconds: 700),
                displayDuration: const Duration(seconds: 1));
            appBloc.add(UpdateBluetooth(isConnected: true));
          }

          break;
        default:
          return;
      }
    });
  }

  bool isDisabled(Settings? settings, String name) {
    if (settings?.disabled_eload != null &&
        (settings?.disabled_eload.isNotEmpty ?? false)) {
      return settings!.disabled_eload
          .where((e) => e.toLowerCase() == name.toLowerCase())
          .isNotEmpty;
    } else {
      return false;
    }
  }

  double getFee() {
    var settings = BlocProvider.of<AppBloc>(context).state.settings;
    if (settings?.additionalFee != null) {
      if (amount / (settings?.threshold ?? 1) > 0) {
        int multiplier = (amount / (settings?.threshold ?? 1)).floor();
        return (settings?.fee ?? 0) +
            (settings?.additionalFee ?? 0) * multiplier;
      } else {
        return settings?.fee ?? 0;
      }
    }
    return 0;
  }

  handleRequest() async {
    Branch? currentBranch =
        BlocProvider.of<AppBloc>(context).state.selectedBranch;
    int lastQueue = BlocProvider.of<UtilBloc>(context).state.lastQueue + 1;

    RequestTransaction tran = RequestTransaction(
        type: "eload",
        sub_type: "$selectedProvider LOAD",
        transactionDetails: jsonEncode(({
          "provider": selectedProvider,
          "phone": phoneNum,
          "amount": amount,
          "type": type,
          "promo": promo,
          "fee": getFee(),
        })),
        fee: getFee(),
        amount: amount,
        branchId: currentBranch?.id ?? "",
        isOnlinePayment: false,
        queue: lastQueue);

    BlocProvider.of<BillsBloc>(context).add(ReqTransaction(
        requestTransaction: tran,
        onDone: (data) {
          Future.delayed(const Duration(milliseconds: 100));

          Map<String, dynamic> request = {
            "transactionId": data["_id"],
            "branchId": data["branchId"],
            "billingType": "eload",
            "queue": lastQueue
          };

          BlocProvider.of<UtilBloc>(context).add(NewQueue(
              request: request,
              branchId: data["branchId"],
              callback: (resp) async {
                if (resp) {
                  await Printer.printQueue(lastQueue).then((e) {
                    if (e is bool && e) {
                      Navigator.pushNamed(context, '/request-success');
                    } else {
                      showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: e,
                          ),
                          snackBarPosition: SnackBarPosition.bottom,
                          animationDuration: const Duration(milliseconds: 700),
                          displayDuration: const Duration(seconds: 1));
                    }
                  });
                }
              }));
        }));
  }

  @override
  Widget build(BuildContext context) {
    final billBloc = context.watch<BillsBloc>();

    return BlocListener<BillsBloc, BillState>(
      listener: (context, state) {
        if (state.requestStatus.isError) {
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.error(
                message: "Server is offline",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 1));
        }
      },
      child: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
        return state.selectedBranch == null
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
            : Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  margin: const EdgeInsets.only(top: 15),
                  child: Center(
                    child: state.statusSetting.isLoading
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10.0),
                              Text("E-Load is fetching...",
                                  style: TextStyle(
                                      fontFamily: 'abel', fontSize: 18.0))
                            ],
                          )
                        : SizedBox(
                            width: 700,
                            child: Column(
                              children: [
                                Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 20),
                                        child: DropDownTextField(
                                            clearOption: true,
                                            clearIconProperty: IconProperty(
                                                color: ACCENT_SECONDARY),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return "Provider is required";
                                              }
                                              return null;
                                            },
                                            listTextStyle:
                                                const TextStyle(fontSize: 21),
                                            textFieldDecoration: textFieldStyle(
                                                label: "Provider",
                                                labelStyle: const TextStyle(
                                                    fontSize: 21),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                backgroundColor: ACCENT_PRIMARY
                                                    .withOpacity(.03)),
                                            dropdownRadius: 5,
                                            dropDownList: LOAD_PORTALS.map((e) {
                                              return DropDownValueModel(
                                                value: e.toLowerCase(),
                                                name:
                                                    "$e ${isDisabled(state.settings, e) ? "(DISABLED)" : ""}",
                                              );
                                            }).toList(),
                                            onChanged: (val) => setState(() =>
                                                selectedProvider =
                                                    (val as DropDownValueModel)
                                                        .value)),
                                      ),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            onChanged: (val) =>
                                                setState(() => phoneNum = val),
                                            maxLength: 10,
                                            style:
                                                const TextStyle(fontSize: 21),
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
                                                labelStyle: const TextStyle(
                                                    fontSize: 21),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                backgroundColor: ACCENT_PRIMARY
                                                    .withOpacity(.03)),
                                          )),
                                      Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: TextFormField(
                                            onChanged: (val) => setState(() =>
                                                amount = double.parse(
                                                    val.split(",").join())),
                                            inputFormatters: [
                                              DecimalFormatter()
                                            ],
                                            style:
                                                const TextStyle(fontSize: 21),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return "Amount is required";
                                              }
                                              return null;
                                            },
                                            decoration: textFieldStyle(
                                                label: "Amount",
                                                prefix: PESO,
                                                labelStyle: const TextStyle(
                                                    fontSize: 21),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                backgroundColor: ACCENT_PRIMARY
                                                    .withOpacity(.03)),
                                          )),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: RadioGroup(
                                          currentValue: type,
                                          choices: const ["Regular", "Promo"],
                                          onChange: (e) =>
                                              setState(() => type = e),
                                        ),
                                      ),
                                      if (type == "promo")
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          child: TextFormField(
                                            onChanged: (val) =>
                                                setState(() => promo = val),
                                            style:
                                                const TextStyle(fontSize: 21),
                                            validator: (val) {
                                              if (val!.isEmpty) {
                                                return "Promo is required";
                                              }
                                              return null;
                                            },
                                            decoration: textFieldStyle(
                                                label: "Promo",
                                                labelStyle: const TextStyle(
                                                    fontSize: 25),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 20),
                                                backgroundColor: ACCENT_PRIMARY
                                                    .withOpacity(.03)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Button(
                                    label: isDisabled(
                                            state.settings, selectedProvider)
                                        ? "Provider is Temporarily Unavailable"
                                        : !state.isBTConnected
                                            ? "PRINTER NOT CONNECTED"
                                            : "SUBMIT",
                                    padding: const EdgeInsets.all(20),
                                    backgroundColor: ACCENT_SECONDARY,
                                    borderColor: Colors.transparent,
                                    isLoading:
                                        billBloc.state.requestStatus.isLoading,
                                    fontSize: 21,
                                    margin: const EdgeInsets.only(top: 10.0),
                                    onPress: isDisabled(state.settings,
                                                selectedProvider) ||
                                            !state.isBTConnected
                                        ? null
                                        : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              handleRequest();
                                            }
                                          })
                              ],
                            ),
                          ),
                  ),
                ),
              );
      }),
    );
  }
}
