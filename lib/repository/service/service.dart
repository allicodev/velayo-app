import 'package:velayo_flutterapp/repository/errors.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/repository/models/request_transaction_model.dart';
import 'package:velayo_flutterapp/repository/models/settings_model.dart';
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

  getBranch() async {
    final response = await APIServices.get(endpoint: "/api/branch");
    if (response is Success) {
      if (response.response["data"].isNotEmpty) {
        return List<Branch>.from(
            response.response["data"].map((x) => Branch.fromJson(x)));
      } else {
        throw ErrorEmptyResponse();
      }
    }
    if (response is Failure) {
      throw ErrorGettingBranches();
    }
  }

  requestTransaction(RequestTransaction transaction) async {
    Map<String, dynamic> payload = transaction.toMap();
    payload["history"] = [
      {
        "description": "First  Transaction requested",
        "status": "request",
        "createdAt": DateTime.now().toIso8601String(),
      },
    ];

    final response = await APIServices.post(
        endpoint: "/api/bill/request-transaction", payload: payload);

    if (response is Success) {
      if (response.response["data"] != null) {
        return response.response["data"];
      } else {
        throw ErrorEmptyResponse();
      }
    }
    if (response is Failure) {
      throw ErrorGettingSettings();
    }
  }

  getSettings() async {
    try {
      final response =
          await APIServices.get(endpoint: "/api/etc/eload-settings");
      if (response is Success) {
        if (response.response["data"] != null) {
          return Settings.fromJson(response.response["data"]);
        } else {
          throw ErrorEmptyResponse();
        }
      }
      if (response is Failure) {
        throw ErrorGettingSettings();
      }
    } catch (e) {
      print(e);
    }
  }

  updateBranchItem(String _id, String type, List<BranchItemUpdate> items,
      String? transactId) async {
    Map<String, dynamic> payload = {
      "_id": _id,
      "type": type,
      "items": items.map((x) => x.toJson()).toList(),
      "transactId": transactId,
    };

    final response = await APIServices.post(
        endpoint: "/api/branch/update-items", payload: payload);
    if (response is Failure) {
      throw ErrorGettingSettings();
    }
  }

  updateBranchPin(String _id, String pin) async {
    final response = await APIServices.post(
        endpoint: "/api/branch/update-pin", payload: {"_id": _id, "pin": pin});

    if (response is Failure) {
      throw ErrorUpdate();
    }

    return response;
  }
}
