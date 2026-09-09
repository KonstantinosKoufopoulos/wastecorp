import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cash & simple economy state for the tutorial loop.
class EconomyState {
  const EconomyState({
    this.cash = 0,
    this.lastCashPop = 0,
  });

  final int cash;
  final int lastCashPop;

  EconomyState copyWith({int? cash, int? lastCashPop}) => EconomyState(
        cash: cash ?? this.cash,
        lastCashPop: lastCashPop ?? this.lastCashPop,
      );
}

class EconomyNotifier extends Notifier<EconomyState> {
  @override
  EconomyState build() => const EconomyState();

  void addCash(int amount) {
    state = state.copyWith(
      cash: state.cash + amount,
      lastCashPop: amount,
    );
  }

  bool spend(int amount) {
    if (state.cash < amount) return false;
    state = state.copyWith(cash: state.cash - amount, lastCashPop: 0);
    return true;
  }

  void reset() => state = const EconomyState();
}

final economyProvider =
    NotifierProvider<EconomyNotifier, EconomyState>(EconomyNotifier.new);

/// Plastic press payout stub (tutorial).
const kPlasticPressPayout = 40;

/// First worker hire cost (tutorial — nearly all money).
const kWorkerHireCost = 35;
