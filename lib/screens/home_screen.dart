import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/screens/load_screen.dart';
import 'package:velayo_flutterapp/screens/misc_screen.dart';
import 'package:velayo_flutterapp/screens/shopee_screen.dart';
import 'package:velayo_flutterapp/screens/wallet_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/printer.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/utilities/utils_buttons.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/home_button.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  late final AnimationController animationController;
  double _scaleTransformValue = 1;
  String selectedTransaction = "";
  String branchId = "";
  bool isValidating = false;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  void initState() {
    final appBloc = BlocProvider.of<AppBloc>(context);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((b) {
        BlocProvider.of<BranchBloc>(context).add(GetBranches(onDone: () {
          if (b != "") {
            branchId = b;
            appBloc.add(SetSelectedBranch(
                branch: BlocProvider.of<BranchBloc>(context)
                    .state
                    .branches
                    .firstWhere((e) => e.id == b)));
            BlocProvider.of<UtilBloc>(context).add(GetLastQueue(branchId: b));

            setState(() {});
          }
        }));
      });
    });

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
          appBloc.add(UpdateBluetooth(isConnected: true));
          showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Bluetooth is turned on",
              ),
              snackBarPosition: SnackBarPosition.bottom,
              animationDuration: const Duration(milliseconds: 700),
              displayDuration: const Duration(seconds: 1));

          break;
        default:
          return;
      }
    });

    super.initState();
  }

  showAdminPin() {
    showDialog(
        context: context,
        barrierDismissible: !isValidating,
        builder: (BuildContext context) =>
            StatefulBuilder(builder: (context, setState) {
              return Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: BlocBuilder<AppBloc, AppState>(
                    builder: (context, state) {
                      String adminPin = state.settings?.pin ?? "";

                      if (adminPin == "") {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Container(
                          padding: const EdgeInsets.all(16.0),
                          width: 500,
                          height: 400,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Administrative Area",
                                style: TextStyle(
                                    fontFamily: "abel",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32.0),
                              ),
                              const SizedBox(height: 16.0),
                              if (isValidating)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        margin:
                                            const EdgeInsets.only(right: 10.0),
                                        child: const Text("Validating....")),
                                    const SizedBox(width: 15.0),
                                    const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  "Please enter a pin code to access this area",
                                  style: TextStyle(
                                      fontFamily: "abel", fontSize: 22.0),
                                ),
                              const SizedBox(height: 16.0),
                              Pin(
                                length: 6,
                                disabled: isValidating,
                                onComplete: (pin) {
                                  isValidating = true;

                                  if (adminPin == pin) {
                                    isValidating = false;
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, "/admin");
                                  } else {
                                    isValidating = false;
                                    showTopSnackBar(
                                        Overlay.of(context),
                                        const CustomSnackBar.error(
                                          message: "PIN is incorrect",
                                        ),
                                        snackBarPosition:
                                            SnackBarPosition.bottom,
                                        animationDuration:
                                            const Duration(milliseconds: 700),
                                        displayDuration:
                                            const Duration(seconds: 1));
                                  }

                                  setState(() {});
                                },
                              ),
                              Text(
                                  "Current Selected Branch: ${state.selectedBranch != null ? state.selectedBranch!.name : "None"}")
                            ],
                          ));
                    },
                  ));
            }));
  }

  Widget showNoOfferSelected() {
    final utilBloc = context.watch<UtilBloc>();
    final appBloc = context.watch<AppBloc>();

    String getLabel1() => utilBloc.state.status.isLoading
        ? "Printing..."
        : branchId == ""
            ? "No Branch Selected"
            : !appBloc.state.isBTConnected
                ? "No Printer Connected"
                : "PRINT A QUEUE";

    newQueue() {
      int lastQueue = utilBloc.state.lastQueue + 1;

      Map<String, dynamic> request = {
        "branchId": branchId,
        "queue": lastQueue,
      };

      utilBloc.add(NewQueue(
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

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/image-home1.png'),
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 15.0),
          const Text(
            "Welcome to Velayo Customer Queue App",
            style: TextStyle(
                fontSize: 42, fontFamily: 'abel', fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 15.0),
          const Text(
            "Please select an offer list to the left side to continue or just print a queue",
            style: TextStyle(fontSize: 22, fontFamily: 'abel'),
          ),
          const SizedBox(height: 5.0),
          Transform.scale(
              scale: _scaleTransformValue,
              child: Button(
                label: getLabel1(),
                textColor: Colors.black87,
                isLoading: utilBloc.state.status.isLoading,
                width: 200,
                onPress: branchId == "" ||
                        !appBloc.state.isBTConnected ||
                        utilBloc.state.status.isLoading
                    ? null
                    : () async {
                        animationController.forward();
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => animationController.reverse(),
                        );

                        newQueue();
                      },
              ))
        ],
      ),
    );
  }

  Widget showSelectedOffer() {
    return Expanded(
      child: Container(
          margin: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(25.0),
                width: MediaQuery.of(context).size.width * 0.72,
                decoration: BoxDecoration(
                    color: ACCENT_PRIMARY,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  selectedTransaction.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 28.0),
                )),
            if (selectedTransaction == "miscellaneous")
              MiscScreen(scaffoldKey: globalKey),
            if (selectedTransaction == "bills payment") const Bills(),
            if (selectedTransaction == "e-money") const Wallets(),
            if (selectedTransaction == "load") const LoadScreen(),
            if (selectedTransaction == "shopee collect")
              const ShopeeCollectScreen()
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // drawerEnableOpenDragGesture: false,
        resizeToAvoidBottomInset: true,
        // endDrawer: const CartDrawer(),
        key: globalKey,
        body: UtilsButtonOverride(
          callback: () => showAdminPin(),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(18.0),
                width: MediaQuery.of(context).size.width * 0.204,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 5,
                    childAspectRatio: 16 / 9,
                    crossAxisCount: 1,
                  ),
                  itemCount: home_offers.length,
                  itemBuilder: (context, index) => HomeButton(
                    value: home_offers[index],
                    isSelected: home_offers[index].title.toLowerCase() ==
                        selectedTransaction,
                    onClick: () {
                      if (selectedTransaction ==
                          home_offers[index].title.toLowerCase()) {
                        setState(() {
                          selectedTransaction = "";
                        });
                        return;
                      }

                      setState(() {
                        selectedTransaction =
                            home_offers[index].title.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              if (selectedTransaction != "")
                showSelectedOffer()
              else
                showNoOfferSelected(),
            ],
          ),
        ));
  }
}
