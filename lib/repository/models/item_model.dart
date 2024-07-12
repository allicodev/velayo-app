// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

  Item({
    required this.name,
    required this.unit,
    required this.itemCode,
    required this.cost,
    required this.price,
    this.description,
    this.id,
  });

  factory Item.fromJson(Map<String, dynamic> json) =>
      _$ItemFromJson(json)..id = json["id"] ?? json["_id"];
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

class MiscItem extends Item {
  MiscItem(
      {required super.name,
      required super.unit,
      required super.itemCode,
      required super.cost,
      required super.price,
      required this.quantity,
      super.id});

  int quantity;
}

class ItemCategory {
  String name;
  ItemCategory({
    required this.name,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      ItemCategory(name: json["name"] as String);
}
