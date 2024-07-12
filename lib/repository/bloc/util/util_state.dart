part of 'util_bloc.dart';

enum UtilStatus { initial, success, error, loading }

extension A on UtilStatus {
  bool get isInitial => this == UtilStatus.initial;
  bool get isSuccess => this == UtilStatus.success;
  bool get isError => this == UtilStatus.error;
  bool get isLoading => this == UtilStatus.loading;
}

class UtilState extends Equatable {
  const UtilState({this.status = UtilStatus.initial, this.lastQueue = 0});

  final UtilStatus status;
  final int lastQueue;

  @override
  List<Object?> get props => [status, lastQueue];

  UtilState copyWith({UtilStatus? status, int? lastQueue}) {
    return UtilState(
        status: status ?? this.status, lastQueue: lastQueue ?? this.lastQueue);
  }
}
