import 'package:flutter/material.dart';

class BlinkingCursor extends StatefulWidget {
  final Color color;
  final bool visible;

  const BlinkingCursor({Key? key, required this.color, required this.visible})
      : super(key: key);

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.visible) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.visible && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: widget.color,
      ),
    );
  }
}
