import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contracts/contracts.dart';
import '../../domain/economy/economy.dart';
import '../../domain/reputation/reputation.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

/// S5 — Contract: district card Accept + active chip.
class S5ContractScreen extends ConsumerStatefulWidget {
  const S5ContractScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S5ContractScreen> createState() => _S5ContractScreenState();
}

class _S5ContractScreenState extends ConsumerState<S5ContractScreen> {
  bool accepted = false;
  bool delivering = false;

  void _accept() {
    ref.read(contractProvider.notifier).accept(kTutorialContract);
    setState(() => accepted = true);
  }

  Future<void> _completeLoads() async {
    if (delivering) return;
    setState(() => delivering = true);
    final notifier = ref.read(contractProvider.notifier);
    for (var i = 0; i < kTutorialContract.loadsRequired; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      notifier.recordLoad();
    }
    final c = kTutorialContract;
    ref.read(economyProvider.notifier).addCash(c.rewardCash);
    ref.read(reputationProvider.notifier).add(c.rewardReputation);
    setState(() => delivering = false);
  }

  @override
  Widget build(BuildContext context) {
    final contract = ref.watch(contractProvider);
    final done = contract.completed;

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
                        done ? Icons.check_circle : Icons.local_shipping,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        done
                            ? 'Contract done'
                            : '${kTutorialContract.districtName} '
                                '${contract.loadsDone}/'
                                '${kTutorialContract.loadsRequired}',
                      ),
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
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
                          const Icon(Icons.map_outlined,
                              color: AppColors.primary),
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
                        'Deliver ${kTutorialContract.loadsRequired} loads.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reward: \$${kTutorialContract.rewardCash} + '
                        '${kTutorialContract.rewardReputation} reputation',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (!accepted)
                PrimaryCta(label: 'Accept', onPressed: _accept)
              else if (!done)
                PrimaryCta(
                  label: delivering ? 'Hauling…' : 'Run contract (stub)',
                  onPressed: delivering ? null : _completeLoads,
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
