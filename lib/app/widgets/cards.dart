import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed.call();
              }
            : null,
        child: child,
      ),
    );
  }
}
