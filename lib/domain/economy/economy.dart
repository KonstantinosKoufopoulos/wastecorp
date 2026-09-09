import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage_service.dart';

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
  EconomyState build() => EconomyState(cash: StorageService.getCash());

  Future<void> addCash(int amount) async {
    final next = state.cash + amount;
    state = state.copyWith(cash: next, lastCashPop: amount);
    await StorageService.setCash(next);
  }

  Future<bool> spend(int amount) async {
    if (state.cash < amount) return false;
    final next = state.cash - amount;
    state = state.copyWith(cash: next, lastCashPop: 0);
    await StorageService.setCash(next);
    return true;
  }

  Future<void> reset() async {
    state = const EconomyState();
    await StorageService.setCash(0);
  }
}

final economyProvider =
    NotifierProvider<EconomyNotifier, EconomyState>(EconomyNotifier.new);

/// Plastic press payout stub (tutorial).
const kPlasticPressPayout = 40;

/// First worker hire cost (tutorial — nearly all money).
const kWorkerHireCost = 35;
