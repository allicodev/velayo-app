part of 'app_bloc.dart';

class AppState extends Equatable {
  AppState({
    this.selectedBranch,
  });

  Branch? selectedBranch;

  @override
  List<Object?> get props => [selectedBranch];

  AppState copyWith({Branch? selectedBranch}) {
    return AppState(selectedBranch: selectedBranch);
  }
}
