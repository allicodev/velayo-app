part of 'app_bloc.dart';

enum SettingStatus { initial, success, error, loading }

extension A on SettingStatus {
  bool get isInitial => this == SettingStatus.initial;
  bool get isSuccess => this == SettingStatus.success;
  bool get isError => this == SettingStatus.error;
  bool get isLoading => this == SettingStatus.loading;
}

class AppState extends Equatable {
  const AppState(
      {this.statusSetting = SettingStatus.initial,
      this.isBTConnected = false,
      this.selectedBranch,
      this.settings,
      this.itemCategories});

  final SettingStatus statusSetting;
  final bool isBTConnected;
  final Branch? selectedBranch;
  final Settings? settings;
  final List<ItemCategory>? itemCategories;

  @override
  List<Object?> get props =>
      [selectedBranch, settings, statusSetting, itemCategories, isBTConnected];

  AppState copyWith(
      {Branch? selectedBranch,
      Settings? settings,
      SettingStatus? statusSetting,
      List<ItemCategory>? itemCategories,
      bool? isBTConnected}) {
    return AppState(
        selectedBranch: selectedBranch ?? this.selectedBranch,
        settings: settings ?? this.settings,
        statusSetting: statusSetting ?? this.statusSetting,
        itemCategories: itemCategories ?? this.itemCategories,
        isBTConnected: isBTConnected ?? this.isBTConnected);
  }
}
