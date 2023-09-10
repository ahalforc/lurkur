import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/list_tiles.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/app/widgets/videos.dart';
import 'package:lurkur/features/submission_more_actions_popup.dart';
import 'package:lurkur/features/submission_popup.dart';
import 'package:provider/provider.dart';

class SubmissionTile extends StatelessWidget {
  const SubmissionTile({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    final density = context.themeDensity;
    return Provider.value(
      value: submission,
      child: BodyListTile(
          onPress: () => showSubmissionPopup(
                context,
                submission: submission,
              ),
          onLongPress: () => showSubmissionMoreActionsPopup(
                context,
                submission: submission,
              ),
          contentAlignment: switch (density) {
            ThemeDensity.small => CrossAxisAlignment.center,
            _ => CrossAxisAlignment.start,
          },
          leading: const _Leading(),
          title: const _Title(),
          subtitles: const [
            SizedBox(height: ThemeCubit.small2Padding),
            _Info(),
            SizedBox(height: ThemeCubit.small3Padding),
            _Context(),
          ],
          body: switch (density) {
            ThemeDensity.large => const _Preview(),
            _ => null,
          }),
    );
  }
}

extension on BuildContext {
  ThemeDensity get themeDensity => watch<PreferenceCubit>().state.themeDensity;

  RedditSubmission get submission => watch<RedditSubmission>();
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final density = context.themeDensity;
    final submission = context.submission;
    return Text(
      submission.title,
      style: context.textTheme.titleMedium,
      overflow: switch (density) {
        ThemeDensity.small => TextOverflow.ellipsis,
        _ => null,
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return Wrap(
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
    );
  }
}

class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
    final density = context.themeDensity;
    final submission = context.submission;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: submission.subreddit,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.secondary,
            ),
          ),
          TextSpan(
            text: ' by ${submission.author}',
            style: context.textTheme.labelSmall,
          ),
        ],
      ),
      maxLines: switch (density) {
        ThemeDensity.small => 1,
        _ => null,
      },
      overflow: switch (density) {
        ThemeDensity.small => TextOverflow.ellipsis,
        _ => null,
      },
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading();

  @override
  Widget build(BuildContext context) {
    return Thumbnail(
      url: context.submission.thumbnailUrl,
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    final self = submission.self;
    final video = submission.video;
    final gallery = submission.gallery;
    return SeparatedColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      space: ThemeCubit.medium1Padding,
      children: [
        if (self != null)
          Padding(
            padding: const EdgeInsets.all(ThemeCubit.medium1Padding).copyWith(
              top: 0,
            ),
            child: Text(
              self.text,
              maxLines: 20,
              overflow: TextOverflow.fade,
            ),
          ),
        if (video != null)
          VideoPlayer(
            video: UrlVideo(
              url: video.url,
              width: video.width,
              height: video.height,
            ),
          )
        else if (gallery != null)
          Gallery(
            images: [
              for (final image in gallery.images)
                UrlImage(
                  url: image.url,
                  width: image.width,
                  height: image.height,
                ),
            ],
          ),
      ],
    );
  }
}
