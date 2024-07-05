import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable()
class Settings {
  List<String> disabled_eload;
  double fee;
  double threshold;
  double additionalFee;
  String pin;

  Settings(
      {required this.disabled_eload,
      required this.fee,
      required this.threshold,
      required this.additionalFee,
      required this.pin});

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
