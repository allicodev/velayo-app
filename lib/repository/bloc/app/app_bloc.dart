import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/repository/models/settings_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvents, AppState> {
  AppBloc({
    required this.repo,
  }) : super(AppState()) {
    on<UpdateStatus>(_updateStatus);
    on<SetSelectedBranch>(_setSelectedBranch);
    on<GetSettings>(_getSettings);
    on<UpdatePin>(_updatePin);
    on<GetItemCategory>(_getItemCategories);
  }

  final Repository repo;

  void _updateStatus(UpdateStatus event, Emitter<AppState> emit) {
    emit(
      state.copyWith(statusSetting: event.status),
    );
  }

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

  void _updatePin(UpdatePin event, Emitter<AppState> emit) async {
    try {
      emit(state.copyWith(statusSetting: SettingStatus.loading));
      await repo.updatePinBranch(event.id, event.pin);
      emit(
        state.copyWith(
          statusSetting: SettingStatus.success,
        ),
      );
    } catch (error) {
      emit(state.copyWith(statusSetting: SettingStatus.error));
    }
  }

  void _getItemCategories(GetItemCategory event, Emitter<AppState> emit) async {
    try {
      emit(state.copyWith(statusSetting: SettingStatus.loading));
      final itemsCategories = await repo.getItemCategories();
      emit(
        state.copyWith(
          statusSetting: SettingStatus.success,
          itemCategories: itemsCategories,
        ),
      );
    } catch (error) {
      emit(state.copyWith(statusSetting: SettingStatus.error));
    }
  }
}
