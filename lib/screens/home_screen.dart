import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/screens/load_screen.dart';
import 'package:velayo_flutterapp/screens/misc_screen.dart';
import 'package:velayo_flutterapp/screens/shopee_screen.dart';
import 'package:velayo_flutterapp/screens/wallet_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/home_button.dart';
import 'package:velayo_flutterapp/widgets/misc/cart_drawer.dart';
import 'package:velayo_flutterapp/widgets/pin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  String selectedTransaction = "";
  bool isValidating = false;

  @override
  void initState() {
    final branchBloc = BlocProvider.of<BranchBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((b) {
        if (b != "" && branchBloc.state.branches.isEmpty) {
          branchBloc.add(GetBranches());
        }
      });
    });
    super.initState();
  }

  Widget showNoOfferSelected() {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/image-home1.png'),
            height: 300,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 15.0),
          Text(
            "Welcome to Velayo Customer Queue App",
            style: TextStyle(
                fontSize: 48, fontFamily: 'abel', fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 15.0),
          Text(
            "Please select an offer to the left side to continue",
            style: TextStyle(fontSize: 24, fontFamily: 'abel'),
          )
        ],
      ),
    );
  }

  Widget showSelectedOffer() {
    return Container(
        margin: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(25.0),
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                  color: ACCENT_SECONDARY,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                selectedTransaction.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 36.0),
              )),
          if (selectedTransaction == "miscellaneous")
            MiscScreen(scaffoldKey: globalKey),
          if (selectedTransaction == "bills payment") const Bills(),
          if (selectedTransaction == "e-money") const Wallets(),
          if (selectedTransaction == "load") const LoadScreen(),
          if (selectedTransaction == "shopee collect")
            const ShopeeCollectScreen()
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        endDrawer: const CartDrawer(),
        key: globalKey,
        body: Row(
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
                  mainAxisSpacing: 20,
                  childAspectRatio: 16 / 9,
                  crossAxisCount: 1,
                ),
                itemCount: home_offers.length,
                itemBuilder: (context, index) => HomeButton(
                  value: home_offers[index],
                  isSelected: home_offers[index].title.toLowerCase() ==
                      selectedTransaction,
                  onClick: () {
                    if (home_offers[index].title.toLowerCase() ==
                        "admin area") {
                      showDialog(
                          context: context,
                          barrierDismissible: !isValidating,
                          builder: (BuildContext context) =>
                              StatefulBuilder(builder: (context, setState) {
                                return Dialog(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    child: Container(
                                        padding: const EdgeInsets.all(16.0),
                                        width: 500,
                                        height: 400,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: const Text(
                                                          "Validating....")),
                                                  const SizedBox(width: 15.0),
                                                  const SizedBox(
                                                    width: 25,
                                                    height: 25,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              const Text(
                                                "Please enter a pin code to access this area",
                                                style: TextStyle(
                                                    fontFamily: "abel",
                                                    fontSize: 22.0),
                                              ),
                                            const SizedBox(height: 16.0),
                                            Pin(
                                              length: 6,
                                              disabled: isValidating,
                                              onComplete: (pin) {
                                                setState(() {
                                                  isValidating = true;
                                                });

                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 500), () {
                                                  setState(() {
                                                    isValidating = false;
                                                  });
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, "/admin");
                                                });
                                              },
                                            ),
                                          ],
                                        )));
                              }));
                    } else {
                      setState(() => selectedTransaction =
                          home_offers[index].title.toLowerCase());
                    }
                  },
                ),
              ),
            ),
            if (selectedTransaction != "")
              showSelectedOffer()
            else
              showNoOfferSelected(),
          ],
        ));
  }
}
