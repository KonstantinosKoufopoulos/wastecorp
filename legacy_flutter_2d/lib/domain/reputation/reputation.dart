import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage_service.dart';

class ReputationState {
  const ReputationState({this.points = 0});

  final int points;

  ReputationState copyWith({int? points}) =>
      ReputationState(points: points ?? this.points);
}

class ReputationNotifier extends Notifier<ReputationState> {
  @override
  ReputationState build() =>
      ReputationState(points: StorageService.getReputation());

  Future<void> add(int amount) async {
    final next = state.points + amount;
    state = state.copyWith(points: next);
    await StorageService.setReputation(next);
  }

  Future<void> reset() async {
    state = const ReputationState();
    await StorageService.setReputation(0);
  }
}

final reputationProvider =
    NotifierProvider<ReputationNotifier, ReputationState>(
      ReputationNotifier.new,
    );
