import 'package:velayo_flutterapp/repository/errors.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';
import 'package:velayo_flutterapp/repository/models/wallet_model.dart';
import 'package:velayo_flutterapp/repository/service/api_service.dart';
import 'package:velayo_flutterapp/utilities/api_status.dart';

class Service {
  getBills() async {
    final response = await APIServices.get(endpoint: "/api/bill/get-bill");

    if (response is Success) {
      if (response.response["data"].isNotEmpty) {
        return List<Bill>.from(
            response.response["data"].map((x) => Bill.fromJson(x)));
      } else {
        throw ErrorEmptyResponse();
      }
    }
    if (response is Failure) {
      throw ErrorGettingBills();
    }
  }

  getWallets() async {
    final response = await APIServices.get(endpoint: "/api/wallet/get-wallet");

    if (response is Success) {
      if (response.response["data"].isNotEmpty) {
        return List<Wallet>.from(
            response.response["data"].map((x) => Wallet.fromJson(x)));
      } else {
        throw ErrorEmptyResponse();
      }
    }
    if (response is Failure) {
      throw ErrorGettingWallets();
    }
  }
}
