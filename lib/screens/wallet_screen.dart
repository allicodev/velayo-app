import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/bloc/wallet/wallet_bloc.dart';
import 'package:velayo_flutterapp/repository/models/wallet_model.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart' as _;
import 'package:velayo_flutterapp/screens/bills_screen.dart';
import 'package:velayo_flutterapp/screens/error_screen.dart';
import 'package:velayo_flutterapp/utilities/constant.dart';
import 'package:velayo_flutterapp/widgets/button.dart';
import 'package:velayo_flutterapp/widgets/form/textfieldstyle.dart';

class Wallets extends StatefulWidget {
  const Wallets({Key? key}) : super(key: key);

  @override
  State<Wallets> createState() => _WalletsState();
}

class _WalletsState extends State<Wallets> {
  final formKey = GlobalKey<FormState>();

  String searchedWallet = "";
  String selectedWallet = "";
  String selectedWalletType = "";

  // ! bad code! bad! bad! bad!
  bool checked = false;

  Widget showWalletList(List<Wallet> wallets) {
    var _wallets = [...wallets];

    if (searchedWallet != "") {
      _wallets.removeWhere(
          (e) => !e.name.toLowerCase().contains(searchedWallet.toLowerCase()));
    } else {
      _wallets = wallets;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SELECT WALLET",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  onChanged: (val) => setState(() => searchedWallet = val),
                  decoration: textFieldStyle(
                      label: "Search Wallet",
                      prefixIcon: const Icon(Icons.search),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
                ),
              ),
            ],
          ),
          const Divider(),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 16 / 9,
                  crossAxisCount: 4,
                ),
                itemCount: _wallets.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => setState(
                            () => selectedWallet = _wallets[index].id ?? ""),
                        hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Image is here",
                              style: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _wallets[index].name,
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showSelectedWallet(List<Wallet> wallets) {
    Wallet _selectedWallet = wallets.firstWhere((e) => e.id == selectedWallet);
    List<_.FormField>? formFields = selectedWalletType == "cash-in"
        ? _selectedWallet.cashInFormField
        : _selectedWallet.cashOutFormField;

    // ? "input", "number", "textarea", "checkbox", "select"
    Widget generateForm(_.FormField f) {
      switch (f.type) {
        case "input":
          return TextFormField(
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: const TextStyle(fontSize: 21),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
                label: f.name,
                labelStyle: const TextStyle(fontSize: 25),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
          );
        case "number":
          return TextFormField(
            inputFormatters: [
              if (f.inputNumberOption?.isMoney ?? false)
                DecimalFormatter()
              else
                FilteringTextInputFormatter.digitsOnly
            ],
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: TextStyle(
                fontSize: f.inputNumberOption?.isMoney ?? false ? 25 : null),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
              label: f.name,
              prefix: f.inputNumberOption?.isMoney ?? false ? PESO : null,
              labelStyle: const TextStyle(fontSize: 25),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              backgroundColor: ACCENT_PRIMARY.withOpacity(.03),
            ),
          );
        case "textarea":
          return TextFormField(
            minLines: f.textareaOption?.minRow ?? 1,
            maxLines: f.textareaOption?.maxRow ?? 9999,
            // onChanged: (val) => setState(() => searchedBiller = val),
            maxLength: f.inputOption?.maxLength,
            style: const TextStyle(fontSize: 21),
            validator: (val) {
              if (val!.isEmpty) {
                return "${f.name} is required";
              }
              return null;
            },
            decoration: textFieldStyle(
                label: f.name,
                labelStyle: const TextStyle(fontSize: 25),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
          );
        case "checkbox":
          return Row(
            children: [
              Checkbox(
                  value: checked,
                  onChanged: (value) => setState(() => checked = value!)),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(f.name),
              ),
            ],
          );
        case "select":
          return DropDownTextField(
              clearOption: true,
              clearIconProperty: IconProperty(color: ACCENT_SECONDARY),
              validator: (val) {
                if (val!.isEmpty) {
                  return "${f.name} is required";
                }
                return null;
              },
              textFieldDecoration: textFieldStyle(
                  label: f.name,
                  labelStyle: const TextStyle(fontSize: 25),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  backgroundColor: ACCENT_PRIMARY.withOpacity(.03)),
              dropdownRadius: 5,
              dropDownList: f.selectOption!.items!.map((e) {
                return DropDownValueModel(
                  value: e['value'],
                  name: e['name'] ?? "",
                );
              }).toList(),
              onChanged: (val) {});
        default:
          return Container();
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.78,
      margin: const EdgeInsets.only(top: 15),
      child: Stack(
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
                onPress: () => setState(() {
                  selectedWallet = "";
                  selectedWalletType = "";
                }),
              )),
          if (formFields != null &&
              formFields.isNotEmpty &&
              selectedWalletType != "")
            Positioned(
                bottom: 0,
                right: 0,
                child: Button(
                    label: "SUBMIT",
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 70),
                    backgroundColor: ACCENT_SECONDARY,
                    fontSize: 25,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    onPress: () {
                      if (formKey.currentState!.validate()) {}
                    })),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (formFields != null &&
                  formFields.isNotEmpty &&
                  selectedWalletType != "")
                Center(
                  child: SizedBox(
                    width: 700,
                    child: Column(
                      children: [
                        Text(
                          "${_selectedWallet.name.toUpperCase()} ${selectedWalletType.toUpperCase()}",
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w700),
                        ),
                        Form(
                            key: formKey,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Column(
                                  children: List.generate(
                                      formFields.length,
                                      (index) => Container(
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          child:
                                              generateForm(formFields[index]))),
                                ))),
                      ],
                    ),
                  ),
                ),
              if ((_selectedWallet.cashInFormField?.isEmpty ?? false) &&
                  (_selectedWallet.cashOutFormField?.isEmpty ?? false))
                const Center(
                  child: Text("There are no Field Forms added on this Wallet"),
                )
              else if (selectedWalletType == "")
                showSelectedWalletType(_selectedWallet)
            ],
          )
        ],
      ),
    );
  }

  Widget showSelectedWalletType(Wallet _wallet) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(top: 30),
      child: Row(children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Material(
            color: (_wallet.cashInFormField?.isNotEmpty ?? false)
                ? Colors.transparent
                : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: (_wallet.cashInFormField?.isNotEmpty ?? false)
                  ? () => setState(() => selectedWalletType = "cash-in")
                  : null,
              hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 140,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "CASH IN ${(_wallet.cashInFormField?.isNotEmpty ?? false) ? "" : "\n(Disabled)"}",
                    style: TextStyle(
                        fontSize: (_wallet.cashInFormField?.isNotEmpty ?? false)
                            ? 30.0
                            : 23.0,
                        fontWeight: FontWeight.w500,
                        color: (_wallet.cashInFormField?.isNotEmpty ?? false)
                            ? Colors.black
                            : Colors.black45.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Material(
          color: (_wallet.cashOutFormField?.isNotEmpty ?? false)
              ? Colors.transparent
              : Colors.black12,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                ? () => setState(() => selectedWalletType = "cash-out")
                : null,
            hoverColor: ACCENT_SECONDARY.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 140,
              width: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(
                "CASH OUT ${(_wallet.cashOutFormField?.isNotEmpty ?? false) ? "" : "\n(Disabled)"}",
                style: TextStyle(
                    fontSize: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                        ? 30.0
                        : 23.0,
                    fontWeight: FontWeight.w500,
                    color: (_wallet.cashOutFormField?.isNotEmpty ?? false)
                        ? Colors.black
                        : Colors.black45.withOpacity(0.5)),
              )),
            ),
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
      return state.status.isSuccess
          ? selectedWallet != ""
              ? showSelectedWallet(state.wallets)
              : showWalletList(state.wallets)
          : state.status.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.8,
                  margin: const EdgeInsets.only(top: 15),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : state.status.isError
                  ? const ErrorScreen(title: "Fetching Wallets Error")
                  : const SizedBox();
    });
  }
}
