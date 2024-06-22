import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/screens/admin_screen.dart';
import 'package:velayo_flutterapp/screens/home_screen.dart';
import 'package:velayo_flutterapp/screens/misc_payment.dart';
import 'package:velayo_flutterapp/screens/request_success_screen.dart';
import 'package:velayo_flutterapp/widgets/initialize.dart';

Map<String, Widget Function(BuildContext)> routeGenerator = {
  '/': (context) => const InitializeScreen(),
  '/home': (context) => const HomeScreen(),
  '/admin': (context) => const AdminScreen(),
  '/misc-payment': (context) => const MiscPayment(),
  '/request-success': (context) => const RequestSuccessScreen()
};
