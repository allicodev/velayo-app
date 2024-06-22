import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/settings_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvents, AppState> {
  AppBloc({
    required this.repo,
  }) : super(AppState()) {
    on<SetSelectedBranch>(_setSelectedBranch);
    on<GetSettings>(_getSettings);
  }

  final Repository repo;

  void _setSelectedBranch(SetSelectedBranch event, Emitter<AppState> emit) {
    emit(
      state.copyWith(selectedBranch: event.branch),
    );
  }

  void _getSettings(GetSettings event, Emitter<AppState> emit) async {
    try {
      emit(state.copyWith(statusSetting: SettingStatus.loading));
      final settings = await repo.getSettings();
      emit(
        state.copyWith(
          statusSetting: SettingStatus.success,
          settings: settings,
        ),
      );
    } catch (error) {
      emit(state.copyWith(statusSetting: SettingStatus.error));
    }
  }
}
