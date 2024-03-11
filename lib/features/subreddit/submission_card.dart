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
    this.compact = false,
  });

  final RedditSubmission submission;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - 32) * (compact ? 0.8 : 1);
    final height =
        (MediaQuery.of(context).size.height / 2) * (compact ? 0.8 : 1);

    return Provider.value(
      value: submission,
      child: SizedBox(
        width: width,
        height: height,
        child: Card.filled(
          child: InkWell(
            onTap: () => showSubmissionPopup(
              context,
              submission: submission,
            ),
            onLongPress: () => showSubmissionMoreActionsPopup(
              context,
              submission: submission,
            ),
            child: Stack(
              children: [
                _Background(),
                Column(
                  children: [
                    _Header(),
                    Expanded(
                      child: _Preview(),
                    ),
                  ],
                ),
              ],
            ),
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

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    final gallery = context.submission.gallery;
    return gallery == null
        ? Container()
        : Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                gallery.images.first.url,
                fit: BoxFit.cover,
              ),
            ),
          );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Context(),
                    SizedBox(height: 4),
                    _Title(),
                  ],
                ),
              ),
              SizedBox(width: 4),
            ],
          ),
          SizedBox(height: 4),
          _Info(),
        ],
      ),
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
    final submission = context.submission;
    return SeparatedRow(
      space: 4,
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

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    final self = submission.self;
    final video = submission.video;
    final gallery = submission.gallery;
    return Column(
      children: [
        if (self != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(ThemeCubit.medium2Padding).copyWith(
                top: 0,
              ),
              child: Text(
                self.text,
                maxLines: 20,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        if (video != null)
          Expanded(
            flex: 4,
            child: Center(
              child: VideoPlayer(
                video: UrlVideo(
                  url: video.url,
                  width: video.width,
                  height: video.height,
                ),
              ),
            ),
          )
        else if (gallery != null)
          Expanded(
            flex: 4,
            child: Center(
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
          ),
      ],
    );
  }
}
