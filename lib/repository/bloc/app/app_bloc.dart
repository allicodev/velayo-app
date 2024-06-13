import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvents, AppState> {
  AppBloc() : super(AppState()) {
    on<SetSelectedBranch>(_setSelectedBranch);
  }

  void _setSelectedBranch(SetSelectedBranch event, Emitter<AppState> emit) {
    emit(
      state.copyWith(selectedBranch: event.branch),
    );
  }
}
