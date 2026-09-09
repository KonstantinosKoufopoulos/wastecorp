import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

/// S4 — Lines open: metal + paper machines appear.
class S4LinesOpenScreen extends StatelessWidget {
  const S4LinesOpenScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

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
                'Lines open',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Metal crusher and paper baler join the plastic press.',
                style: TextStyle(color: AppColors.inkMuted),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _MachineCard(
                      color: AppColors.metal,
                      icon: Icons.hardware_outlined,
                      title: 'Metal',
                      subtitle: 'Crusher online',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MachineCard(
                      color: AppColors.paper,
                      icon: Icons.article_outlined,
                      title: 'Paper',
                      subtitle: 'Baler online',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MachineCard(
                color: AppColors.plastic,
                icon: Icons.precision_manufacturing_outlined,
                title: 'Plastic',
                subtitle: 'Press (already running)',
              ),
              const Spacer(),
              PrimaryCta(label: 'Check district contract', onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
