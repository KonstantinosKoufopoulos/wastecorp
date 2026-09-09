import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage_service.dart';
import 's0_splash_yard.dart';
import 's1_sort.dart';
import 's2_plastic_press.dart';
import 's3_hire.dart';
import 's4_lines_open.dart';
import 's5_contract.dart';
import 's6_upgrade_choice.dart';
import '../theme/app_theme.dart';

/// First-5-min navigation flow (Christos wireframes S0–S6).
class TutorialShell extends ConsumerStatefulWidget {
  const TutorialShell({super.key});

  @override
  ConsumerState<TutorialShell> createState() => _TutorialShellState();
}

class _TutorialShellState extends ConsumerState<TutorialShell> {
  int? step; // null until Hive load

  @override
  void initState() {
    super.initState();
    final saved = StorageService.getTutorialStep();
    step = saved.clamp(0, 7);
  }

  Future<void> _go(int next) async {
    await StorageService.setTutorialStep(next);
    if (!mounted) return;
    setState(() => step = next);
  }

  @override
  Widget build(BuildContext context) {
    final s = step;
    if (s == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return switch (s) {
      0 => S0SplashYardScreen(onStart: () => _go(1)),
      1 => S1SortScreen(onContinue: () => _go(2)),
      2 => S2PlasticPressScreen(onContinue: () => _go(3)),
      3 => S3HireScreen(onContinue: () => _go(4)),
      4 => S4LinesOpenScreen(onContinue: () => _go(5)),
      5 => S5ContractScreen(onContinue: () => _go(6)),
      6 => S6UpgradeChoiceScreen(onDone: () => _go(7)),
      _ => const _TutorialCompleteScreen(),
    };
  }
}

class _TutorialCompleteScreen extends StatelessWidget {
  const _TutorialCompleteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.factory_outlined,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Tutorial complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sprint 1 shell ends here. Next district needs more reputation — build the company.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Gate: no Pages ship without Carolos playtest PASS.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.inkMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
