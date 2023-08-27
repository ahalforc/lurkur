import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryCard extends StatelessWidget {
  const PrimaryCard({
    super.key,
    this.onPressed,
    this.onLongPressed,
    required this.child,
  });

  final void Function()? onPressed, onLongPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    final onLongPressed = this.onLongPressed;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed();
              }
            : null,
        onLongPress: onLongPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onLongPressed();
              }
            : null,
        child: child,
      ),
    );
  }
}
