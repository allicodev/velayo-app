part of 'bill_bloc.dart';

class BillEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetBills extends BillEvents {
  @override
  List<Object?> get props => [];
}

class ReqTransaction extends BillEvents {
  RequestTransaction requestTransaction;
  Function(dynamic)? onDone;
  ReqTransaction({required this.requestTransaction, this.onDone});
}
