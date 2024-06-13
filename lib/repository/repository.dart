import 'package:velayo_flutterapp/repository/service/service.dart';

class Repository {
  const Repository({
    required this.service,
  });
  final Service service;

  Future<dynamic> getBills() async => service.getBills();
  Future<dynamic> getWallets() async => service.getWallets();
  Future<dynamic> getBranches() async => service.getBranch();
}
