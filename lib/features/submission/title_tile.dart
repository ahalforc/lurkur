import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/models/reddit_submission.dart';
import 'package:lurkur/app/widgets/tags.dart';

class TitleTile extends StatelessWidget {
  const TitleTile({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.reddit),
      title: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: submission.title,
            ),
            TextSpan(
              text: ' by ${submission.author}',
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: ThemeCubit.small3Padding),
        child: Wrap(
          spacing: ThemeCubit.medium1Padding,
          children: [
            if (submission.isNsfw) const NsfwTag(),
            if (submission.isPinned) const PinnedTag(),
            if (submission.isStickied) const StickiedTag(),
            ScoreTag(
              score: submission.score,
            ),
            CommentsTag(
              count: submission.commentCount,
            ),
            CreatedTag(
              createdTime: submission.createdDateTime,
            ),
          ],
        ),
      ),
    );
  }
}
