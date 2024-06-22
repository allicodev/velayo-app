import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/app/app_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/bill/bill_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/branch/branch_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/misc/misc_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class MiscPayment extends StatefulWidget {
  const MiscPayment({super.key});

  @override
  State<MiscPayment> createState() => _MiscPaymentState();
}

class _MiscPaymentState extends State<MiscPayment> {
  final formKey = GlobalKey<FormState>();
  bool isOnlinePayment = false;

  Map<String, dynamic> onlinePaymentInput = {
    "portal": "",
    "receiverName": "",
    "recieverNum": ""
  };

  handleRequest() {
    var miscBloc = BlocProvider.of<MiscBloc>(context);
    var billsBloc = BlocProvider.of<BillsBloc>(context);

    Branch? currentBranch =
        BlocProvider.of<AppBloc>(context).state.selectedBranch;

    double total = miscBloc.state.items!
        .map((e) => e.price * e.quantity)
        .reduce((p, n) => p + n);

    double fee = miscBloc.state.items == null
        ? 0
        : miscBloc.state.items!
            .map((e) => (e.price - e.cost) * e.quantity)
            .reduce((p, n) => p + n);

    RequestTransaction tran = RequestTransaction(
        type: "miscellaneous",
        transactionDetails: jsonEncode(miscBloc.state.items
            ?.map((e) => ({
                  "name": e.name,
                  "price": e.price,
                  "quantity": e.quantity,
                  "unit": e.unit,
                  "cost": e.cost
                }))
            .toList()),
        fee: fee,
        amount: total - fee,
        branchId: currentBranch?.id ?? "",
        isOnlinePayment: isOnlinePayment);

    if (isOnlinePayment) {
      tran.portal = onlinePaymentInput["portal"];
      tran.receiverName = onlinePaymentInput["receiverName"];
      tran.recieverNum = onlinePaymentInput["recieverNum"];
    }

    billsBloc.add(ReqTransaction(
        requestTransaction: tran,
        onDone: (data) {
          miscBloc.add(UpdateItemBranch(
              id: data["branchId"],
              type: "misc",
              items: miscBloc.state.items!
                  .map((e) => BranchItemUpdate(id: e.id!, count: -(e.quantity)))
                  .toList(),
              transactId: data["_id"]));
          miscBloc.add(PurgeItem());
        }));
  }

  @override
  Widget build(BuildContext context) {
    final miscBloc = context.read<MiscBloc>();
    final branchBloc = context.read<BranchBloc>();
    final appBloc = context.read<AppBloc>();

    double calculateTotal() {
      if (miscBloc.state.items == null ||
          (miscBloc.state.items?.isEmpty ?? false)) return 0;
      return miscBloc.state.items!
          .map((e) => e.price * e.quantity)
          .reduce((p, n) => p + n);
    }

    Widget cardItem(MiscItem item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        height: 100,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                    child: Text("Image is here",
                        style: TextStyle(color: Colors.grey.shade400)))),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const SizedBox(
                      width: 55,
                      child: Text("PRICE: "),
                    ),
                    Text("$PESO${item.price}",
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 55,
                      child: Text("QTY: "),
                    ),
                    Text(item.quantity.toString(),
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
          ]),
          Container(
            margin: const EdgeInsets.only(right: 25.0),
            child: Text("$PESO${item.price * item.quantity}",
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600)),
          )
        ]),
      );
    }

    Widget onlinePaymentForm() {
      return Form(
          key: formKey,
          child: Column(children: [
            TextFormField(
              style: const TextStyle(fontSize: 21),
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["portal"] = val),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Portal is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label: "Portal (Payment Wallet Used)",
                  labelStyle: const TextStyle(fontSize: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["receiverName"] = val),
              style: const TextStyle(fontSize: 21),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Sender Name is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label:
                      "Sender Name (Payees name of payment wallet being sent)",
                  labelStyle: const TextStyle(fontSize: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              onChanged: (val) =>
                  setState(() => onlinePaymentInput["recieverNum"] = val),
              style: const TextStyle(fontSize: 21),
              validator: (val) {
                if (val!.isEmpty) {
                  return "Sender Number/Account Number is required";
                }
                return null;
              },
              decoration: textFieldStyle(
                  label: "Sender Number/Account Number",
                  labelStyle: const TextStyle(fontSize: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
            ),
          ]));
    }

    Widget showA() {
      return Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Item Cart",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  )),
              const Divider(),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: miscBloc.state.items?.length ?? 0,
                    itemBuilder: (context, index) {
                      return cardItem(miscBloc.state.items![index]);
                    }),
              )),
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text("$PESO${calculateTotal()}",
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget showB() {
      return Expanded(
        flex: 1,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isOnlinePayment,
                        onChanged: (bool? value) =>
                            setState(() => isOnlinePayment = !isOnlinePayment),
                      ),
                      const SizedBox(width: 10.0),
                      const Text("Online Payment",
                          style: TextStyle(fontSize: 24.0)),
                    ],
                  ),
                  if (isOnlinePayment) ...[
                    const Divider(),
                    const SizedBox(height: 10.0),
                    onlinePaymentForm()
                  ]
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Button(
                label: "CHECKOUT",
                fontSize: 18.0,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                backgroundColor: ACCENT_SECONDARY,
                borderColor: Colors.transparent,
                onPress: () {
                  if (isOnlinePayment) {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                  }
                  handleRequest();
                })
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Miscellaneous Payment"),
        backgroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<BillsBloc, BillState>(
        listener: (context, state) {
          if (state.requestStatus.isSuccess) {
            branchBloc.add(GetBranches(onDone: () {
              appBloc.add(SetSelectedBranch(
                  branch: BlocProvider.of<BranchBloc>(context)
                      .state
                      .branches
                      .firstWhere((e) =>
                          e.id == (appBloc.state.selectedBranch?.id ?? ""))));
            }));

            Navigator.pushNamed(context, "/request-success");
          }
        },
        child: Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              showA(),
              const SizedBox(
                width: 15.0,
              ),
              showB()
            ],
          ),
        ),
      ),
    );
  }
}
