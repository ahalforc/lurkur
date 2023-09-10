import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/models/reddit_submission.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';

class SubredditBody extends StatelessWidget {
  const SubredditBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubredditCubit>().state;
    final hiddenSubreddits =
        context.watch<PreferenceCubit>().state.hiddenSubreddits;

    final submissions = switch (state) {
      (Loaded loaded) => loaded.submissions.where(
          (submission) => !hiddenSubreddits.contains(submission.subreddit),
        ),
      _ => const <RedditSubmission>[],
    }
        .toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _maybeLoadMore(
        context,
        notification,
      ),
      child: CustomScrollView(
        slivers: [
          switch (state) {
            (Loading _) => const SliverFillRemaining(
                child: LoadingIndicator(),
              ),
            (LoadingFailed _) => const SliverFillRemaining(
                child: LoadingFailedIndicator(),
              ),
            (Loaded _) => SliverSafeArea(
                left: false,
                right: false,
                bottom: false,
                sliver: SliverList.separated(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    return SubmissionTile(
                      key: ValueKey(submissions[index].id),
                      submission: submissions[index],
                    );
                  },
                  separatorBuilder: (context, _) => Container(
                    color: context.colorScheme.outline.withOpacity(0.15),
                    height: ThemeCubit.medium1Padding,
                  ),
                ),
              ),
          },
          if (state is Loaded && state.isLoadingMore)
            const SliverFullScreen(
              child: LoadingIndicator(),
            ),
          if (state is Loaded && state.didLoadingMoreFail)
            const SliverFullScreen(
              child: LoadingFailedIndicator(),
            ),
        ],
      ),
    );
  }

  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    final max = notification.metrics.maxScrollExtent;
    final current = notification.metrics.pixels;
    // At 80% of the total scroll (or more), start loading the next block.
    if (current >= max * 0.8) {
      context.read<SubredditCubit>().loadMore();
    }
    return false; // let the notification continue bubbling
  }
}
