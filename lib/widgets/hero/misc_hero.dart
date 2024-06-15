import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';
import 'package:velayo_flutterapp/widgets/icon_button.dart';

class MiscHero extends StatefulWidget {
  Function(String, int) onSubmit;
  ItemsWithStock item;
  MiscHero({Key? key, required this.item, required this.onSubmit})
      : super(key: key);

  @override
  State<MiscHero> createState() => _MiscHeroState();
}

class _MiscHeroState extends State<MiscHero> {
  late TextEditingController controller;
  late ItemsWithStock item;
  int inputQuantity = 1;

  @override
  void initState() {
    controller = TextEditingController()..setText(inputQuantity.toString());
    item = widget.item;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: SingleChildScrollView(
                        child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.2,
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.itemId.name,
                              style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'abel')),
                          const SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 180,
                                child: TextFormField(
                                  onChanged: (val) => setState(
                                      () => inputQuantity = int.parse(val)),
                                  textAlign: TextAlign.center,
                                  controller: controller,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: textFieldStyle(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      backgroundColor:
                                          ACCENT_PRIMARY.withOpacity(.03)),
                                ),
                              ),
                              const SizedBox(width: 5),
                              MiscIconButton(
                                  icon: const Icon(Icons.add,
                                      size: 22.0, color: Colors.black54),
                                  onPress: () {
                                    controller.setText(
                                        (inputQuantity + 1).toString());
                                    setState(() =>
                                        inputQuantity = inputQuantity + 1);
                                  }),
                              const SizedBox(width: 1),
                              MiscIconButton(
                                  icon: const Icon(Icons.remove,
                                      size: 22.0, color: Colors.black54),
                                  onPress: () {
                                    if (inputQuantity > 1) {
                                      controller.setText(
                                          (inputQuantity - 1).toString());
                                      setState(() =>
                                          inputQuantity = inputQuantity - 1);
                                    }
                                  }),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Button(
                              label: "ADD TO CART",
                              width: 280,
                              textColor: Colors.white,
                              borderColor: ACCENT_PRIMARY,
                              backgroundColor: ACCENT_PRIMARY,
                              onPress: () {})
                        ],
                      ),
                    )),
                  );
                });
              }).then((e) {
            setState(() => inputQuantity = 1);
            controller.setText("1");
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 3.0,
                offset: const Offset(2, 0),
              ),
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 3.0,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  SizedBox(
                      height: 120,
                      child: Center(
                          child: Text(
                        "Image is Here",
                        style: TextStyle(color: Colors.grey.shade300),
                      ))),
                  Container(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Text(item.itemId.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'abel'))),
                ],
              ),
              Positioned(
                  bottom: -30,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.171,
                      decoration: BoxDecoration(
                        color: ACCENT_PRIMARY,
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Available Stock: ${item.stock_count}",
                                style: const TextStyle(color: Colors.white)),
                            Container(
                              decoration: BoxDecoration(
                                  color: ACCENT_SECONDARY.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(100.0)),
                              padding: const EdgeInsets.all(8.0),
                              child: Text("$PESO${item.itemId.price}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white)),
                            )
                          ],
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
