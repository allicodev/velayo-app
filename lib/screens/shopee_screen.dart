import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class ShopeeCollectScreen extends StatefulWidget {
  const ShopeeCollectScreen({super.key});

  @override
  State<ShopeeCollectScreen> createState() => _ShopeeCollectScreenState();
}

class _ShopeeCollectScreenState extends State<ShopeeCollectScreen> {
  final formKey = GlobalKey<FormState>();
  int numOfParcel = 0;
  Map<String, dynamic> data = {};
  String branchId = "";

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    final appBloc = BlocProvider.of<AppBloc>(context);

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((b) {
        // ! check this, does getting branch necessary here ?
        // BlocProvider.of<BranchBloc>(context).add(GetBranches(onDone: () {
        if (b != "") {
          branchId = b;
          setState(() {});
        }
        // }));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final utilBloc = context.watch<UtilBloc>();
    final appBloc = context.watch<AppBloc>();

    handleRequest() {
      Future.delayed(const Duration(milliseconds: 100));

      int lastQueue = utilBloc.state.lastQueue + 1;

      Map<String, dynamic> request = {
        "branchId": branchId,
        "billingType": "shopee",
        "queue": lastQueue,
        "extra": data
      };

      BlocProvider.of<UtilBloc>(context).add(NewQueue(
          request: request,
          branchId: branchId,
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
    }

    Widget showParcelForms(int num) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.57,
          width: 150,
          child: ListView(
              children: List.generate(
                  num,
                  (index) => Container(
                        margin: const EdgeInsets.only(top: 15),
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) =>
                              setState(() => data["pins"][index] = val),
                          maxLength: 6,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Pin #${index + 1} is required";
                            }
                            if (val.length < 6) {
                              return "Invalid Pin";
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 21, letterSpacing: 5),
                          decoration: textFieldStyle(
                            label: "Collection Pin #${index + 1}",
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: const TextStyle(fontSize: 15),
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            backgroundColor: ACCENT_PRIMARY.withOpacity(.03),
                          ),
                        ),
                      ))),
        );

    Widget showSubmitBtn() => Positioned(
        bottom: 0,
        right: 0,
        child: Button(
            label: appBloc.state.isBTConnected
                ? "SUBMIT"
                : "PRINTER NOT CONNECTED",
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            backgroundColor: ACCENT_SECONDARY,
            borderColor: Colors.transparent,
            fontSize: 21,
            margin: const EdgeInsets.only(top: 10.0),
            onPress: appBloc.state.isBTConnected
                ? () {
                    if (formKey.currentState!.validate()) {
                      handleRequest();
                    }
                  }
                : null));

    return false
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.75,
            child: const Center(
              child: Text(
                "Not Available for a moment",
                style: TextStyle(color: Colors.black45, fontSize: 28.0),
              ),
            ),
          )
        : Expanded(
            child: Stack(
              children: [
                Center(
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
                                  onChanged: (val) =>
                                      setState(() => data["name"] = val),
                                  style: const TextStyle(fontSize: 21),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Name is required";
                                    }
                                    return null;
                                  },
                                  decoration: textFieldStyle(
                                      label: "Name",
                                      labelStyle: const TextStyle(fontSize: 21),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                      backgroundColor:
                                          ACCENT_PRIMARY.withOpacity(.03)),
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
                                        onChanged: (val) {
                                          numOfParcel =
                                              val == "" ? 0 : int.parse(val);
                                          data["pins"] =
                                              List.filled(int.parse(val), "");
                                          setState(() {});
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter(
                                              RegExp("[0-9]"),
                                              allow: true),
                                          TextInputFormatter.withFunction(
                                              (TextEditingValue oldValue,
                                                  TextEditingValue newValue) {
                                            final newValueText = newValue.text;
                                            if (newValueText.length > 1 &&
                                                newValueText[0].trim() == '0') {
                                              newValue =
                                                  FilteringTextInputFormatter
                                                      .deny(
                                                RegExp(r'^0+'),
                                              ).formatEditUpdate(
                                                      oldValue, newValue);
                                              if (newValue.text.isEmpty) {
                                                return oldValue;
                                              }
                                            }
                                            if (newValueText.isNotEmpty) {
                                              return int.tryParse(
                                                          newValueText) !=
                                                      null
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
                                            labelStyle:
                                                const TextStyle(fontSize: 21),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                            backgroundColor: ACCENT_PRIMARY
                                                .withOpacity(.03)),
                                      ),
                                    ),
                                    // SizedBox(
                                    //   width: 300,
                                    //   child: TextFormField(
                                    //     // onChanged: (val) => setState(() => searchedBiller = val),
                                    //     inputFormatters: [DecimalFormatter()],
                                    //     style: const TextStyle(fontSize: 21),
                                    //     decoration: textFieldStyle(
                                    //         label: "Amount",
                                    //         prefix: PESO,
                                    //         labelStyle:
                                    //             const TextStyle(fontSize: 21),
                                    //         contentPadding:
                                    //             const EdgeInsets.symmetric(
                                    //                 horizontal: 10, vertical: 20),
                                    //         backgroundColor:
                                    //             ACCENT_PRIMARY.withOpacity(.03)),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              if (numOfParcel != 0) showParcelForms(numOfParcel)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                showSubmitBtn()
              ],
            ),
          );
  }
}
