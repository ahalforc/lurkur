import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NsfwTag extends StatelessWidget {
  const NsfwTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'nsfw',
      animationColor: context.colorScheme.nsfwPrimaryColor,
    );
  }
}

class PinnedTag extends StatelessWidget {
  const PinnedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'pinned',
      animationColor: context.colorScheme.pinnedPrimaryColor,
    );
  }
}

class StickiedTag extends StatelessWidget {
  const StickiedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'stickied',
      animationColor: context.colorScheme.stickiedPrimaryColor,
    );
  }
}

class SubmitterTag extends StatelessWidget {
  const SubmitterTag({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Tag(
      text: 'OP',
    );
  }
}

class EditedTag extends StatelessWidget {
  const EditedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Tag(
      text: 'Edited',
    );
  }
}

class ScoreTag extends StatelessWidget {
  const ScoreTag({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    final isPositive = score >= 0;
    return _Tag(
      icon: isPositive ? Icons.thumb_up : Icons.thumb_down,
      text: '${isPositive ? '' : ''}${score.shorthand}',
    );
  }
}

class CommentsTag extends StatelessWidget {
  const CommentsTag({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return _Tag(
      icon: Icons.comment,
      text: count.shorthand,
    );
  }
}

class CreatedTag extends StatelessWidget {
  const CreatedTag({
    super.key,
    required this.createdTime,
  });

  final DateTime createdTime;

  @override
  Widget build(BuildContext context) {
    return _Tag(
      icon: Icons.create,
      text: timeago.format(createdTime, locale: 'en_short'),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    this.icon,
    required this.text,
    this.animationColor,
  });

  final IconData? icon;
  final String text;
  final Color? animationColor;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final animationColor = this.animationColor;
    return Animate(
      onComplete: animationColor != null ? (c) => c.loop() : null,
      effects: animationColor != null
          ? [
              ShimmerEffect(
                duration: 5.seconds,
                color: animationColor,
              ),
            ]
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                icon,
                size: 10,
                color: context.colorScheme.onSurface,
                applyTextScaling: true,
              ),
            ),
            LurkurSpacing.spacing4.horizontalGap,
          ],
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(),
          ),
        ],
      ),
    );
  }
}

extension on int {
  String get shorthand {
    final i = abs();
    if (1000 <= i && i < 1000000) {
      return '${i ~/ 1000}k';
    }
    return toString();
  }
}
