import 'package:flutter/material.dart';

import '../../domain/models/waste_material.dart';
import '../theme/app_theme.dart';

Color colorForMaterial(WasteMaterial type) => switch (type) {
      WasteMaterial.plastic => AppColors.plastic,
      WasteMaterial.metal => AppColors.metal,
      WasteMaterial.paper => AppColors.paper,
      WasteMaterial.mixed => AppColors.yardDirty,
    };

/// Visual bin stub for plastic (blue) / metal (grey) / paper (brown).
class BinPlaceholder extends StatelessWidget {
  const BinPlaceholder({
    super.key,
    required this.type,
    this.count = 0,
    this.onTap,
    this.highlighted = false,
  });

  final WasteMaterial type;
  final int count;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = colorForMaterial(type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 88,
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlighted ? color : color.withValues(alpha: 0.6),
            width: highlighted ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
