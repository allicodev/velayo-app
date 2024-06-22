part of 'app_bloc.dart';

class AppEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetSelectedBranch extends AppEvents {
  SetSelectedBranch({required this.branch});
  Branch branch;
}

class GetSettings extends AppEvents {}
