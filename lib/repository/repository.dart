import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/repository/service/service.dart';

class Repository {
  const Repository({
    required this.service,
  });
  final Service service;

  // get
  Future<dynamic> getBills() async => service.getBills();
  Future<dynamic> getWallets() async => service.getWallets();
  Future<dynamic> getBranches() async => service.getBranch();
  Future<dynamic> getSettings() async => service.getSettings();

  // post
  Future<dynamic> requestTransaction(RequestTransaction _) async =>
      service.requestTransaction(_);
  Future<dynamic> updateItemBranch(String _id, String type,
          List<BranchItemUpdate> items, String? transactId) async =>
      service.updateBranchItem(_id, type, items, transactId);
  Future<dynamic> updatePinBranch(String _, String __) async =>
      service.updateBranchPin(_, __);
}
