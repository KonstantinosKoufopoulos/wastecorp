import 'dart:async';
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

/// S4 — Metal+paper unlock · truckload #2 = 10 · ≥1 process each line.
class S4LinesOpenScreen extends ConsumerStatefulWidget {
  const S4LinesOpenScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S4LinesOpenScreen> createState() => _S4LinesOpenScreenState();
}

class _S4LinesOpenScreenState extends ConsumerState<S4LinesOpenScreen> {
  late List<SortItemData> pile;
  final Map<WasteMaterial, int> binCounts = {
    WasteMaterial.plastic: 0,
    WasteMaterial.metal: 0,
    WasteMaterial.paper: 0,
  };
  int metalProcessed = 0;
  int paperProcessed = 0;
  bool metalBusy = false;
  bool paperBusy = false;
  double metalProgress = 0;
  double paperProgress = 0;
  String? cashPop;

  @override
  void initState() {
    super.initState();
    pile = buildTruckload(kS4TruckloadItems, prefix: 's4');
    unawaited(StorageService.setLinesOpen(true));
  }

  bool get _ready => metalProcessed >= 1 && paperProcessed >= 1;

  Future<void> _onAccept(SortItemData item) async {
    final payout = sortPayoutFor(item.material);
    setState(() {
      pile = pile.where((e) => e.id != item.id).toList();
      binCounts[item.material] = (binCounts[item.material] ?? 0) + 1;
      cashPop = '+\$$payout';
    });
    await ref.read(economyProvider.notifier).addCash(payout);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => cashPop = null);
  }

  Future<void> _processMetal() async {
    if (metalBusy || binCounts[WasteMaterial.metal]! < 1) return;
    setState(() {
      metalBusy = true;
      metalProgress = 0;
    });
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(
        Duration(milliseconds: (kLineProcessSeconds * 1000 / steps).round()),
      );
      if (!mounted) return;
      setState(() => metalProgress = i / steps);
    }
    setState(() {
      binCounts[WasteMaterial.metal] = binCounts[WasteMaterial.metal]! - 1;
      metalProcessed++;
      metalBusy = false;
      cashPop = '+\$$kMetalProcessPayout';
    });
    await ref.read(economyProvider.notifier).addCash(kMetalProcessPayout);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => cashPop = null);
  }

  Future<void> _processPaper() async {
    if (paperBusy || binCounts[WasteMaterial.paper]! < 1) return;
    setState(() {
      paperBusy = true;
      paperProgress = 0;
    });
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(
        Duration(milliseconds: (kLineProcessSeconds * 1000 / steps).round()),
      );
      if (!mounted) return;
      setState(() => paperProgress = i / steps);
    }
    setState(() {
      binCounts[WasteMaterial.paper] = binCounts[WasteMaterial.paper]! - 1;
      paperProcessed++;
      paperBusy = false;
      cashPop = '+\$$kPaperProcessPayout';
    });
    await ref.read(economyProvider.notifier).addCash(kPaperProcessPayout);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => cashPop = null);
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
              const SizedBox(height: 8),
              const Text(
                'Lines open',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _ready
                    ? 'Metal & paper processed. Contract awaits.'
                    : 'Truckload #2 ($kS4TruckloadItems). Sort, then process metal & paper once each.',
                style: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _LineCard(
                      color: AppColors.metal,
                      icon: Icons.hardware_outlined,
                      title: 'Metal',
                      progress: metalBusy
                          ? metalProgress
                          : (metalProcessed > 0 ? 1 : 0),
                      busy: metalBusy,
                      canProcess:
                          !metalBusy &&
                          binCounts[WasteMaterial.metal]! >= 1 &&
                          metalProcessed < 1,
                      done: metalProcessed >= 1,
                      onProcess: _processMetal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LineCard(
                      color: AppColors.paper,
                      icon: Icons.article_outlined,
                      title: 'Paper',
                      progress: paperBusy
                          ? paperProgress
                          : (paperProcessed > 0 ? 1 : 0),
                      busy: paperBusy,
                      canProcess:
                          !paperBusy &&
                          binCounts[WasteMaterial.paper]! >= 1 &&
                          paperProcessed < 1,
                      done: paperProcessed >= 1,
                      onProcess: _processPaper,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.yardDirty.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.yardDirty,
                          width: 2,
                        ),
                      ),
                      child: pile.isEmpty
                          ? const Center(
                              child: Text(
                                'Truckload sorted',
                                style: TextStyle(
                                  color: AppColors.inkMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final item in pile)
                                    DraggableSortItem(item: item),
                                ],
                              ),
                            ),
                    ),
                    if (cashPop != null)
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            cashPop!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.money,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BinPlaceholder(
                    type: WasteMaterial.plastic,
                    count: binCounts[WasteMaterial.plastic]!,
                    workerIdle: true,
                    onAccept: _onAccept,
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.metal,
                    count: binCounts[WasteMaterial.metal]!,
                    onAccept: _onAccept,
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.paper,
                    count: binCounts[WasteMaterial.paper]!,
                    onAccept: _onAccept,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryCta(
                label: _ready
                    ? 'Check district contract'
                    : 'Process metal & paper…',
                onPressed: _ready ? widget.onContinue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.progress,
    required this.busy,
    required this.canProcess,
    required this.done,
    required this.onProcess,
  });

  final Color color;
  final IconData icon;
  final String title;
  final double progress;
  final bool busy;
  final bool canProcess;
  final bool done;
  final VoidCallback onProcess;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                const Spacer(),
                if (done)
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.money,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: color,
              backgroundColor: AppColors.surfaceDark,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: canProcess ? onProcess : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  busy
                      ? '…'
                      : done
                      ? 'Done'
                      : 'Process',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
