import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';
import 'package:velayo_flutterapp/widgets/branch_chooser.dart';
import 'package:velayo_flutterapp/widgets/button.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String selectedButton = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getValue('selectedBranch').then((selectedBranch) {
        if (selectedBranch != "") {
          BlocProvider.of<AppBloc>(context).add(SetSelectedBranch(
              branch: BlocProvider.of<BranchBloc>(context)
                  .state
                  .branches
                  .firstWhere((e) => e.id == selectedBranch)));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final branchBloc = context.watch<BranchBloc>();
    final appBloc = context.watch<AppBloc>();

    Widget generateAdminButton(int i) {
      switch (i) {
        case 0:
          {
            return Material(
              color: selectedButton == admin_home[i]
                  ? ACCENT_SECONDARY
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  setState(() => selectedButton = admin_home[i]);
                  branchBloc.add(GetBranches());

                  showDialog(
                      context: context,
                      builder: (context) {
                        return const BranchChooser();
                      });
                },
                hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: ACCENT_SECONDARY),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            admin_home[i],
                            style: TextStyle(
                                fontSize: 18.0,
                                color: selectedButton == admin_home[i]
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          if (appBloc.state.selectedBranch != null)
                            Text(
                              appBloc.state.selectedBranch!.name,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: selectedButton == admin_home[i]
                                      ? Colors.white
                                      : Colors.black),
                            ),
                        ],
                      ),
                    )),
              ),
            );
          }
        case 1:
          {
            // nothing, this is pin update before
            return Container();
          }
        default:
          return Container();
      }
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<BranchBloc, BranchState>(
          builder: (context, branchState) {
            return branchState.status.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Button(
                          label: "BACK",
                          fontSize: 25,
                          icon: Icons.chevron_left_rounded,
                          textColor: Colors.black87,
                          width: 170,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          onPress: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        child: SingleChildScrollView(
                          child: MasonryGridView.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: admin_home.length,
                            itemBuilder: (context, index) {
                              return generateAdminButton(index);
                            },
                          ),
                        ),
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }
}
