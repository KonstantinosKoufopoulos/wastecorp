import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../../domain/models/waste_material.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';
import '../yard/bin_placeholder.dart';
import '../yard/draggable_sort_item.dart';

/// S3 — Hire \$40 · 1 CTA · worker idle at plastic · player still sorts.
class S3HireScreen extends ConsumerStatefulWidget {
  const S3HireScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S3HireScreen> createState() => _S3HireScreenState();
}

class _S3HireScreenState extends ConsumerState<S3HireScreen> {
  bool hired = false;
  late List<SortItemData> helpPile;
  final Map<WasteMaterial, int> sorted = {
    WasteMaterial.plastic: 0,
    WasteMaterial.metal: 0,
    WasteMaterial.paper: 0,
  };

  @override
  void initState() {
    super.initState();
    hired = StorageService.getHasWorker();
    // Small leftover pile so player can still sort after hire.
    helpPile = buildTruckload(3, prefix: 's3');
  }

  Future<void> _hire() async {
    final ok = await ref.read(economyProvider.notifier).spend(kWorkerHireCost);
    if (!ok || !mounted) return;
    await StorageService.setHasWorker(true);
    setState(() => hired = true);
  }

  Future<void> _onAccept(SortItemData item) async {
    final payout = sortPayoutFor(item.material);
    setState(() {
      helpPile = helpPile.where((e) => e.id != item.id).toList();
      sorted[item.material] = (sorted[item.material] ?? 0) + 1;
    });
    await ref.read(economyProvider.notifier).addCash(payout);
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
              const Align(alignment: Alignment.topRight, child: MoneyHud()),
              const SizedBox(height: 12),
              Text(
                hired ? 'Worker on plastic' : 'Hire help',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hired
                    ? 'Worker idles at plastic. You can still sort.'
                    : 'A worker sorts while you run the press. You can still help.',
                style: const TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 16),
              if (!hired) ...[
                const Spacer(),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(
                            Icons.engineering_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Yard sorter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Stations at the plastic bin. You keep sorting too.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.inkMuted),
                        ),
                        const SizedBox(height: 16),
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
                PrimaryCta(
                  label: canAfford ? 'Hire' : 'Need \$$kWorkerHireCost',
                  onPressed: canAfford ? _hire : null,
                ),
              ] else ...[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.yardDirty.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.yardDirty, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: helpPile.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Help pile clear — nice.',
                                      style: TextStyle(
                                        color: AppColors.inkMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (final item in helpPile)
                                        DraggableSortItem(item: item),
                                    ],
                                  ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              BinPlaceholder(
                                type: WasteMaterial.plastic,
                                count: sorted[WasteMaterial.plastic]!,
                                workerIdle: true,
                                onAccept: _onAccept,
                              ),
                              BinPlaceholder(
                                type: WasteMaterial.metal,
                                count: sorted[WasteMaterial.metal]!,
                                onAccept: _onAccept,
                              ),
                              BinPlaceholder(
                                type: WasteMaterial.paper,
                                count: sorted[WasteMaterial.paper]!,
                                onAccept: _onAccept,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryCta(
                  label: 'Open more lines',
                  onPressed: widget.onContinue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
