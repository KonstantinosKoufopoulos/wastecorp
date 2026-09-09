import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage_service.dart';
import '../models/waste_material.dart';

/// Cash & simple economy state for the tutorial loop.
class EconomyState {
  const EconomyState({this.cash = 0, this.lastCashPop = 0});

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

final economyProvider = NotifierProvider<EconomyNotifier, EconomyState>(
  EconomyNotifier.new,
);

/// Drag-sort hit / juice (Christos locked).
const kSortItemSize = 72.0;
const kBinHitSize = 120.0;
const kSnapDistance = 48.0;
const kWrongBounceMs = 120;
const kWrongShakeDeg = 2.0;
const kCorrectScalePop = 1.15;

/// Sort payouts per correct drop.
const kSortPlasticPayout = 2;
const kSortMetalPayout = 3;
const kSortPaperPayout = 2;

int sortPayoutFor(WasteMaterial material) => switch (material) {
  WasteMaterial.plastic => kSortPlasticPayout,
  WasteMaterial.metal => kSortMetalPayout,
  WasteMaterial.paper => kSortPaperPayout,
  WasteMaterial.mixed => 0,
};

/// S1 pile size for advance.
const kS1ItemCount = 8;

/// S4 second truckload size.
const kS4TruckloadItems = 10;

/// Plastic press (S2): 1 tap, 2.0s, +$25, auto-advance.
const kPlasticPressPayout = 25;
const kPlasticPressSeconds = 2.0;

/// First worker hire cost (S3).
const kWorkerHireCost = 40;

/// Modest first metal / paper process payouts (S4 tutorial).
const kMetalProcessPayout = 12;
const kPaperProcessPayout = 10;
const kLineProcessSeconds = 1.2;
