import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReputationState {
  const ReputationState({this.points = 0});

  final int points;

  ReputationState copyWith({int? points}) =>
      ReputationState(points: points ?? this.points);
}

class ReputationNotifier extends Notifier<ReputationState> {
  @override
  ReputationState build() => const ReputationState();

  void add(int amount) {
    state = state.copyWith(points: state.points + amount);
  }

  void reset() => state = const ReputationState();
}

final reputationProvider =
    NotifierProvider<ReputationNotifier, ReputationState>(
        ReputationNotifier.new);
