import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/misc/misc_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';
import 'package:velayo_flutterapp/widgets/hero/misc_hero.dart';
import 'package:collection/collection.dart';

class MiscScreen extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  MiscScreen({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  State<MiscScreen> createState() => _MiscScreenState();
}

class _MiscScreenState extends State<MiscScreen> {
  late GlobalKey<ScaffoldState> scaffoldKey;
  String search = "";
  @override
  void initState() {
    scaffoldKey = widget.scaffoldKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final miscBloc = context.watch<MiscBloc>();

    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.only(top: 15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                "Welcome Guest",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      onChanged: (val) => setState(() => search = val),
                      decoration: textFieldStyle(
                          label: "Search Items",
                          prefixIcon: const Icon(Icons.search),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            Badge.count(
                                count: miscBloc.state.items?.length ?? 0,
                                isLabelVisible:
                                    (miscBloc.state.items?.length ?? 0) != 0,
                                child: const Icon(
                                  Icons.shopping_cart,
                                  size: 32.0,
                                )),
                            const Text("My Cart")
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ]),
            const Divider(),
            Stack(
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: MasonryGridView.count(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      crossAxisCount: 4,
                      mainAxisSpacing: 50,
                      crossAxisSpacing: 25,
                      itemCount: state.selectedBranch?.items
                              .where((e) => e.itemId.name
                                  .toLowerCase()
                                  .contains(search.toLowerCase()))
                              .length ??
                          0,
                      itemBuilder: (context, index) => MiscHero(
                        item: state.selectedBranch!.items
                            .where((e) => e.itemId.name
                                .toLowerCase()
                                .contains(search.toLowerCase()))
                            .toList()[index],
                        onSubmit: (itemId, quantity) {
                          ItemsWithStock? item = state.selectedBranch?.items
                              .firstWhereOrNull((e) => e.itemId.id == itemId);

                          if (item != null) {
                            MiscItem? miscItem = miscBloc.state.items
                                ?.firstWhereOrNull((e) => e.id == itemId);

                            if (item.stock_count < quantity ||
                                (miscItem != null &&
                                    quantity >
                                        item.stock_count - miscItem.quantity)) {
                              showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(
                                    message:
                                        "Quantity is greater than available stock(s)",
                                  ),
                                  snackBarPosition: SnackBarPosition.bottom,
                                  animationDuration:
                                      const Duration(milliseconds: 700),
                                  displayDuration: const Duration(seconds: 1));
                              return;
                            }

                            MiscItem? _item = miscBloc.state.items
                                ?.firstWhereOrNull(
                                    (e) => e.id == item.itemId.id);

                            if (_item != null) {
                              miscBloc.add(UpdateItemQuantity(
                                  id: item.itemId.id ?? "",
                                  quantity: _item.quantity + quantity));

                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              return;
                            }

                            miscBloc.add(AddItem(
                                item: MiscItem(
                                    id: item.itemId.id,
                                    name: item.itemId.name,
                                    unit: item.itemId.unit,
                                    itemCode: item.itemId.itemCode,
                                    cost: item.itemId.cost,
                                    price: item.itemId.price,
                                    quantity: quantity)));

                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                if (miscBloc.state.items?.isNotEmpty ?? false)
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Button(
                          label: "CHECKOUT",
                          icon: Icons.login,
                          textColor: Colors.white,
                          backgroundColor: ACCENT_PRIMARY,
                          borderColor: Colors.transparent,
                          fontSize: 24.0,
                          onPress: () {
                            Navigator.pushNamed(context, "/misc-payment");
                          })),
              ],
            ),
          ],
        ),
      );
    });
  }
}
