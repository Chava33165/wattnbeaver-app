import 'package:flutter/material.dart';
import '../theme/neu_glass.dart';

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? baseColor;

  const NeuButton({
    super.key,
    required this.child,
    this.onTap,
    this.radius = NeuGlass.radiusSmall,
    this.width,
    this.height,
    this.padding,
    this.baseColor,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap!();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: _isPressed
            ? NeuGlass.neuInset(context, radius: widget.radius, baseColor: widget.baseColor)
            : NeuGlass.neuRaised(context, radius: widget.radius, baseColor: widget.baseColor),
        child: Center(child: widget.child),
      ),
    );
  }
}
