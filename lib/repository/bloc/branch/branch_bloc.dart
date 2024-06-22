import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';
import 'package:velayo_flutterapp/utilities/shared_prefs.dart';

part 'branch_event.dart';
part 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvents, BranchState> {
  BranchBloc({
    required this.repo,
  }) : super(BranchState()) {
    on<GetBranches>(_getBranches);
  }

  final Repository repo;

  _getBranches(GetBranches event, Emitter<BranchState> emit) async {
    try {
      emit(state.copyWith(status: BranchStatus.loading));
      final branches = await repo.getBranches();
      emit(
        state.copyWith(
          status: BranchStatus.success,
          branches: branches,
        ),
      );

      if (event.onDone != null) {
        event.onDone!();
      }
    } catch (error) {
      emit(state.copyWith(status: BranchStatus.error));
    }
  }
}
