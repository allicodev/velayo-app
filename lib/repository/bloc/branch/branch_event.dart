part of 'branch_bloc.dart';

class BranchEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetBranches extends BranchEvents {
  Function? onDone;
  GetBranches({this.onDone});
}
