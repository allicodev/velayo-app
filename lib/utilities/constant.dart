import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/repository/models/env/env.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';

const ACCENT_PRIMARY = Color(0xff56B3FA);
const ACCENT_SECONDARY = Color.fromARGB(255, 44, 125, 179);

const String IS_PODUCTION = "dev"; // dev | prod

getBaseUrl() {
  return "https://4070-112-198-98-39.ngrok-free.app";
  if (IS_PODUCTION == "prod") return "https://velayo-eservice.vercel.app";
  if (IS_PODUCTION == "dev") return Env.LocalUrl;
}

String BASE_URL = getBaseUrl();

List<HomeButtonValues> home_offers = [
  HomeButtonValues(title: "Miscellaneous", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "Bills Payment", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "E-Money", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "LOAD", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "Shopee Collect", icon: Icons.miscellaneous_services),
];

List<String> admin_home = ['Select/Switch Branch', "Update PIN"];
const LOAD_PORTALS = ["TM", "GLOBE", "SMART", "TNT", "DITO", "GOMO"];

const PESO = "₱";
