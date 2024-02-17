import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// It's like a regular box, but it's *liquid*.
///
/// I don't really know why I made this but it's neat.
class LiquidBox extends StatefulWidget {
  const LiquidBox({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<LiquidBox> createState() => _LiquidBoxState();
}

class _LiquidBoxState extends State<LiquidBox> {
  final _springs = List.generate(6, (_) => _Spring());

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
      )
          .animate(
            onComplete: (c) => c.loop(),
          )
          .custom(
            duration: 3.seconds,
            builder: (context, value, child) {
              _update();
              return CustomPaint(
                painter: _LiquidPainter(
                  springs: _springs.map((e) => e._position).toList(),
                ),
                child: child,
              );
            },
          ),
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    final pos = event.localPosition.dx / 436;
    final index = (_springs.length * pos).round().clamp(0, _springs.length - 1);
    _springs[index].push();
  }

  void _update() {
    for (final spring in _springs) {
      spring.update();
    }
    for (var i = 1; i < _springs.length - 1; i++) {
      _springs[i].dampen(
        _springs[i - 1],
        _springs[i + 1],
      );
    }
    for (final spring in _springs) {
      spring.settle();
    }
  }
}

class _LiquidPainter extends CustomPainter {
  const _LiquidPainter({
    required this.springs,
  });

  final List<double> springs;

  @override
  void paint(Canvas canvas, Size size) {
    (double x, double y) springOffset(int i) {
      return (
        (i / (springs.length - 1)) * size.width,
        size.height * springs[i] - size.height,
      );
    }

    final path = Path();
    for (var i = 0; i < springs.length; i++) {
      final (x, y) = springOffset(i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prev = springOffset(i - 1);
        if (i % 2 == 1) {
          path.cubicTo(
            (x + prev.$1) / 2,
            prev.$2,
            (x + prev.$1) / 2,
            y,
            x,
            y,
          );
        } else {
          path.cubicTo(
            (x + prev.$1) / 2,
            prev.$2,
            (x + prev.$1) / 2,
            y,
            x,
            y,
          );
        }
      }
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Spring {
  static const target = 1.0;

  var _position = target;
  late var _pendingPosition = _position;
  var _velocity = 0.0;

  void push() {
    _velocity -= 0.002;
    _velocity.clamp(-0.006, 0.006);
  }

  void update() {
    // This constant is the stiffness of the spring.
    // This basically controls how fast it bounces.
    const k = 0.0025;

    // Adjust this spring's relative position based on its velocity.
    _position += _velocity;

    // Adjust this spring's velocity based on its target position and stiffness.
    _velocity += (-k * (_position - target));

    // Dampen this spring's velocity artificially for UX reasons.
    // Yes, 0.96 is a *magic* number.
    _velocity *= 0.96;
    if (_velocity.abs() < 0.00001) _velocity = 0;
  }

  void dampen(_Spring left, _Spring right) {
    const spread = 0.005;

    _pendingPosition = _position +
        spread * (_position - left._position) +
        spread * (_position - right._position);
  }

  void settle() {
    _position = _pendingPosition;
  }
}
