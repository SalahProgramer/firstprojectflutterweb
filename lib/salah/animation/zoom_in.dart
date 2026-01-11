import 'package:flutter/material.dart';

class ZoomIn extends StatefulWidget {
  const ZoomIn({super.key, required this.base, required this.child});

  final double base;
  final Widget child;

  @override
  State<ZoomIn> createState() => ZoomInState();
}

class ZoomInState extends State<ZoomIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420),
    );
    _s = Tween(
      begin: 1.35,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_c);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (_, child) {
        final size = widget.base * _s.value;
        return SizedBox(width: size, height: size, child: child);
      },
      child: widget.child,
    );
  }
}
