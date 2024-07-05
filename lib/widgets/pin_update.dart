import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class PinUpdate extends StatefulWidget {
  const PinUpdate({super.key});

  @override
  State<PinUpdate> createState() => _PinSlideState();
}

class _PinSlideState extends State<PinUpdate> {
  bool _isOn = false;

  Key key = const ValueKey("key1");
  Key key2 = const ValueKey("key2");
  Key key3 = const ValueKey("key3");

  TextStyle style = const TextStyle(fontFamily: "abel", fontSize: 22);

  String? pin1;
  String? pin2;
  Map<String, dynamic> error = {"show": false, "description": ""};

  bool errorInitial = false;

  @override
  Widget build(BuildContext context) {
    final branchBloc = context.read<BranchBloc>();

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
        child: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
          return BlocListener<AppBloc, AppState>(
              listener: (context, state) async {
                if (state.statusSetting.isSuccess) {
                  showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.success(
                        message: "Successfully Updated",
                      ),
                      snackBarPosition: SnackBarPosition.bottom,
                      animationDuration: const Duration(milliseconds: 700),
                      displayDuration: const Duration(seconds: 1));

                  await getValue('selectedBranch').then((b) {
                    branchBloc.add(GetBranches(onDone: () {
                      if (b != "") {
                        BlocProvider.of<AppBloc>(context).add(SetSelectedBranch(
                            branch: BlocProvider.of<BranchBloc>(context)
                                .state
                                .branches
                                .firstWhere((e) => e.id == b)));
                      }
                    }));
                  });

                  if (mounted) {
                    context
                        .read<AppBloc>()
                        .add(UpdateStatus(status: SettingStatus.initial));
                  }
                }
              },
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
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        padding: const EdgeInsets.all(16.0),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
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
                                            : () {
                                                context.read<AppBloc>().add(
                                                    UpdatePin(
                                                        id: state
                                                            .selectedBranch!
                                                            .id!,
                                                        pin: pin1!));
                                              })
                                  ])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Enter OLD PIN", style: style),
                                      if (errorInitial)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4.0)),
                                          child: const Text(
                                            "Pin is Incorrect",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'abel'),
                                          ),
                                        )
                                    ],
                                  ),
                                  Pin(
                                      length: 6,
                                      key: key,
                                      onChange: (val) {
                                        setState(() => errorInitial = false);
                                      },
                                      onComplete: (val) {
                                        String pin = state.selectedBranch!.pin!;

                                        if (val == pin) {
                                          _isOn = true;
                                        } else {
                                          errorInitial = true;
                                        }

                                        setState(() {});
                                      }),
                                ],
                              ),
                      ))));
        }));
  }
}
