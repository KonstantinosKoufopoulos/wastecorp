import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/economy/economy.dart';
import '../../domain/reputation/reputation.dart';
import '../theme/app_theme.dart';

/// Minimal HUD: money | reputation.
class MoneyHud extends ConsumerWidget {
  const MoneyHud({super.key, this.showReputation = false});

  final bool showReputation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cash = ref.watch(economyProvider).cash;
    final rep = ref.watch(reputationProvider).points;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.payments_outlined, size: 18, color: AppColors.money),
          const SizedBox(width: 6),
          Text(
            '\$$cash',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.money,
            ),
          ),
          if (showReputation) ...[
            const SizedBox(width: 16),
            const Icon(Icons.star_outline, size: 18, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              '$rep',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
