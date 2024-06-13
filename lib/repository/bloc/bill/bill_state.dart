part of 'bill_bloc.dart';

enum BillStatus { initial, success, error, loading }

extension A on BillStatus {
  bool get isInitial => this == BillStatus.initial;
  bool get isSuccess => this == BillStatus.success;
  bool get isError => this == BillStatus.error;
  bool get isLoading => this == BillStatus.loading;
}

class BillState extends Equatable {
  BillState({
    this.status = BillStatus.initial,
    List<Bill>? bills,
  }) : bills = bills ?? [];

  final List<Bill> bills;
  final BillStatus status;

  @override
  List<Object?> get props => [status, bills];

  BillState copyWith({
    List<Bill>? bills,
    BillStatus? status,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      status: status ?? this.status,
    );
  }
}
