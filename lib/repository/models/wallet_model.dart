import 'package:json_annotation/json_annotation.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';

part 'wallet_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Wallet {
  final String name;
  final String cashinType;
  final double cashinFeeValue;
  final String cashoutType;
  final double cashoutFeeValue;
  final List<FormField>? cashInFormField;
  final List<FormField>? cashOutFormField;
  final List<Map<dynamic, dynamic>>? cashInexceptFormField;
  final List<Map<dynamic, dynamic>>? cashOutexceptFormField;
  final bool isDisabled;
  final DateTime? createdAt;

  Wallet(
      {required this.name,
      required this.cashinType,
      required this.cashinFeeValue,
      required this.cashoutType,
      required this.cashoutFeeValue,
      this.cashInFormField,
      this.cashOutFormField,
      this.cashInexceptFormField,
      this.cashOutexceptFormField,
      this.isDisabled = false,
      this.createdAt});

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);
}
