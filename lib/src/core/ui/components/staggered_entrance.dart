import 'package:flutter/material.dart';

class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 500),
  });

  final List<Widget> children;
  final Duration delay;
  final Duration duration;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(widget.children.length, (index) {
        final start = (index * widget.delay.inMilliseconds) /
            (widget.duration.inMilliseconds +
                widget.children.length * widget.delay.inMilliseconds);
        final end = start +
            (widget.duration.inMilliseconds /
                (widget.duration.inMilliseconds +
                    widget.children.length * widget.delay.inMilliseconds));

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}
