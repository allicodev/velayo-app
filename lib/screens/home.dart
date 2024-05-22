import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/screens/bills.dart';
import 'package:velayo_flutterapp/screens/wallet.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/home_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedTransaction = "";

  @override
  void initState() {
    fetchBills();
    super.initState();
  }

  fetchBills() async {}

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
          if (selectedTransaction == "bills payment") const Bills(),
          if (selectedTransaction == "e-money") const Wallets(),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(18.0),
            width: MediaQuery.of(context).size.width * 0.204,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                onClick: () => setState(() => selectedTransaction =
                    home_offers[index].title.toLowerCase()),
              ),
            ),
          ),
          if (selectedTransaction != "") showSelectedOffer()
        ],
      ),
    );
  }
}
