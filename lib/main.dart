import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/observer.dart';
import 'package:velayo_flutterapp/widgets/initialize.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(const MainApp()),
    blocObserver: MyBlocObserver(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: InitializeScreen(),
        ),
      ),
    );
  }
}
