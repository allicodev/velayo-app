// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'bills_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Bill {
  String? id;
  final String name;
  final double fee;
  final double threshold;
  final double additionalFee;
  final List<FormField>? formField;
  final List<Map<dynamic, dynamic>>? exceptFormField;
  final bool? isDisabled;
  final DateTime? createdAt;

  Bill(
      {required this.name,
      this.id,
      this.fee = 0,
      this.threshold = 0,
      this.additionalFee = 0,
      this.formField,
      this.exceptFormField,
      this.isDisabled,
      this.createdAt});

  factory Bill.fromJson(Map<String, dynamic> json) =>
      _$BillFromJson(json)..id = json["id"] ?? json["_id"];
  Map<String, dynamic> toJson() => _$BillToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FormField {
  final String type;
  final String name;
  final String? slug_name;
  final InputOption? inputOption;
  final InputNumberOption? inputNumberOption;
  final TextAreaOption? textareaOption;
  final SelectOption? selectOption;

  FormField(
      {required this.type,
      required this.name,
      this.slug_name,
      this.inputOption,
      this.inputNumberOption,
      this.textareaOption,
      this.selectOption});

  factory FormField.fromJson(Map<String, dynamic> json) =>
      _$FormFieldFromJson(json);
  Map<String, dynamic> toJson() => _$FormFieldToJson(this);
}

@JsonSerializable()
class BaseOption {
  final int? minLength;
  final int? maxLength;
  BaseOption({this.minLength, this.maxLength});

  factory BaseOption.fromJson(Map<String, dynamic> json) =>
      _$BaseOptionFromJson(json);
  Map<String, dynamic> toJson() => _$BaseOptionToJson(this);
}

@JsonSerializable()
class InputOption extends BaseOption {
  InputOption({int? minLength, int? maxLength})
      : super(maxLength: maxLength, minLength: minLength);

  factory InputOption.fromJson(Map<String, dynamic> json) =>
      _$InputOptionFromJson(json);
  Map<String, dynamic> toJson() => _$InputOptionToJson(this);
}

@JsonSerializable()
class InputNumberOption extends InputOption {
  final bool? mainAmount;
  final bool? isMoney;
  final int? min;
  final int? max;
  InputNumberOption(
      {this.mainAmount,
      this.isMoney,
      this.min,
      this.max,
      int? maxLength,
      int? minLength})
      : super(maxLength: maxLength, minLength: minLength);

  factory InputNumberOption.fromJson(Map<String, dynamic> json) =>
      _$InputNumberOptionFromJson(json);
  Map<String, dynamic> toJson() => _$InputNumberOptionToJson(this);
}

@JsonSerializable()
class TextAreaOption {
  final int? minRow;
  final int? maxRow;
  TextAreaOption({this.minRow, this.maxRow});

  factory TextAreaOption.fromJson(Map<String, dynamic> json) =>
      _$TextAreaOptionFromJson(json);
  Map<String, dynamic> toJson() => _$TextAreaOptionToJson(this);
}

@JsonSerializable()
class SelectOption {
  final List<Map<dynamic, dynamic>>? items;
  SelectOption({this.items});

  factory SelectOption.fromJson(Map<String, dynamic> json) =>
      _$SelectOptionFromJson(json);
  Map<String, dynamic> toJson() => _$SelectOptionToJson(this);
}
