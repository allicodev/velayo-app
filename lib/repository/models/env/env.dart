// lib/env/env.dart
// ignore_for_file: non_constant_identifier_names

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'token', obfuscate: true)
  static final String Token = _Env.Token;
  @EnviedField(varName: 'local_url', obfuscate: true)
  static final String LocalUrl = _Env.LocalUrl;
}
