import 'package:flutter_riverpod/flutter_riverpod.dart';

class DistrictContract {
  const DistrictContract({
    required this.id,
    required this.districtName,
    required this.loadsRequired,
    required this.timeLimitSeconds,
    required this.rewardCash,
    required this.rewardReputation,
  });

  final String id;
  final String districtName;
  final int loadsRequired;
  final int timeLimitSeconds;
  final int rewardCash;
  final int rewardReputation;
}

class ContractState {
  const ContractState({
    this.active,
    this.loadsDone = 0,
    this.completed = false,
  });

  final DistrictContract? active;
  final int loadsDone;
  final bool completed;

  ContractState copyWith({
    DistrictContract? active,
    int? loadsDone,
    bool? completed,
    bool clearActive = false,
  }) => ContractState(
    active: clearActive ? null : (active ?? this.active),
    loadsDone: loadsDone ?? this.loadsDone,
    completed: completed ?? this.completed,
  );
}

/// Tutorial district contract: 3 loads / 90s · $80 + +1 rep (Christos locked).
const kTutorialContract = DistrictContract(
  id: 'district_north',
  districtName: 'North District',
  loadsRequired: 3,
  timeLimitSeconds: 90,
  rewardCash: 80,
  rewardReputation: 1,
);

class ContractNotifier extends Notifier<ContractState> {
  @override
  ContractState build() => const ContractState();

  void accept(DistrictContract contract) {
    state = ContractState(active: contract);
  }

  void recordLoad() {
    final c = state.active;
    if (c == null) return;
    final done = state.loadsDone + 1;
    state = state.copyWith(loadsDone: done, completed: done >= c.loadsRequired);
  }

  void clear() => state = const ContractState();
}

final contractProvider = NotifierProvider<ContractNotifier, ContractState>(
  ContractNotifier.new,
);
