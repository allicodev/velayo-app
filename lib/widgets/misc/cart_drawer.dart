import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/misc/misc_bloc.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/misc/cart_hero.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  Widget showHeader(int len) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Button(
          label: "CHECKOUT ($len items)",
          icon: Icons.login,
          textColor: Colors.white,
          backgroundColor: ACCENT_SECONDARY,
          borderColor: Colors.transparent,
          onPress: len == 0
              ? null
              : () {
                  Navigator.pushNamed(context, "/misc-payment");
                },
        ),
        Button(
          label: "CLEAR",
          icon: Icons.close,
          textColor: Colors.red,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          onPress: () => context.read<MiscBloc>().add(PurgeItem()),
        )
      ]),
    );
  }

  Widget showFooter(List<MiscItem>? items) {
    double total = 0;

    try {
      total =
          items == null ? 0 : items.map((e) => e.price).reduce((p, n) => p + n);
    } catch (e) {
      total = 0;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TOTAL:",
                style: TextStyle(fontSize: 32.0, fontFamily: 'abel')),
            Text("$PESO$total",
                style: const TextStyle(fontSize: 32.0, fontFamily: 'abel')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiscBloc, MiscState>(builder: (context, state) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.28,
        child: Column(
          children: [
            showHeader(state.items?.length ?? 0),
            const Divider(),

            // generate a list of cart(s) added
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.825,
              child: (state.items?.isNotEmpty ?? false)
                  ? ListView(
                      children: List.generate(
                          state.items?.length ?? 0,
                          (index) => CartHero(
                              item: state.items![index],
                              remove: () {
                                context.read<MiscBloc>().add(RemoveItem(
                                    id: state.items![index].id ?? ""));
                              })),
                    )
                  : const Center(
                      child: Text("No Items added",
                          style:
                              TextStyle(color: Colors.black26, fontSize: 18.0)),
                    ),
            ),
            const Divider(),
            showFooter(state.items)
          ],
        ),
      );
    });
  }
}
