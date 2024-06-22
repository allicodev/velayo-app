import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/etc.dart';
import 'package:velayo_flutterapp/repository/models/item_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';

part 'misc_event.dart';
part 'misc_state.dart';

class MiscBloc extends Bloc<MiscEvents, MiscState> {
  MiscBloc({
    required this.repo,
  }) : super(MiscState()) {
    on<AddItem>(_addItem);
    on<RemoveItem>(_removeItem);
    on<UpdateItemQuantity>(_updateItemQuatity);
    on<PurgeItem>(_purge);
    on<UpdateItemBranch>(_updateItemBranch);
  }

  final Repository repo;

  void _addItem(AddItem event, Emitter<MiscState> emit) {
    emit(
      state.copyWith(items: [...?state.items, event.item]),
    );
  }

  void _removeItem(RemoveItem event, Emitter<MiscState> emit) {
    emit(
      state.copyWith(
          items: state.items!.where((e) => e.id != event.id).toList()),
    );
  }

  void _updateItemQuatity(UpdateItemQuantity event, Emitter<MiscState> emit) {
    emit(
      state.copyWith(
          items: state.items!.map((e) {
        if (e.id == event.id) {
          e.quantity = event.quantity;
        }
        return e;
      }).toList()),
    );
  }

  void _purge(PurgeItem event, Emitter<MiscState> emit) {
    emit(state.copyWith(items: []));
  }

  void _updateItemBranch(
      UpdateItemBranch event, Emitter<MiscState> emit) async {
    try {
      await repo.updateItemBranch(
          event.id, event.type, event.items, event.transactId);
    } catch (error) {
      // emit(state.copyWith(status: BranchStatus.error));
    }
  }
}
