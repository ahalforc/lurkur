import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NsfwTag extends StatelessWidget {
  const NsfwTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'nsfw',
      color: context.colorScheme.primaryContainer,
    );
  }
}

class PinnedTag extends StatelessWidget {
  const PinnedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'pinned',
      color: context.colorScheme.secondaryContainer,
    );
  }
}

class StickiedTag extends StatelessWidget {
  const StickiedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'stickied',
      color: context.colorScheme.tertiaryContainer,
    );
  }
}

class SubmitterTag extends StatelessWidget {
  const SubmitterTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'OP',
      color: context.colorScheme.primaryContainer,
    );
  }
}

class EditedTag extends StatelessWidget {
  const EditedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      text: 'Edited',
      color: context.colorScheme.secondaryContainer,
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
      color: isPositive
          ? context.colorScheme.primaryContainer
          : context.colorScheme.error,
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
      color: context.colorScheme.secondaryContainer,
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
      color: context.colorScheme.tertiaryContainer,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    this.icon,
    required this.text,
    required this.color,
  });

  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeCubit.medium1Padding,
        vertical: ThemeCubit.small2Padding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              // [color] can be many things, so onSurface is just a "safe" choice
              color: context.colorScheme.onSurface,
            ),
            const SizedBox(width: ThemeCubit.medium1Padding),
          ],
          Text(text),
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
