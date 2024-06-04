import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/app/widgets/videos.dart';
import 'package:provider/provider.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({
    super.key,
    required this.submission,
    this.compact = true,
  });

  final RedditSubmission submission;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final density = context.watch<PreferenceCubit>().state.themeDensity;
    final self = submission.self;
    final gallery = submission.gallery;
    final video = submission.video;
    final thumbnail = submission.thumbnailUrl;
    final canShowLargePreview =
        !compact || (compact && density == ThemeDensity.large);
    return MultiProvider(
      providers: [
        Provider.value(
          value: submission,
        ),
        Provider.value(
          value: compact ? density : ThemeDensity.large,
        ),
      ],
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Context(),
                  LurkurSpacing.spacing4.verticalGap,
                  const _Title(),
                  LurkurSpacing.spacing4.verticalGap,
                  const _Info(),
                  if (self != null && canShowLargePreview) ...[
                    LurkurSpacing.spacing12.verticalGap,
                    _SelfSubmission(self: self, compact: compact),
                  ],
                  if (gallery != null &&
                      video == null &&
                      canShowLargePreview) ...[
                    LurkurSpacing.spacing12.verticalGap,
                    _GallerySubmission(gallery: gallery),
                  ],
                  if (video != null && canShowLargePreview) ...[
                    LurkurSpacing.spacing12.verticalGap,
                    _VideoSubmission(video: video),
                  ],
                ],
              ),
            ),
            if (thumbnail != null && !canShowLargePreview) ...[
              LurkurSpacing.spacing12.horizontalGap,
              _Thumbnail(url: thumbnail),
            ],
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  ThemeDensity get themeDensity => watch<ThemeDensity>();

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
        width: LurkurSpacing.spacing24.value,
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
    required this.compact,
  });

  final SelfSubmission self;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      self.text,
      maxLines: compact ? 10 : null,
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
    return ClipRRect(
      borderRadius: LurkurRadius.radius16.circularBorderRadius,
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
        borderRadius: LurkurRadius.radius16.circularBorderRadius,
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
      borderRadius: LurkurRadius.radius8.circularBorderRadius,
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
