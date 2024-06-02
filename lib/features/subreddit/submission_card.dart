import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/app/widgets/videos.dart';
import 'package:lurkur/features/submission_more_actions_popup.dart';
import 'package:lurkur/features/submission_popup.dart';
import 'package:provider/provider.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    final self = submission.self;
    final gallery = submission.gallery;
    final video = submission.video;
    final thumbnail = submission.thumbnailUrl;
    final canShowLargePreview = context.themeDensity == ThemeDensity.large;
    return Provider.value(
      value: submission,
      child: InkWell(
        onTap: () => showSubmissionPopup(
          context,
          submission: submission,
        ),
        onLongPress: () => showSubmissionMoreActionsPopup(
          context,
          submission: submission,
        ),
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Context(),
                    const SizedBox(height: 4),
                    const _Title(),
                    const SizedBox(height: 4),
                    const _Info(),
                    if (self != null && canShowLargePreview) ...[
                      const SizedBox(height: 12),
                      _SelfSubmission(self: self),
                    ],
                    if (gallery != null &&
                        video == null &&
                        canShowLargePreview) ...[
                      const SizedBox(height: 12),
                      _GallerySubmission(gallery: gallery),
                    ],
                    if (video != null && canShowLargePreview) ...[
                      const SizedBox(height: 12),
                      _VideoSubmission(video: video),
                    ],
                  ],
                ),
              ),
              if (thumbnail != null && !canShowLargePreview) ...[
                const SizedBox(width: 12),
                _Thumbnail(url: thumbnail),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  ThemeDensity get themeDensity => watch<PreferenceCubit>().state.themeDensity;

  RedditSubmission get submission => watch<RedditSubmission>();
}

class _Context extends StatelessWidget {
  const _Context();

  @override
  Widget build(BuildContext context) {
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
      maxLines: 1,
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
      maxLines: switch (density) {
        ThemeDensity.small => 1,
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
    return SeparatedRow(
      separatorBuilder: (_) => Container(
        alignment: Alignment.center,
        width: ThemeCubit.medium3Padding,
        child: const Text('•'),
      ),
      children: [
        if (submission.isNsfw) const NsfwTag(),
        if (submission.isPinned) const PinnedTag(),
        if (submission.isStickied) const StickiedTag(),
        ScoreTag(score: submission.score),
        CommentsTag(count: submission.commentCount),
        CreatedTag(createdTime: submission.createdDateTime),
      ],
    );
  }
}

class _SelfSubmission extends StatelessWidget {
  const _SelfSubmission({
    required this.self,
  });

  final SelfSubmission self;

  @override
  Widget build(BuildContext context) {
    return Text(
      self.text,
      maxLines: 10,
      overflow: TextOverflow.fade,
    );
  }
}

class _GallerySubmission extends StatelessWidget {
  const _GallerySubmission({
    required this.gallery,
  });

  final GallerySubmission gallery;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: gallery.tallestAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Gallery(
          images: [
            for (final image in gallery.images)
              UrlImage(
                url: image.url,
                width: image.width,
                height: image.height,
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoSubmission extends StatelessWidget {
  const _VideoSubmission({
    required this.video,
  });

  final VideoSubmission video;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: video.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: VideoPlayer(
          video: UrlVideo(
            url: video.url,
            width: video.width,
            height: video.height,
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: switch (context.themeDensity) {
          ThemeDensity.small => 48,
          _ => 64,
        },
        height: switch (context.themeDensity) {
          ThemeDensity.small => 48,
          _ => 64,
        },
        child: Image.network(url),
      ),
    );
  }
}
