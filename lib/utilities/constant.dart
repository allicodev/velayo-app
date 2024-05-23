import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/repository/models/env/env.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';

const ACCENT_PRIMARY = Color(0xFF98c04b);
const ACCENT_SECONDARY = Color(0xFF294b0f);

const String IS_PODUCTION = "prod"; // dev prod

getBaseUrl() {
  if (IS_PODUCTION == "prod") return "https://velayo-eservice.vercel.app";
  if (IS_PODUCTION == "dev") return Env.LocalUrl;
}

List<HomeButtonValues> home_offers = [
  HomeButtonValues(title: "Miscellaneous", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "Bills Payment", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "E-Money", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "LOAD", icon: Icons.miscellaneous_services),
  HomeButtonValues(title: "Shopee Collect", icon: Icons.miscellaneous_services),
];

String BASE_URL = getBaseUrl();

// ignore: constant_identifier_names
enum TransactionTypes { MISCELLANEOUS, BILLS, EMONEY, LOAD, SHOPEE }

const PESO = "₱";

const LOAD_PORTALS = ["TM", "GLOBE", "SMART", "TNT", "DITO", "GOMO"];
