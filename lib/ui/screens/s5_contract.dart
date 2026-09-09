import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contracts/contracts.dart';
import '../../domain/economy/economy.dart';
import '../../domain/reputation/reputation.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

/// S5 — Contract: 3 loads / 90s · Accept · chip HUD · \$80 + +1 rep.
class S5ContractScreen extends ConsumerStatefulWidget {
  const S5ContractScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S5ContractScreen> createState() => _S5ContractScreenState();
}

class _S5ContractScreenState extends ConsumerState<S5ContractScreen> {
  bool accepted = false;
  bool hauling = false;
  bool rewarded = false;
  int secondsLeft = kTutorialContract.timeLimitSeconds;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _accept() {
    ref.read(contractProvider.notifier).accept(kTutorialContract);
    setState(() {
      accepted = true;
      secondsLeft = kTutorialContract.timeLimitSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (secondsLeft <= 0 || ref.read(contractProvider).completed) {
        t.cancel();
        return;
      }
      setState(() => secondsLeft--);
    });
  }

  Future<void> _sendLoad() async {
    final state = ref.read(contractProvider);
    if (!accepted || state.completed || hauling || secondsLeft <= 0) return;
    setState(() => hauling = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    ref.read(contractProvider.notifier).recordLoad();
    setState(() => hauling = false);
    final done = ref.read(contractProvider).completed;
    if (done) {
      await _grantReward();
    }
  }

  Future<void> _grantReward() async {
    if (rewarded) return;
    rewarded = true;
    _timer?.cancel();
    final c = kTutorialContract;
    await ref.read(economyProvider.notifier).addCash(c.rewardCash);
    await ref.read(reputationProvider.notifier).add(c.rewardReputation);
    if (mounted) setState(() {});
  }

  String get _timerLabel {
    final m = secondsLeft ~/ 60;
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final contract = ref.watch(contractProvider);
    final done = contract.completed;
    final timedOut = accepted && !done && secondsLeft <= 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (accepted)
                    Chip(
                      avatar: Icon(
                        done
                            ? Icons.check_circle
                            : timedOut
                            ? Icons.timer_off_outlined
                            : Icons.local_shipping,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        done
                            ? 'Contract done'
                            : '${kTutorialContract.districtName} '
                                  '${contract.loadsDone}/'
                                  '${kTutorialContract.loadsRequired}'
                                  ' · $_timerLabel',
                      ),
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      side: BorderSide.none,
                    ),
                  const Spacer(),
                  const MoneyHud(showReputation: true),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'District contract',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Truck auto-hauls. You run the yard.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            kTutorialContract.districtName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Deliver ${kTutorialContract.loadsRequired} loads '
                        'in ${kTutorialContract.timeLimitSeconds}s.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reward: \$${kTutorialContract.rewardCash} + '
                        '+${kTutorialContract.rewardReputation} rep',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      if (accepted && !done) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value:
                              contract.loadsDone /
                              kTutorialContract.loadsRequired,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.primary,
                          backgroundColor: AppColors.surfaceDark,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timedOut
                              ? 'Time’s up — send remaining loads anyway.'
                              : 'Load ready when you tap Send.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                      if (done) ...[
                        const SizedBox(height: 16),
                        Text(
                          '+\$${kTutorialContract.rewardCash}  ·  '
                          '+${kTutorialContract.rewardReputation} rep',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.money,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (!accepted)
                PrimaryCta(label: 'Accept', onPressed: _accept)
              else if (!done)
                PrimaryCta(
                  label: hauling ? 'Hauling…' : 'Send load',
                  onPressed: hauling ? null : _sendLoad,
                )
              else
                PrimaryCta(
                  label: 'Choose upgrade',
                  onPressed: widget.onContinue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
