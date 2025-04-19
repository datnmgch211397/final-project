import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
   LikeAnimation({
    Key? key,
    required this.child,
    required this.isAnimation,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.isLike = false,
  }) : super(key: key);
  final Widget child;
  final bool isAnimation;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool isLike;

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: widget.duration.inMicroseconds),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);
  }

  @override
  void didUpdateWidget(LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimation != oldWidget.isAnimation) {
      if (widget.isAnimation) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void startAnimation() async {
    if (widget.isAnimation || widget.isLike) {
      await _controller.forward();
      await _controller.reverse();
      await Future.delayed(const Duration(milliseconds: 150));
    }
    if (widget.onEnd != null) {
      widget.onEnd!();
    }
  }
@override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
