import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

class NsfwTag extends StatelessWidget {
  const NsfwTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextTag(
      text: 'nsfw',
      color: context.colorScheme.primaryContainer,
    );
  }
}

class PinnedTag extends StatelessWidget {
  const PinnedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextTag(
      text: 'pinned',
      color: context.colorScheme.secondaryContainer,
    );
  }
}

class StickiedTag extends StatelessWidget {
  const StickiedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextTag(
      text: 'stickied',
      color: context.colorScheme.tertiaryContainer,
    );
  }
}

class SubmitterTag extends StatelessWidget {
  const SubmitterTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextTag(
      text: 'OP',
      color: context.colorScheme.primaryContainer,
    );
  }
}

class EditedTag extends StatelessWidget {
  const EditedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextTag(
      text: 'Edited',
      color: context.colorScheme.secondaryContainer,
    );
  }
}

class _TextTag extends StatelessWidget {
  const _TextTag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeCubit.medium1Padding,
        vertical: ThemeCubit.small2Padding,
      ),
      child: Text(text),
    );
  }
}
