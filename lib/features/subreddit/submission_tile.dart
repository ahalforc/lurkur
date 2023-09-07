import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/list_tiles.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/app/widgets/videos.dart';
import 'package:lurkur/features/submission_popup.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
          onLongPress: () => context.showSubmissionJson(submission),
          contentAlignment: switch (density) {
            ThemeDensity.small => CrossAxisAlignment.center,
            _ => CrossAxisAlignment.start,
          },
          leading: const _Leading(),
          title: const _Title(),
          subtitles: const [
            _Info(),
            SizedBox(height: ThemeCubit.small2Padding),
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

  void showSubmissionJson(RedditSubmission submission) {
    showPrimaryPopup(
      context: this,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SelectableText(submission.toString()),
        );
      },
    );
  }
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
    final density = context.themeDensity;
    final submission = context.submission;
    return Text.rich(
      TextSpan(
        children: [
          if (submission.isNsfw)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.medium1Padding,
                ),
                child: NsfwTag(),
              ),
            ),
          if (submission.isPinned)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.medium1Padding,
                ),
                child: PinnedTag(),
              ),
            ),
          if (submission.isStickied)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.medium1Padding,
                ),
                child: StickiedTag(),
              ),
            ),
          TextSpan(
            text: submission.scoreStr,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          TextSpan(
            text: ' - ',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          TextSpan(
            text: '${submission.commentCount} comments',
            style: context.textTheme.bodyMedium?.copyWith(),
          ),
          TextSpan(
            text: ' - ',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          TextSpan(
            text: timeago.format(submission.createdDateTime, locale: 'en'),
            style: context.textTheme.bodyMedium?.copyWith(),
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
      space: ThemeCubit.medium1Padding,
      children: [
        if (self != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeCubit.medium1Padding,
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
