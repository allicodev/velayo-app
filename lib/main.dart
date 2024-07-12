import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/provider/route_generator.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/misc/misc_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/observer.dart';
import 'package:velayo_flutterapp/repository/bloc/util/util_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/wallet/wallet_bloc.dart';
import 'package:velayo_flutterapp/repository/repository.dart';
import 'package:velayo_flutterapp/repository/service/service.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight]);
      return runApp(RepositoryProvider(
          create: (context) => Repository(service: Service()),
          child: MultiBlocProvider(providers: [
            BlocProvider<MiscBloc>(
                create: (context) =>
                    MiscBloc(repo: context.read<Repository>())),
            BlocProvider<AppBloc>(
                create: (context) => AppBloc(repo: context.read<Repository>())
                  ..add(GetSettings())
                  ..add(GetItemCategory())),
            BlocProvider<BillsBloc>(
              create: (context) => BillsBloc(
                repo: context.read<Repository>(),
              )..add(GetBills()),
            ),
            BlocProvider<WalletBloc>(
              create: (context) => WalletBloc(
                repo: context.read<Repository>(),
              )..add(GetWallets()),
            ),
            BlocProvider<BranchBloc>(
                create: (context) => BranchBloc(
                      repo: context.read<Repository>(),
                    )),
            BlocProvider<UtilBloc>(
                create: (context) => UtilBloc(
                      repo: context.read<Repository>(),
                    )),
          ], child: const MainApp())));
    },
    blocObserver: MyBlocObserver(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Velayo Customer Queue App",
      initialRoute: "/",
      routes: routeGenerator,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
