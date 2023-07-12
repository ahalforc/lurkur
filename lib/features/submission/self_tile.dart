import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';

class SelfTile extends StatelessWidget {
  const SelfTile({
    super.key,
    required this.self,
  });

  final SelfSubmission self;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.text_snippet),
      title: const Text('self text'),
      initiallyExpanded: true,
      expandedAlignment: Alignment.topLeft,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: ThemeCubit.mediumPadding,
            right: ThemeCubit.mediumPadding,
            bottom: ThemeCubit.mediumPadding,
          ),
          child: SelectableText(self.text),
        ),
      ],
    );
  }
}
