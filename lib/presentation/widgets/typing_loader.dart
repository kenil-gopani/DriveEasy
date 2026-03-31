import 'dart:ui';
import 'package:flutter/material.dart';

class TypingLoader extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  
  const TypingLoader({
    super.key,
    this.color = Colors.white,
    this.shadowColor = Colors.black45, // Slightly darker to show up on the blue gradient
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 35,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dot 1
          Positioned(
            left: 60 * 0.15,
            child: _TypingDotGroup(delayMs: 0, color: color, shadowColor: shadowColor),
          ),
          // Dot 2
          Positioned(
            left: 60 * 0.45,
            child: _TypingDotGroup(delayMs: 200, color: color, shadowColor: shadowColor),
          ),
          // Dot 3
          Positioned(
            right: 60 * 0.15,
            child: _TypingDotGroup(delayMs: 300, color: color, shadowColor: shadowColor),
          ),
        ],
      ),
    );
  }
}

class _TypingDotGroup extends StatefulWidget {
  final int delayMs;
  final Color color;
  final Color shadowColor;

  const _TypingDotGroup({
    required this.delayMs,
    required this.color,
    required this.shadowColor,
  });

  @override
  State<_TypingDotGroup> createState() => _TypingDotGroupState();
}

class _TypingDotGroupState extends State<_TypingDotGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  // Dot Tweens
  late Animation<double> _topAnim;
  late Animation<double> _heightAnim;
  late Animation<double> _scaleXAnim;
  
  // Shadow Tweens
  late Animation<double> _shadowScaleXAnim;
  late Animation<double> _shadowOpacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    _topAnim = Tween<double>(begin: 20.0, end: 0.0).animate(curve);

    _heightAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 5.0, end: 8.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween<double>(8.0), weight: 60),
    ]).animate(curve);

    _scaleXAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.7, end: 1.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
    ]).animate(curve);

    _shadowScaleXAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.2), weight: 60),
    ]).animate(curve);

    _shadowOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.7), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.4), weight: 60),
    ]).animate(curve);

    if (widget.delayMs == 0) {
      _ctrl.repeat(reverse: true);
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // Optimizing out Opacity widget: directly manipulate alpha
        final int currentAlpha = (widget.shadowColor.alpha * _shadowOpacityAnim.value).round().clamp(0, 255);
        final Color currentShadowColor = widget.shadowColor.withAlpha(currentAlpha);

        return SizedBox(
          width: 8,
          height: 35, // Space for dot + shadow
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Shadow - optimized to use BoxShadow instead of ImageFilter
              Positioned(
                top: 30, // Shadow always rests at the bottom
                child: Transform.scale(
                  scaleX: _shadowScaleXAnim.value,
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 4,
                    decoration: BoxDecoration(
                      color: currentShadowColor,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: currentShadowColor,
                          blurRadius: 2, // Approximates blur without ImageFilter cost
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bouncing Dot
              Positioned(
                top: _topAnim.value,
                child: Transform.scale(
                  scaleX: _scaleXAnim.value,
                  alignment: Alignment.center,
                  child: Container(
                    width: 8,
                    height: _heightAnim.value,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(50), // Removed heavy conditional radius
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
