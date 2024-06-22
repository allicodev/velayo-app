part of 'app_bloc.dart';

enum SettingStatus { initial, success, error, loading }

extension A on SettingStatus {
  bool get isInitial => this == SettingStatus.initial;
  bool get isSuccess => this == SettingStatus.success;
  bool get isError => this == SettingStatus.error;
  bool get isLoading => this == SettingStatus.loading;
}

class AppState extends Equatable {
  AppState(
      {this.statusSetting = SettingStatus.initial,
      this.selectedBranch,
      this.settings});

  final SettingStatus statusSetting;
  final Branch? selectedBranch;
  final Settings? settings;

  @override
  List<Object?> get props => [selectedBranch, settings, statusSetting];

  AppState copyWith(
      {Branch? selectedBranch,
      Settings? settings,
      SettingStatus? statusSetting}) {
    return AppState(
        selectedBranch: selectedBranch ?? this.selectedBranch,
        settings: settings ?? this.settings,
        statusSetting: statusSetting ?? this.statusSetting);
  }
}
