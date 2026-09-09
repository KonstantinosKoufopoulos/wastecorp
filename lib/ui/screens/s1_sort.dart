import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../../domain/models/waste_material.dart';
import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';
import '../yard/bin_placeholder.dart';

/// S1 — Sort: dump pile, 3 bins, tap-to-sort placeholder, money HUD.
class S1SortScreen extends ConsumerStatefulWidget {
  const S1SortScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<S1SortScreen> createState() => _S1SortScreenState();
}

class _S1SortScreenState extends ConsumerState<S1SortScreen> {
  int pileLeft = 6;
  final Map<WasteMaterial, int> sorted = {
    WasteMaterial.plastic: 0,
    WasteMaterial.metal: 0,
    WasteMaterial.paper: 0,
  };

  /// Cycle target for tap-to-sort placeholder (drag-ish later).
  WasteMaterial _nextTarget = WasteMaterial.plastic;

  void _tapSort(WasteMaterial bin) {
    if (pileLeft <= 0) return;
    // Forgiving: any tap sorts into that bin for the stub.
    setState(() {
      pileLeft--;
      sorted[bin] = (sorted[bin] ?? 0) + 1;
      _nextTarget = switch (bin) {
        WasteMaterial.plastic => WasteMaterial.metal,
        WasteMaterial.metal => WasteMaterial.paper,
        _ => WasteMaterial.plastic,
      };
    });
    // Small cash tease for correct-feeling feedback (tutorial juice).
    if (bin == WasteMaterial.plastic ||
        bin == WasteMaterial.metal ||
        bin == WasteMaterial.paper) {
      ref.read(economyProvider.notifier).addCash(2);
    }
  }

  bool get _ready => pileLeft == 0;

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
                'Sort the dump',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pileLeft > 0
                    ? 'Tap a bin to sort ($pileLeft left) — drag later'
                    : 'Pile clear. Plastic ready for the press.',
                style: const TextStyle(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
              // Dump pile
              Expanded(
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.yardDirty.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.yardDirty,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: pileLeft > 0
                              ? AppColors.ink
                              : AppColors.inkMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pileLeft > 0 ? 'Dump pile' : 'Empty',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '×$pileLeft',
                          style: const TextStyle(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Three bins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BinPlaceholder(
                    type: WasteMaterial.plastic,
                    count: sorted[WasteMaterial.plastic]!,
                    highlighted: _nextTarget == WasteMaterial.plastic,
                    onTap: () => _tapSort(WasteMaterial.plastic),
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.metal,
                    count: sorted[WasteMaterial.metal]!,
                    highlighted: _nextTarget == WasteMaterial.metal,
                    onTap: () => _tapSort(WasteMaterial.metal),
                  ),
                  BinPlaceholder(
                    type: WasteMaterial.paper,
                    count: sorted[WasteMaterial.paper]!,
                    highlighted: _nextTarget == WasteMaterial.paper,
                    onTap: () => _tapSort(WasteMaterial.paper),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
