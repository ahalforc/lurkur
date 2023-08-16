import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

class SplitIconButton extends StatelessWidget {
  const SplitIconButton({
    super.key,
    this.leftIcon,
    this.rightIcon,
    this.onLeftPressed,
    this.onRightPressed,
    required this.child,
  });

  final Widget? leftIcon, rightIcon;
  final void Function()? onLeftPressed, onRightPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final leftIcon = this.leftIcon, rightIcon = this.rightIcon;
    final onLeftPressed = this.onLeftPressed,
        onRightPressed = this.onRightPressed;
    void Function()? onCardPressed;
    if (onLeftPressed != null && onRightPressed == null) {
      onCardPressed = onLeftPressed;
    } else if (onLeftPressed == null && onRightPressed != null) {
      onCardPressed = onRightPressed;
    }
    return GestureDetector(
      onTap: onCardPressed,
      child: Card(
        color: context.colorScheme.secondaryContainer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon != null)
              IconButton(
                icon: leftIcon,
                onPressed: onLeftPressed,
              ),
            AnimatedDefaultTextStyle(
              duration: kThemeChangeDuration,
              style: context.textTheme.labelMedium!,
              child: child,
            ),
            if (rightIcon != null)
              IconButton(
                icon: rightIcon,
                onPressed: onRightPressed,
              )
            else
              const SizedBox(width: ThemeCubit.mediumPadding),
          ],
        ),
      ),
    );
  }
}
