import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Item {
  String? id;
  final String name;
  final String unit;
  final int itemCode;
  final String? description;
  final double cost;
  final double price;

  Item(
      {required this.name,
      required this.unit,
      required this.itemCode,
      this.description,
      required this.cost,
      required this.price});

  factory Item.fromJson(Map<String, dynamic> json) =>
      _$ItemFromJson(json)..id = json["id"] ?? json["_id"];
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
