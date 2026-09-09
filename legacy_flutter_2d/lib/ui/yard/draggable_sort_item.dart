import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/economy/economy.dart';
import '../../domain/models/waste_material.dart';
import 'bin_placeholder.dart';

/// 72² draggable waste item with correct-scale / wrong-bounce+shake juice.
class DraggableSortItem extends StatefulWidget {
  const DraggableSortItem({
    super.key,
    required this.item,
    this.enabled = true,
    this.onRejected,
  });

  final SortItemData item;
  final bool enabled;
  final VoidCallback? onRejected;

  @override
  State<DraggableSortItem> createState() => _DraggableSortItemState();
}

class _DraggableSortItemState extends State<DraggableSortItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _feedback;
  late Animation<double> _shake;
  late Animation<double> _scale;
  bool _wasAccepted = false;

  @override
  void initState() {
    super.initState();
    _feedback = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kWrongBounceMs),
    );
    _shake = Tween<double>(begin: 0, end: 0).animate(_feedback);
    _scale = Tween<double>(begin: 1, end: 1).animate(_feedback);
  }

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _playWrong() async {
    _shake = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: kWrongShakeDeg * math.pi / 180),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: kWrongShakeDeg * math.pi / 180,
          end: -kWrongShakeDeg * math.pi / 180,
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -kWrongShakeDeg * math.pi / 180, end: 0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _feedback, curve: Curves.easeOut));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 1),
    ]).animate(_feedback);
    _feedback.duration = const Duration(milliseconds: kWrongBounceMs);
    await _feedback.forward(from: 0);
    widget.onRejected?.call();
  }

  Future<void> _playCorrect() async {
    _wasAccepted = true;
    _shake = AlwaysStoppedAnimation(0);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: kCorrectScalePop),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: kCorrectScalePop, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _feedback, curve: Curves.easeOut));
    _feedback.duration = const Duration(milliseconds: 160);
    await _feedback.forward(from: 0);
  }

  Widget _chip({double opacity = 1}) {
    final color = colorForMaterial(widget.item.material);
    return AnimatedBuilder(
      animation: _feedback,
      builder: (context, child) {
        return Transform.rotate(
          angle: _shake.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: kSortItemSize,
          height: kSortItemSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconForMaterial(widget.item.material),
                color: Colors.white,
                size: 28,
              ),
              Text(
                widget.item.material.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _chip(opacity: 0.45);
    }

    return Draggable<SortItemData>(
      data: widget.item,
      maxSimultaneousDrags: 1,
      feedback: Material(color: Colors.transparent, child: _chip()),
      childWhenDragging: _chip(opacity: 0.25),
      onDragEnd: (details) {
        if (_wasAccepted) return;
        if (!details.wasAccepted) {
          _playWrong();
        }
      },
      onDragCompleted: () {
        _playCorrect();
      },
      child: _chip(),
    );
  }
}

/// Ghost outline hint near the correct bin (snap cue within [kSnapDistance]).
class SnapGhost extends StatelessWidget {
  const SnapGhost({super.key, required this.material});

  final WasteMaterial material;

  @override
  Widget build(BuildContext context) {
    final color = colorForMaterial(material);
    return IgnorePointer(
      child: Container(
        width: kSortItemSize,
        height: kSortItemSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
      ),
    );
  }
}
