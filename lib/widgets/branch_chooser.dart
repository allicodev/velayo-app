import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/screens/error_screen.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';

class BranchChooser extends StatelessWidget {
  const BranchChooser({super.key});

  @override
  Widget build(BuildContext context) {
    final appBloc = context.read<AppBloc>();
    final branchBloc = context.read<BranchBloc>();

    return BlocProvider<BranchBloc>.value(
        value: branchBloc,
        child: BlocBuilder<BranchBloc, BranchState>(builder: (context, state) {
          return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SingleChildScrollView(
                  child: state.status.isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.height * 0.8,
                          margin: const EdgeInsets.only(top: 15),
                          child: Container(),
                        )
                      : state.status.isError
                          ? const ErrorScreen(title: "Fetching Branches Error")
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Column(
                                  children: List.generate(state.branches.length,
                                      (index) {
                                return Container(
                                  margin: index == state.branches.length - 1
                                      ? null
                                      : const EdgeInsets.only(bottom: 16.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setKeyValue("selectedBranch",
                                            state.branches[index].id ?? "");
                                        appBloc.add(SetSelectedBranch(
                                            branch: branchBloc.state.branches
                                                .firstWhere((e) =>
                                                    e.id ==
                                                    state.branches[index].id)));

                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                                color: Colors.black38)),
                                        child: Column(children: [
                                          Text(
                                            state.branches[index].name,
                                            style:
                                                const TextStyle(fontSize: 28.0),
                                          ),
                                          Text(
                                              "(${state.branches[index].address})",
                                              style: const TextStyle(
                                                  color: Colors.black38))
                                        ]),
                                      ),
                                    ),
                                  ),
                                );
                              })))));
        }));
  }
}
