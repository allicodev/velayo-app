import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velayo_flutterapp/repository/models/wallet_model.dart';
import 'package:velayo_flutterapp/repository/repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvents, WalletState> {
  WalletBloc({
    required this.walletRepository,
  }) : super(WalletState()) {
    on<GetWallets>(_mapGetWalletEventToState);
  }

  final Repository walletRepository;

  void _mapGetWalletEventToState(
      GetWallets event, Emitter<WalletState> emit) async {
    try {
      emit(state.copyWith(status: WalletStatus.loading));
      final wallets = await walletRepository.getWallets();
      emit(
        state.copyWith(
          status: WalletStatus.success,
          wallets: wallets,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: WalletStatus.error));
    }
  }
}
