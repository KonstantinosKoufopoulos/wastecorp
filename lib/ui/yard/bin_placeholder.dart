import 'package:flutter/material.dart';

import '../../domain/economy/economy.dart';
import '../../domain/models/waste_material.dart';
import '../theme/app_theme.dart';

Color colorForMaterial(WasteMaterial type) => switch (type) {
  WasteMaterial.plastic => AppColors.plastic,
  WasteMaterial.metal => AppColors.metal,
  WasteMaterial.paper => AppColors.paper,
  WasteMaterial.mixed => AppColors.yardDirty,
};

IconData iconForMaterial(WasteMaterial type) => switch (type) {
  WasteMaterial.plastic => Icons.water_drop_outlined,
  WasteMaterial.metal => Icons.hardware_outlined,
  WasteMaterial.paper => Icons.article_outlined,
  WasteMaterial.mixed => Icons.inventory_2_outlined,
};

/// Bin with locked 120² hit target — wraps [DragTarget] for sort drops.
class BinPlaceholder extends StatelessWidget {
  const BinPlaceholder({
    super.key,
    required this.type,
    this.count = 0,
    this.onTap,
    this.highlighted = false,
    this.accepting = false,
    this.workerIdle = false,
    this.onAccept,
  });

  final WasteMaterial type;
  final int count;
  final VoidCallback? onTap;
  final bool highlighted;
  final bool accepting;
  final bool workerIdle;
  final void Function(SortItemData item)? onAccept;

  Widget _visual({required bool lit, required bool hot}) {
    final color = colorForMaterial(type);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: kBinHitSize,
      height: kBinHitSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: hot ? 0.4 : 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (lit || hot) ? color : color.withValues(alpha: 0.6),
          width: (lit || hot) ? 3 : 2,
        ),
        boxShadow: hot
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: color, size: 36),
              const SizedBox(height: 4),
              Text(
                type.label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text('$count', style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          if (workerIdle)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.engineering,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onAccept != null) {
      return DragTarget<SortItemData>(
        onWillAcceptWithDetails: (details) => details.data.material == type,
        onAcceptWithDetails: (details) => onAccept!(details.data),
        builder: (context, candidate, rejected) {
          final hovering = candidate.isNotEmpty;
          return AnimatedScale(
            scale: hovering ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: _visual(lit: highlighted || hovering, hot: hovering),
          );
        },
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _visual(lit: highlighted, hot: accepting),
    );
  }
}
