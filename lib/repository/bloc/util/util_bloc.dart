import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/repository.dart';

part 'util_event.dart';
part 'util_state.dart';

class UtilBloc extends Bloc<UtilEvents, UtilState> {
  UtilBloc({
    required this.repo,
  }) : super(UtilState()) {
    on<NewQueue>(_newQueue);
    on<GetLastQueue>(_lastQueue);
  }

  final Repository repo;

  void _newQueue(NewQueue event, Emitter<UtilState> emit) async {
    try {
      emit(state.copyWith(status: UtilStatus.loading));
      final response = await repo.newQueue(event.branchId, event.request);

      emit(
        state.copyWith(
          status: UtilStatus.success,
        ),
      );

      if (response.response["success"]) {
        add(GetLastQueue(branchId: event.branchId));
        event.callback(true);
      }
    } catch (error) {
      emit(state.copyWith(status: UtilStatus.error));
    }
  }

  void _lastQueue(GetLastQueue event, Emitter<UtilState> emit) async {
    try {
      emit(state.copyWith(status: UtilStatus.loading));
      final response = await repo.lastQueue(event.branchId);
      emit(
        state.copyWith(
            status: UtilStatus.success, lastQueue: response.response["data"]),
      );
    } catch (error) {
      emit(state.copyWith(status: UtilStatus.error));
    }
  }
}
