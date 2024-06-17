part of 'misc_bloc.dart';

class MiscEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddItem extends MiscEvents {
  AddItem({required this.item});
  final MiscItem item;
}

class RemoveItem extends MiscEvents {
  RemoveItem({required this.id});
  final String id;
}

class UpdateItemQuantity extends MiscEvents {
  UpdateItemQuantity({required this.id, required this.quantity});
  final String id;
  final int quantity;
}

class PurgeItem extends MiscEvents {}
