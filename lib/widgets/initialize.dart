import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velayo_flutterapp/widgets/hero/failed_hero.dart';
import 'package:velayo_flutterapp/widgets/icon_loaders.dart';
import 'package:velayo_flutterapp/widgets/icon_text.dart';

// TODO: check also if there is a printer connected via bluetooth/network/myheart

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({super.key});

  @override
  State<InitializeScreen> createState() => _InitializeState();
}

class _InitializeState extends State<InitializeScreen> {
  var initialState = "loading";
  late StreamSubscription<ConnectivityResult> subscription;
  var lastResult;

  @override
  void initState() {
    super.initState();

    subscription =
        Connectivity().onConnectivityChanged.listen((_) => checkConnectivity());
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    setState(() => initialState = "loading");

    await Future.delayed(const Duration(milliseconds: 500));
    var connectivityResult = await Connectivity().checkConnectivity();

    if (lastResult != connectivityResult) {
      setState(() => lastResult = connectivityResult);

      if ([
        ConnectivityResult.mobile,
        ConnectivityResult.wifi,
        ConnectivityResult.none
      ].contains(connectivityResult)) {
        setState(() => initialState = 'online');

        if (mounted) {
          Navigator.pushNamed(context, "/home");
        }
      } else {
        setState(() => initialState = "offline");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (["loading", "offline"].contains(initialState)) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light),
        ),
        body: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: initialState == "loading"
                  ? [
                      const SizedBox(height: 10),
                      showGridLoader(),
                      const SizedBox(height: 10),
                      const Text("Checking Network. Please Wait")
                    ]
                  : [HeroFailed(onRetry: () => checkConnectivity())],
            )),
            IconText(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 15),
                mainAxisAlignment: MainAxisAlignment.center,
                color: Colors.grey,
                fontFamily: 'Abel',
                size: 18.0,
                label: "VELAYO Customer Queue App")
          ],
        ),
      );
    }

    return Container();
  }
}
