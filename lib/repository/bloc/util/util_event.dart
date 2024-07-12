part of 'util_bloc.dart';

class UtilEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewQueue extends UtilEvents {
  Map<String, dynamic> request;
  String branchId;
  Function callback;
  NewQueue(
      {required this.request, required this.branchId, required this.callback});
}

class GetLastQueue extends UtilEvents {
  String branchId;
  GetLastQueue({required this.branchId});
}
