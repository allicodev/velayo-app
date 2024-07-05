import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/misc/misc_bloc.dart';
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

class _MiscHeroState extends State<MiscHero>
    with SingleTickerProviderStateMixin {
  late TextEditingController controller;
  late ItemsWithStock item;
  late final AnimationController animationController;

  int inputQuantity = 1;
  double _scaleTransformValue = 1;

  @override
  void initState() {
    controller = TextEditingController()..setText(inputQuantity.toString());
    item = widget.item;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miscBloc = context.watch<MiscBloc>();

    getCurrentItem() {
      try {
        if (miscBloc.state.items == null ||
            (miscBloc.state.items?.isEmpty ?? false)) return null;
        return miscBloc.state.items!.firstWhere((e) => e.id == item.itemId.id);
      } catch (e) {
        return null;
      }
    }

    Widget showCartAdder() {
      return SingleChildScrollView(
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
                    onChanged: (val) =>
                        setState(() => inputQuantity = int.parse(val)),
                    textAlign: TextAlign.center,
                    controller: controller,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: textFieldStyle(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                  ),
                ),
                const SizedBox(width: 5),
                MiscIconButton(
                    icon: const Icon(Icons.add,
                        size: 22.0, color: Colors.black54),
                    onPress: () {
                      controller.setText((inputQuantity + 1).toString());
                      setState(() => inputQuantity = inputQuantity + 1);
                    }),
                const SizedBox(width: 1),
                MiscIconButton(
                    icon: const Icon(Icons.remove,
                        size: 22.0, color: Colors.black54),
                    onPress: () {
                      if (inputQuantity > 1) {
                        controller.setText((inputQuantity - 1).toString());
                        setState(() => inputQuantity = inputQuantity - 1);
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
                onPress: () {
                  widget.onSubmit(
                      item.itemId.id ?? "", int.parse(controller.text));
                })
          ],
        ),
      ));
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          animationController.forward();

          Future.delayed(
            const Duration(milliseconds: 100),
            () => animationController.reverse(),
          );
          if (item.stock_count == 0) {
            showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.error(
                  message: "Out os stock",
                ),
                snackBarPosition: SnackBarPosition.bottom,
                animationDuration: const Duration(milliseconds: 700),
                displayDuration: const Duration(seconds: 1));
            return;
          }

          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: showCartAdder(),
                  );
                });
              }).then((e) {
            setState(() => inputQuantity = 1);
            controller.setText("1");
          });
        },
        child: Transform.scale(
          scale: _scaleTransformValue,
          child: Container(
            decoration: BoxDecoration(
              color: getCurrentItem() == null ? Colors.white : ACCENT_SECONDARY,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10.0),
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
                if (getCurrentItem() == null)
                  Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                                color: ACCENT_PRIMARY,
                                borderRadius: BorderRadius.circular(100.0)),
                            child: Text("$PESO${item.itemId.price}",
                                style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                  color: ACCENT_PRIMARY,
                                  borderRadius: BorderRadius.circular(100.0)),
                              child: Text(
                                  item.stock_count == 0
                                      ? "Out os stock"
                                      : "${item.stock_count} stock(s)",
                                  style: const TextStyle(color: Colors.white)))
                        ],
                      ))
                else
                  Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                            color: ACCENT_PRIMARY,
                            borderRadius: BorderRadius.circular(100.0)),
                        child: Text(
                            "Added to Cart (${getCurrentItem()!.quantity}pcs)",
                            style: const TextStyle(color: Colors.white)),
                      )),
                SizedBox(
                    height: 200,
                    child: Center(
                        child: Text(
                      "Image is Here",
                      style: TextStyle(color: Colors.grey.shade300),
                    ))),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(item.itemId.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: getCurrentItem() == null
                                  ? Colors.black87
                                  : Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'abel'))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
