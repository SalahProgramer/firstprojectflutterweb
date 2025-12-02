import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class AnimateSwipeItems extends StatefulWidget {
  final ScrollController scrollController;
  final bool doSwipeAuto;
  final Widget customWidget;

  const AnimateSwipeItems(
      {super.key,
      required this.scrollController,
      required this.doSwipeAuto,
      required this.customWidget});

  @override
  State<AnimateSwipeItems> createState() => _AnimateSwipeItemsState();
}

class _AnimateSwipeItemsState extends State<AnimateSwipeItems> {
  bool userInteracting = false;
  Timer? _autoScrollTimer;
  bool _pendingResume = false;
  bool _tickerEnabled = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.of(context);
    if (_tickerEnabled != enabled) {
      setState(() {
        _tickerEnabled = enabled;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void didUpdateWidget(covariant AnimateSwipeItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doSwipeAuto != widget.doSwipeAuto ||
        oldWidget.scrollController != widget.scrollController) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    if (!widget.doSwipeAuto || !mounted) return;

    const double speed = 1; // pixels per tick
    const frameDelay = Duration(milliseconds: 16);

    _autoScrollTimer = Timer.periodic(frameDelay, (_) {
      if (!mounted ||
          !_canAutoScroll() ||
          !widget.scrollController.hasClients ||
          widget.scrollController.position.maxScrollExtent <= 0) {
        return;
      }

      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final current = widget.scrollController.offset;
      double next = current + speed;

      if (next >= maxScroll) {
        next = 0;
      }

      try {
        widget.scrollController.jumpTo(next);
      } catch (_) {
        // ignore jump errors when controller is detaching/attaching
      }
    });
  }

  bool _canAutoScroll() => !userInteracting && !_pendingResume && _tickerEnabled;

  void _setUserInteracting(bool value) {
    if (value) {
      _pendingResume = false;
    }
    if (userInteracting == value) return;
    userInteracting = value;
    if (!value) {
      _resumeAutoScrollWithDelay();
    }
  }

  void _resumeAutoScrollWithDelay() {
    _pendingResume = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (userInteracting) {
        _pendingResume = false;
        return;
      }
      _pendingResume = false;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setUserInteracting(true),
      onPointerUp: (_) => _setUserInteracting(false),
      onPointerCancel: (_) => _setUserInteracting(false),
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction != ScrollDirection.idle) {
            _setUserInteracting(true);
          } else {
            _setUserInteracting(false);
          }
          return false;
        },
        child: widget.customWidget,
      ),
    );
  }
}
