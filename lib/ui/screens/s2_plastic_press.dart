import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

/// S2 — Plastic press: Process button + progress + cash pop stub.
class S2PlasticPressScreen extends ConsumerStatefulWidget {
  const S2PlasticPressScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S2PlasticPressScreen> createState() =>
      _S2PlasticPressScreenState();
}

class _S2PlasticPressScreenState extends ConsumerState<S2PlasticPressScreen> {
  double progress = 0;
  bool processing = false;
  bool done = false;
  int? cashPop;

  Future<void> _process() async {
    if (processing || done) return;
    setState(() {
      processing = true;
      progress = 0;
      cashPop = null;
    });
    const steps = 20;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      setState(() => progress = i / steps);
    }
    ref.read(economyProvider.notifier).addCash(kPlasticPressPayout);
    setState(() {
      processing = false;
      done = true;
      cashPop = kPlasticPressPayout;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                'Plastic press',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Process sorted plastic into bales → cash.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.plastic.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.plastic, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.precision_manufacturing_outlined,
                              size: 56, color: AppColors.plastic),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: AppColors.plastic,
                              backgroundColor: AppColors.surfaceDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cashPop != null)
                      Positioned(
                        top: 8,
                        child: Text(
                          '+\$$cashPop',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.money,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              if (!done)
                PrimaryCta(
                  label: processing ? 'Processing…' : 'Process',
                  onPressed: processing ? null : _process,
                )
              else
                PrimaryCta(
                  label: 'Continue',
                  onPressed: widget.onContinue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
