part of 'branch_bloc.dart';

enum BranchStatus { initial, success, error, loading }

extension A on BranchStatus {
  bool get isInitial => this == BranchStatus.initial;
  bool get isSuccess => this == BranchStatus.success;
  bool get isError => this == BranchStatus.error;
  bool get isLoading => this == BranchStatus.loading;
}

class BranchState extends Equatable {
  BranchState({
    this.status = BranchStatus.initial,
    List<Branch>? branches,
  }) : branches = branches ?? [];

  final List<Branch> branches;
  final BranchStatus status;

  @override
  List<Object?> get props => [status, branches];

  BranchState copyWith({
    List<Branch>? branches,
    BranchStatus? status,
  }) {
    return BranchState(
      branches: branches ?? this.branches,
      status: status ?? this.status,
    );
  }
}
