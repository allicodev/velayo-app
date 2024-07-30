part of 'app_bloc.dart';

class AppEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateStatus extends AppEvents {
  SettingStatus status;
  UpdateStatus({required this.status});
}

class SetSelectedBranch extends AppEvents {
  SetSelectedBranch({required this.branch});
  Branch branch;
}

class GetSettings extends AppEvents {}

class GetItemCategory extends AppEvents {}

class UpdatePin extends AppEvents {
  String id;
  String pin;
  UpdatePin({required this.id, required this.pin});
}

class InitBluetooth extends AppEvents {}
