import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/buttons.dart';
import 'package:lurkur/app/widgets/cards.dart';
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
      child: ElevatedCard(
        onPressed: () => context.goToSubmission(submission),
        child: switch (context.themeDensity) {
          ThemeDensity.small => const _SmallSubmissionTile(),
          ThemeDensity.medium => const _MediumSubmissionTile(),
          ThemeDensity.large => const _LargeSubmissionTile(),
        },
      ),
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
    return const Padding(
      padding: EdgeInsets.all(ThemeCubit.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Preview(),
              SizedBox(width: ThemeCubit.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(),
                    SizedBox(height: ThemeCubit.smallPadding),
                    _Context(),
                    SizedBox(height: ThemeCubit.mediumPadding),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            children: [
              _Score(),
              _Comments(),
              _Share(),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediumSubmissionTile extends StatelessWidget {
  const _MediumSubmissionTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(ThemeCubit.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(),
          SizedBox(height: ThemeCubit.smallPadding),
          _Context(),
          SizedBox(height: ThemeCubit.mediumPadding),
          _Preview(),
          Wrap(
            children: [
              _Score(),
              _Comments(),
              _Share(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeSubmissionTile extends StatelessWidget {
  const _LargeSubmissionTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(ThemeCubit.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(),
          SizedBox(height: ThemeCubit.smallPadding),
          _Context(),
          SizedBox(height: ThemeCubit.mediumPadding),
          _Preview(),
          Wrap(
            children: [
              _Score(),
              _Comments(),
              _Share(),
            ],
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return Text(
      submission.title,
      style: context.textTheme.titleMedium,
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
    return IconTextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        // todo Hit the reddit api to upvote this, update the cache
        showNotificationPopup(
          context: context,
          content: const Text('Upvote unimplemented'),
        );
      },
      onLongPressed: () {
        HapticFeedback.heavyImpact();
        // todo Hit the reddit api to downvote this, update the cache
        showNotificationPopup(
          context: context,
          content: const Text('Downvote unimplemented'),
        );
      },
      icon: const Icon(Icons.thumbs_up_down),
      label: Text('${score > 0 ? '+' : ''}$score'),
    );
  }
}

class _Comments extends StatelessWidget {
  const _Comments();

  @override
  Widget build(BuildContext context) {
    final submission = context.submission;
    return IconTextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        context.goToSubmission(submission);
      },
      icon: const Icon(Icons.comment),
      label: Text('${submission.commentCount}'),
    );
  }
}

class _Share extends StatelessWidget {
  const _Share();

  @override
  Widget build(BuildContext context) {
    return IconTextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        // todo Use the native share plugin and kick off a native share.
        showNotificationPopup(
          context: context,
          content: const Text('Share unimplemented'),
        );
      },
      icon: const Icon(Icons.ios_share),
      label: const Text('Share'),
    );
  }
}
