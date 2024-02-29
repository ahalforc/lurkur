import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/popups.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';

/// Renders a subreddit's posts and scaffold content for interacting with the
/// subreddit and the rest of the app.
///
/// If a null [subreddit] is provided, then the user's home page is fetched.
class SubredditPage extends StatelessWidget {
  static const defaultSortOption = SortOption.hot;

  const SubredditPage({
    super.key,
    this.subreddit,
  });

  final String? subreddit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubredditCubit(
        authCubit: context.read<AuthCubit>(),
        redditApi: context.read<RedditApi>(),
      )..load(
          subreddit,
          sortOption: SubredditPage.defaultSortOption,
        ),
      child: const _SubredditView(),
    );
  }
}

class _SubredditView extends StatelessWidget {
  const _SubredditView();

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

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _maybeLoadMore(
          context,
          notification,
        ),
        child: RefreshIndicator(
          onRefresh: () async => _reload(context),
          child: CustomScrollView(
            cacheExtent: screenSize.height,
            slivers: [
              SliverAppBar(
                title: Text(state.subreddit ?? 'home'),
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: () => _showSortOptionsPopup(context),
                    icon: const Icon(Icons.filter_list_rounded),
                  ),
                ],
              ),
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
                    sliver: SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: max(
                          (screenSize.width - ThemeCubit.maxBodyWidth) / 2,
                          0.0,
                        ),
                      ),
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
        ),
      ),
    );
  }

  void _showSortOptionsPopup(BuildContext context) {
    final subredditCubit = context.read<SubredditCubit>();
    final routerCubit = context.read<RouterCubit>();
    showPrimaryPopup(
      context: context,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            for (final option in [...SortOption.values])
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.displayName),
                onTap: () {
                  subredditCubit.setSortOption(option);
                  routerCubit.goBack(context);
                },
              ),
          ],
        );
      },
    );
  }

  void _reload(BuildContext context) {
    context.read<SubredditCubit>().reload();
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

extension SubredditBabSortOptionX on SortOption {
  String get displayName => switch (this) {
        SortOption.hot => 'hot',
        SortOption.topHour => 'top of the hour',
        SortOption.topDay => 'top of the day',
        SortOption.topWeek => 'top of the week',
        SortOption.topMonth => 'top of the month',
        SortOption.topYear => 'top of the year',
        SortOption.topAllTime => 'top of all time',
      };

  IconData get icon => switch (this) {
        SortOption.hot => Icons.local_fire_department,
        SortOption.topHour => Icons.favorite,
        SortOption.topDay => Icons.favorite,
        SortOption.topWeek => Icons.favorite,
        SortOption.topMonth => Icons.favorite,
        SortOption.topYear => Icons.favorite,
        SortOption.topAllTime => Icons.favorite,
      };
}
