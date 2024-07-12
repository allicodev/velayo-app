// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RequestTransaction {
  String type;
  String? sub_type;
  String transactionDetails;
  double fee;
  double amount;
  String branchId;
  String? billerId;
  String? walletId;
  bool isOnlinePayment;
  String? portal;
  String? receiverName;
  String? recieverNum;
  int queue;

  RequestTransaction({
    required this.type,
    this.sub_type,
    required this.transactionDetails,
    required this.fee,
    required this.amount,
    required this.branchId,
    this.billerId,
    this.walletId,
    required this.isOnlinePayment,
    this.portal,
    this.receiverName,
    this.recieverNum,
    required this.queue,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'sub_type': sub_type,
      'transactionDetails': transactionDetails,
      'fee': fee,
      'amount': amount,
      'branchId': branchId,
      'billerId': billerId,
      'walletId': walletId,
      'isOnlinePayment': isOnlinePayment,
      'portal': portal,
      'receiverName': receiverName,
      'recieverNum': recieverNum,
      'queue': queue
    };
  }

  String toJson() => json.encode(toMap());
}

class TransactionHistory {
  String description;
  String status;
  DateTime createdAt;
  TransactionHistory({
    required this.description,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());
}
