import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/app/widgets/tags.dart';

class SubmissionTile extends StatelessWidget {
  const SubmissionTile({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.hardEdge,
        child: submission.thumbnailUrl != null
            ? Image.network(
                submission.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              )
            : null,
      ),
      title: Text.rich(
        TextSpan(
          children: [
            if (submission.isNsfw)
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ThemeCubit.xsmallPadding,
                  ),
                  child: NsfwTag(),
                ),
              ),
            if (submission.isPinned)
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ThemeCubit.xsmallPadding,
                  ),
                  child: PinnedTag(),
                ),
              ),
            if (submission.isStickied)
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ThemeCubit.xsmallPadding,
                  ),
                  child: StickiedTag(),
                ),
              ),
            TextSpan(
              text: submission.title,
            ),
            TextSpan(
              text: ' - ${submission.author}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '+${submission.score}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
            TextSpan(
              text:
                  ' - ${DateTime.now().difference(submission.createdDateTime).inHours} hours ago - ',
              style: context.textTheme.bodyMedium?.copyWith(),
            ),
            TextSpan(
              text: '${submission.commentCount} comments',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
            const TextSpan(
              text: ' - ',
            ),
            TextSpan(
              text: submission.subreddit,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.read<RouterCubit>().pushSubmission(
            context,
            serializedSubmission: submission.toString(),
          ),
      onLongPress: () => showPrimaryPopup(
        context: context,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(submission.toString()),
          );
        },
      ),
    );
  }
}
