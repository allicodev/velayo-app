import 'package:json_annotation/json_annotation.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';

part 'branch_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Branch {
  String? id;
  final String name;
  final String address;
  final String device;
  final String spm;
  final List<ItemsWithStock> items;
  final DateTime? createdAt;
  final String? pin;

  Branch(
      {required this.name,
      required this.address,
      required this.device,
      required this.spm,
      required this.items,
      this.pin,
      this.createdAt});

  factory Branch.fromJson(Map<String, dynamic> json) =>
      _$BranchFromJson(json)..id = json["id"] ?? json["_id"];
  Map<String, dynamic> toJson() => _$BranchToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ItemsWithStock {
  final Item itemId;
  final int stock_count;
  final DateTime createdAt;

  ItemsWithStock(
      {required this.itemId,
      required this.stock_count,
      required this.createdAt});

  factory ItemsWithStock.fromJson(Map<String, dynamic> json) =>
      _$ItemsWithStockFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsWithStockToJson(this);
}
