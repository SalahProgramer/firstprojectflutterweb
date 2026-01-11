import 'package:flutter/material.dart';

class SnackBarCard extends StatelessWidget {
  const SnackBarCard({
    super.key,
    required this.child,
    this.radius = 20,
    required this.fillGradient,
    required this.borderGradient,
  });

  final Widget child;
  final double radius;
  final List<Color> fillGradient;
  final List<Color> borderGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: fillGradient),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: 2, color: borderGradient.first),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
