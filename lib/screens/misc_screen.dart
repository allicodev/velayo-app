import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';
import 'package:velayo_flutterapp/widgets/hero/misc_hero.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((selectedBranch) {
        BlocProvider.of<AppBloc>(context).add(SetSelectedBranch(
            branch: BlocProvider.of<BranchBloc>(context)
                .state
                .branches
                .firstWhere((e) => e.id == selectedBranch)));
      });
    });
    scaffoldKey = widget.scaffoldKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Badge.count(
                        count: 12,
                        // isLabelVisible: false,
                        child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () {
                                  scaffoldKey.currentState!.openEndDrawer();
                                },
                                child: const Icon(
                                  Icons.shopping_cart,
                                  size: 32.0,
                                )))),
                  )
                ],
              ),
            ]),
            const Divider(),
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
                    item: state.selectedBranch!.items[index],
                    onSubmit: (itemId, quantity) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
