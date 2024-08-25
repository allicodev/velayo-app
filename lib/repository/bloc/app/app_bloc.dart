import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:velayo_flutterapp/repository/models/branch_model.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/repository/models/settings_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';
import 'package:velayo_flutterapp/utilities/bloc_helper.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvents, AppState>
    with BlocHelper<AppEvents, AppState> {
  AppBloc({required this.repo, required this.navigatorKey})
      : super(const AppState()) {
    on<UpdateStatus>(_updateStatus);
    on<SetSelectedBranch>(_setSelectedBranch);
    on<GetSettings>(_getSettings);
    on<UpdatePin>(_updatePin);
    on<GetItemCategory>(_getItemCategories);
    on<InitBluetooth>(_initBluetooth);
    on<UpdateBluetooth>(_updateBluetooth);
  }

  final Repository repo;
  final GlobalKey<NavigatorState> navigatorKey;

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

  void _initBluetooth(InitBluetooth event, Emitter<AppState> emit) async {
    BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

    try {
      List<BluetoothDevice> devices = [];
      devices = await bluetooth.getBondedDevices();
      if (devices.isEmpty) {
        _showSnackBar("ERROR", "No nearby bluetooth printer detected", emit);
      } else {
        BluetoothDevice? printerDevice =
            devices.where((e) => e.name == "BlueTooth Printer").firstOrNull;

        if (printerDevice != null) {
          bluetooth.isConnected.then((e) => bluetooth.connect(printerDevice));
          _showSnackBar("SUCCESS", "Bluetooth Connected", emit);
        } else {
          _showSnackBar("ERROR", "Not connected to printer", emit);
        }
      }
    } on PlatformException {}
  }

  void _updateBluetooth(UpdateBluetooth event, Emitter<AppState> emit) {
    emit(state.copyWith(isBTConnected: event.isConnected));
  }

  _showSnackBar(String status, String message, Emitter<AppState> emit) {
    showTopSnackBar(
        navigatorKey.currentState!.overlay!,
        status == "ERROR"
            ? CustomSnackBar.error(
                message: message,
              )
            : CustomSnackBar.success(
                message: message,
              ),
        snackBarPosition: SnackBarPosition.bottom,
        animationDuration: const Duration(milliseconds: 700),
        displayDuration: const Duration(seconds: 1));
  }
}
