import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/icon_button.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  Widget showHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Total of 2 Item(s)",
            style: TextStyle(fontFamily: 'abel', fontSize: 24)),
        Button(
          label: "CLEAR",
          icon: Icons.close,
          borderColor: Colors.transparent,
          backgroundColor: Colors.red,
          onPress: () {},
        )
      ]),
    );
  }

  Widget showCardListCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.black12)),
            height: 120,
            child: Stack(children: [
              Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(100.0)),
                      child: MiscIconButton(
                          icon: const Icon(Icons.delete,
                              size: 18.0, color: Colors.white),
                          shape: MiscIconButtonType.circle,
                          borderWidth: 0,
                          onPress: () {}))),
              Positioned(
                left: 0,
                bottom: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.18,
                  child: const Tooltip(
                    message: "",
                    child: Text(
                      "This is a veru long text just to test if ellipses is working with flutter",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'abel'),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Image is here",
                  style: TextStyle(color: Colors.grey.shade300),
                ),
              )
            ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0)),
              child: const Text("${PESO}4.00 x 12 = ${PESO}48.00",
                  style: TextStyle(fontSize: 16.0)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        children: [
          showHeader(),
          const Divider(),

          // generate a list of cart(s) added
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: ListView(
              children: List.generate(100, (index) => showCardListCard()),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TOTAL:",
                      style: TextStyle(fontSize: 32.0, fontFamily: 'abel')),
                  Text("${PESO}12,023",
                      style: TextStyle(fontSize: 32.0, fontFamily: 'abel')),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
