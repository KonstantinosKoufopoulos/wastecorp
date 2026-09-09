import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../../domain/models/waste_material.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';
import '../yard/bin_placeholder.dart';
import '../yard/draggable_sort_item.dart';

/// S1 — Real drag-sort: 8 items, 72² / bin 120², juice + payouts, advance at 8.
class S1SortScreen extends ConsumerStatefulWidget {
  const S1SortScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S1SortScreen> createState() => _S1SortScreenState();
}

class _S1SortScreenState extends ConsumerState<S1SortScreen> {
  late List<SortItemData> pile;
  final Map<WasteMaterial, int> sorted = {
    WasteMaterial.plastic: 0,
    WasteMaterial.metal: 0,
    WasteMaterial.paper: 0,
  };
  String? lastPopLabel;
  WasteMaterial? lastCorrect;

  @override
  void initState() {
    super.initState();
    pile = buildTruckload(kS1ItemCount, prefix: 's1');
  }

  bool get _ready => pile.isEmpty;

  Future<void> _onAccept(SortItemData item) async {
    final payout = sortPayoutFor(item.material);
    setState(() {
      pile = pile.where((e) => e.id != item.id).toList();
      sorted[item.material] = (sorted[item.material] ?? 0) + 1;
      lastCorrect = item.material;
      lastPopLabel = '+\$$payout';
    });
    await ref.read(economyProvider.notifier).addCash(payout);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => lastPopLabel = null);
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
              const Align(alignment: Alignment.topRight, child: MoneyHud()),
              const SizedBox(height: 12),
              const Text(
                'Sort the dump',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pile.isNotEmpty
                    ? 'Drag each item into the matching bin (${pile.length} left)'
                    : 'Pile clear. Plastic ready for the press.',
                style: const TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.yardDirty.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.yardDirty,
                          width: 2,
                        ),
                      ),
                      child: pile.isEmpty
                          ? const Center(
                              child: Text(
                                'Empty',
                                style: TextStyle(
                                  color: AppColors.inkMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final item in pile)
                                    DraggableSortItem(item: item),
                                ],
                              ),
                            ),
                    ),
                    if (lastPopLabel != null)
                      Positioned(
                        top: 12,
                        child: Text(
                          lastPopLabel!,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BinPlaceholder(
                    type: WasteMaterial.plastic,
                    count: sorted[WasteMaterial.plastic]!,
                    highlighted: lastCorrect == WasteMaterial.plastic,
                    onAccept: _onAccept,
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.metal,
                    count: sorted[WasteMaterial.metal]!,
                    highlighted: lastCorrect == WasteMaterial.metal,
                    onAccept: _onAccept,
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.paper,
                    count: sorted[WasteMaterial.paper]!,
                    highlighted: lastCorrect == WasteMaterial.paper,
                    onAccept: _onAccept,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Wrong bin soft-bounces · correct pays '
                '\$$kSortPlasticPayout / \$$kSortMetalPayout / \$$kSortPaperPayout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.inkMuted.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
              PrimaryCta(
                label: _ready ? 'Open plastic press' : 'Keep sorting…',
                onPressed: _ready ? widget.onContinue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
