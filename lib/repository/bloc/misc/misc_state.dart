part of 'misc_bloc.dart';

class MiscState extends Equatable {
  MiscState({
    this.items,
  });

  List<MiscItem>? items;

  @override
  List<Object?> get props => [items];

  MiscState copyWith({List<MiscItem>? items}) {
    return MiscState(items: items);
  }
}
