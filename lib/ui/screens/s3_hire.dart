import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

/// S3 — Hire: Worker \$X card + Hire CTA.
class S3HireScreen extends ConsumerStatefulWidget {
  const S3HireScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S3HireScreen> createState() => _S3HireScreenState();
}

class _S3HireScreenState extends ConsumerState<S3HireScreen> {
  bool hired = false;

  void _hire() {
    final ok = ref.read(economyProvider.notifier).spend(kWorkerHireCost);
    if (!ok) return;
    setState(() => hired = true);
  }

  @override
  Widget build(BuildContext context) {
    final cash = ref.watch(economyProvider).cash;
    final canAfford = cash >= kWorkerHireCost;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: MoneyHud(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hire help',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'A worker sorts while you run the press. You can still help.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        child: Icon(
                          hired ? Icons.check : Icons.engineering_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hired ? 'Worker hired' : 'Yard sorter',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hired
                            ? 'They’ll keep the bins moving.'
                            : 'Auto-sorts dump piles slowly.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 16),
                      if (!hired)
                        Text(
                          '\$$kWorkerHireCost',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: canAfford
                                ? AppColors.money
                                : AppColors.dangerSoft,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (!hired)
                PrimaryCta(
                  label: canAfford ? 'Hire' : 'Need \$$kWorkerHireCost',
                  onPressed: canAfford ? _hire : null,
                )
              else
                PrimaryCta(
                  label: 'Open more lines',
                  onPressed: widget.onContinue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
