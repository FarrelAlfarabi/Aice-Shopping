import 'dart:async';
import 'package:flutter/material.dart' hide Text;

/// Turn off looping animations (floating photos, slow zoom). Tests set this to
/// false so `pumpAndSettle` can finish. The app also skips loops when the
/// phone asks for reduced motion.
bool loopMotion = true;

bool motionOn(BuildContext context) =>
    loopMotion && !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

/// Shrinks a little while pressed and springs back, so image buttons feel
/// alive under the finger (Astro style). Wraps any child.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  const Pressable(
      {super.key,
      required this.child,
      this.onTap,
      this.scale = 0.95,
      this.semanticLabel});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool down = false;
  void _set(bool v) {
    if (down != v) setState(() => down = v);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _set(true),
          onTapCancel: () => _set(false),
          onTapUp: (_) => _set(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: down ? widget.scale : 1,
            duration: Duration(milliseconds: down ? 90 : 260),
            curve: down ? Curves.easeOut : Curves.elasticOut,
            child: widget.child,
          ),
        ),
      );
}

/// Fades and slides a section up into place once, after [delay]. Used to
/// stagger the Home sections on first open.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> a =
      CurvedAnimation(parent: c, curve: Curves.easeOutCubic);

  Timer? t;

  @override
  void initState() {
    super.initState();
    t = Timer(Duration(milliseconds: 40 + widget.index * 60), () {
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    t?.cancel();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: a,
        child: widget.child,
        builder: (_, child) => Opacity(
          opacity: a.value,
          child: Transform.translate(
              offset: Offset(0, 18 * (1 - a.value)), child: child),
        ),
      );
}

/// Gently floats its child up and down, with a slight zoom. Makes the photo
/// on a banner or tile feel alive without moving the layout.
class Float extends StatefulWidget {
  final Widget child;
  final double dy;
  final double zoom;
  final Duration period;
  const Float(
      {super.key,
      required this.child,
      this.dy = 5,
      this.zoom = 0.04,
      this.period = const Duration(milliseconds: 2600)});

  @override
  State<Float> createState() => _FloatState();
}

class _FloatState extends State<Float> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionOn(context)) {
      if (!c.isAnimating) c.repeat(reverse: true);
    } else {
      c.stop();
    }
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        child: widget.child,
        builder: (_, child) {
          final t = Curves.easeInOut.transform(c.value);
          return Transform.translate(
            offset: Offset(0, -widget.dy * t),
            child: Transform.scale(scale: 1 + widget.zoom * t, child: child),
          );
        },
      );
}

/// Pops its child (a badge) every time [trigger] changes.
class Bump extends StatelessWidget {
  final Object trigger;
  final Widget child;
  const Bump({super.key, required this.trigger, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(trigger),
        tween: Tween(begin: 1.35, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        builder: (_, s, c) => Transform.scale(scale: s, child: c),
        child: child,
      );
}
