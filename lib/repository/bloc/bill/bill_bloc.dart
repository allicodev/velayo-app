import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/repository.dart';
import 'package:velayo_flutterapp/repository/models/bills_model.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillsBloc extends Bloc<BillEvents, BillState> {
  BillsBloc({
    required this.billRepository,
  }) : super(BillState()) {
    on<GetBills>(_mapGetGamesEventToState);
  }

  final Repository billRepository;

  void _mapGetGamesEventToState(GetBills event, Emitter<BillState> emit) async {
    try {
      emit(state.copyWith(status: BillStatus.loading));
      final bills = await billRepository.getBills();
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
