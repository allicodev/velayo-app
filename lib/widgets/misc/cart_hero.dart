import 'package:flutter/material.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';

class CartHero extends StatelessWidget {
  CartHero({Key? key, required this.item, required this.remove})
      : super(key: key);

  MiscItem item;
  Function remove;

  @override
  Widget build(BuildContext context) {
    double calculateTotal() => item.price * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 40.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 200,
              child: Stack(children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.18,
                    child: Tooltip(
                      message: "",
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'abel'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Text(
                          "$PESO${item.price} x ${item.quantity} = $PESO${calculateTotal()}",
                          style: const TextStyle(fontSize: 16.0)),
                    )),
                Positioned(
                    child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                      color: ACCENT_PRIMARY,
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Text("Qty: ${item.quantity}",
                      style: const TextStyle(color: Colors.white)),
                )),
                Positioned(
                    top: 0,
                    right: 0,
                    child: Button(
                        label: "Remove",
                        width: 100,
                        borderColor: Colors.transparent,
                        textColor: Colors.red.shade400,
                        onPress: remove)),
                Center(
                  child: Text(
                    "Image is here",
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
