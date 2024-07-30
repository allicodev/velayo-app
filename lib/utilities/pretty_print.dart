import 'dart:convert';

String prettyPrintJson(Map<String, dynamic> map) {
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(map);
}
