import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/buttons.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/features/submission/video_tile.dart';
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
    return Provider.value(
      value: submission,
      child: switch (context.themeDensity) {
        ThemeDensity.small => const _SmallSubmissionTile(),
        ThemeDensity.medium => const _MediumSubmissionTile(),
        ThemeDensity.large => const _LargeSubmissionTile(),
      },
    );
  }
}

extension on BuildContext {
  ThemeDensity get themeDensity => watch<PreferenceCubit>().state.themeDensity;

  RedditSubmission get submission => watch<RedditSubmission>();

  void goToSubmission(RedditSubmission submission) {
    read<RouterCubit>().pushSubmission(
      this,
      serializedSubmission: submission.toString(),
    );
  }

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

class _SmallSubmissionTile extends StatelessWidget {
  const _SmallSubmissionTile();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeCubit.xsmallPadding,
        right: ThemeCubit.xsmallPadding,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.goToSubmission(submission);
          },
          child: const Padding(
            padding: EdgeInsets.all(ThemeCubit.smallPadding),
            child: Row(
              children: [
                _Score(),
                SizedBox(width: ThemeCubit.smallPadding),
                _Preview(),
                SizedBox(width: ThemeCubit.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Title(),
                      SizedBox(height: ThemeCubit.xsmallPadding),
                      _Context(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediumSubmissionTile extends StatelessWidget {
  const _MediumSubmissionTile();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeCubit.smallPadding,
        right: ThemeCubit.smallPadding,
        bottom: ThemeCubit.smallPadding,
      ),
      child: Card(
        child: InkWell(
          onTap: () => context.goToSubmission(submission),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: ThemeCubit.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeCubit.smallPadding,
                  ),
                  child: _Title(),
                ),
                SizedBox(height: ThemeCubit.smallPadding),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeCubit.smallPadding,
                  ),
                  child: _Context(),
                ),
                SizedBox(height: ThemeCubit.smallPadding),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeCubit.smallPadding,
                  ),
                  child: _Preview(),
                ),
                SizedBox(height: ThemeCubit.smallPadding),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ThemeCubit.smallPadding,
                  ),
                  child: Wrap(
                    children: [
                      _Score(),
                      _Comments(),
                      _Share(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeSubmissionTile extends StatelessWidget {
  const _LargeSubmissionTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: ThemeCubit.smallPadding,
        right: ThemeCubit.smallPadding,
        bottom: ThemeCubit.smallPadding,
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ThemeCubit.smallPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeCubit.smallPadding,
                ),
                child: _Title(),
              ),
              SizedBox(height: ThemeCubit.smallPadding),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeCubit.smallPadding,
                ),
                child: _Context(),
              ),
              SizedBox(height: ThemeCubit.smallPadding),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeCubit.smallPadding,
                ),
                child: _Preview(),
              ),
              SizedBox(height: ThemeCubit.smallPadding),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeCubit.smallPadding,
                ),
                child: Wrap(
                  children: [
                    _Score(),
                    _Comments(),
                    _Share(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      maxLines: switch (density) {
        ThemeDensity.small => 1,
        _ => null,
      },
      overflow: switch (density) {
        ThemeDensity.small => TextOverflow.ellipsis,
        _ => null,
      },
      style: switch (density) {
        ThemeDensity.small => context.textTheme.bodyMedium,
        ThemeDensity.medium => context.textTheme.titleSmall,
        ThemeDensity.large => context.textTheme.titleMedium,
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
          if (submission.isNsfw)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.smallPadding,
                ),
                child: NsfwTag(),
              ),
            ),
          if (submission.isPinned)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.smallPadding,
                ),
                child: PinnedTag(),
              ),
            ),
          if (submission.isStickied)
            const WidgetSpan(
              child: Padding(
                padding: EdgeInsets.only(
                  right: ThemeCubit.smallPadding,
                ),
                child: StickiedTag(),
              ),
            ),
          TextSpan(
            text: timeago.format(submission.createdDateTime, locale: 'en'),
            style: context.textTheme.bodyMedium?.copyWith(),
          ),
          TextSpan(
            text: ' - ${submission.subreddit}',
          ),
          TextSpan(
            text: ' - ${submission.author}',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.secondary,
            ),
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
    final density = context.themeDensity;
    final submission = context.submission;

    return switch (density) {
      ThemeDensity.small => Thumbnail(url: submission.thumbnailUrl),
      ThemeDensity.medium => Container(
          constraints: const BoxConstraints(maxHeight: 128),
          child: submission.video != null
              ? VideoTile(
                  video: submission.video!,
                )
              : submission.gallery != null
                  ? Gallery(
                      urls: submission.gallery!.urls,
                    )
                  : Container(),
        ),
      ThemeDensity.large => submission.video != null
          ? VideoTile(
              video: submission.video!,
            )
          : submission.gallery != null
              ? Gallery(
                  urls: submission.gallery!.urls,
                )
              : Container(),
    };
  }
}

class _Score extends StatelessWidget {
  const _Score();

  @override
  Widget build(BuildContext context) {
    final score = context.submission.score;
    return SplitIconButton(
      onLeftPressed: () {
        HapticFeedback.heavyImpact();
        // todo Hit the reddit api to upvote this, update the cache
      },
      onRightPressed: () {
        HapticFeedback.heavyImpact();
        // todo Hit the reddit api to downvote this, update the cache
      },
      leftIcon: const Icon(Icons.arrow_upward),
      rightIcon: const Icon(Icons.arrow_downward),
      child: Text('${score > 0 ? '+' : ''}$score'),
    );
  }
}

class _Comments extends StatelessWidget {
  const _Comments();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return SplitIconButton(
      onLeftPressed: () {
        HapticFeedback.heavyImpact();
        context.goToSubmission(submission);
      },
      leftIcon: const Icon(Icons.comment),
      child: Text('${submission.commentCount}'),
    );
  }
}

class _Share extends StatelessWidget {
  const _Share();

  @override
  Widget build(BuildContext context) {
    return SplitIconButton(
      onLeftPressed: () {
        HapticFeedback.heavyImpact();
        // todo Use the native share plugin and kick off a native share.
      },
      leftIcon: const Icon(Icons.ios_share),
      child: const Text('Share'),
    );
  }
}
