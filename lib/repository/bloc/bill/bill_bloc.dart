import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/repository.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillsBloc extends Bloc<BillEvents, BillState> {
  BillsBloc({
    required this.repo,
  }) : super(BillState()) {
    on<GetBills>(_getBills);
  }

  final Repository repo;

  void _getBills(GetBills event, Emitter<BillState> emit) async {
    try {
      emit(state.copyWith(status: BillStatus.loading));
      final bills = await repo.getBills();
      emit(
        state.copyWith(
          status: BillStatus.success,
          bills: bills,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: BillStatus.error));
    }
  }
}
