part of 'wallet_bloc.dart';

enum WalletStatus { initial, success, error, loading }

extension AllGamesStatusX on WalletStatus {
  bool get isInitial => this == WalletStatus.initial;
  bool get isSuccess => this == WalletStatus.success;
  bool get isError => this == WalletStatus.error;
  bool get isLoading => this == WalletStatus.loading;
}

class WalletState extends Equatable {
  WalletState({
    this.status = WalletStatus.initial,
    List<Wallet>? wallets,
  }) : wallets = wallets ?? [];

  final List<Wallet> wallets;
  final WalletStatus status;

  @override
  List<Object?> get props => [status, wallets];

  WalletState copyWith({
    List<Wallet>? wallets,
    WalletStatus? status,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      status: status ?? this.status,
    );
  }
}
