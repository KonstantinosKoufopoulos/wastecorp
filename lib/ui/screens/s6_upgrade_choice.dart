import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/money_hud.dart';
import '../widgets/primary_cta.dart';

enum UpgradePick { truck, yard }

/// S6 — Upgrade choice: Truck | Yard forced pick + dismissable offline banner.
class S6UpgradeChoiceScreen extends StatefulWidget {
  const S6UpgradeChoiceScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<S6UpgradeChoiceScreen> createState() => _S6UpgradeChoiceScreenState();
}

class _S6UpgradeChoiceScreenState extends State<S6UpgradeChoiceScreen> {
  UpgradePick? pick;
  bool showOfflineBanner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (showOfflineBanner)
              Material(
                color: AppColors.accent.withValues(alpha: 0.25),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.cloud_off_outlined,
                      color: AppColors.ink),
                  title: const Text(
                    'Offline progress unlocks after this — come back bigger.',
                    style: TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () =>
                        setState(() => showOfflineBanner = false),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: MoneyHud(showReputation: true),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Grow the company',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pick one upgrade. Next district needs a bit more reputation.',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceCard(
                            selected: pick == UpgradePick.truck,
                            icon: Icons.local_shipping_outlined,
                            title: 'Truck',
                            subtitle: 'Faster hauls',
                            onTap: () =>
                                setState(() => pick = UpgradePick.truck),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ChoiceCard(
                            selected: pick == UpgradePick.yard,
                            icon: Icons.warehouse_outlined,
                            title: 'Yard',
                            subtitle: 'More capacity',
                            onTap: () =>
                                setState(() => pick = UpgradePick.yard),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PrimaryCta(
                      label: pick == null
                          ? 'Choose truck or yard'
                          : 'Build the company',
                      onPressed: pick == null ? null : widget.onDone,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceDark,
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
