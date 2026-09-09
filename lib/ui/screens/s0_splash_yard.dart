import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/primary_cta.dart';

/// S0 — Splash / dirty yard: one-liner + CTA Start.
class S0SplashYardScreen extends StatelessWidget {
  const S0SplashYardScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.yardDirty.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yardDirty, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 56,
                      color: AppColors.inkMuted,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'One truck. A messy yard.',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Waste Corp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sort. Process. Build the company.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryCta(label: 'Start', onPressed: onStart),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
