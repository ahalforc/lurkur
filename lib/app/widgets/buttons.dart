import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.onPressed,
    this.onLongPressed,
    required this.icon,
    required this.label,
  });

  final void Function()? onPressed, onLongPressed;
  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    final onLongPressed = this.onLongPressed;
    return TextButton(
      onPressed: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed();
            }
          : null,
      onLongPress: onLongPressed != null
          ? () {
              HapticFeedback.heavyImpact();
              onLongPressed();
            }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: ThemeCubit.mediumPadding),
          AnimatedDefaultTextStyle(
            duration: kThemeChangeDuration,
            style: context.textTheme.labelMedium!,
            child: label,
          ),
        ],
      ),
    );
  }
}
