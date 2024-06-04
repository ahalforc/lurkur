import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/app_bars.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/popups.dart';
import 'package:lurkur/features/submission_more_actions_popup.dart';
import 'package:lurkur/features/submission_popup.dart';
import 'package:lurkur/features/subreddit/submission_card.dart';

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

class _SubredditView extends StatefulWidget {
  const _SubredditView();

  @override
  State<_SubredditView> createState() => _SubredditViewState();
}

class _SubredditViewState extends State<_SubredditView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubredditCubit>().state;
    final hiddenSubreddits =
        context.watch<PreferenceCubit>().state.hiddenSubreddits;

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = context.responsiveHorizontalPadding;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _maybeLoadMore(
          context,
          notification,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          cacheExtent: screenSize.height,
          slivers: [
            LargeSliverAppBar(
              title: state.subreddit ?? 'home',
              automaticallyImplyLeading:
                  ![null, 'popular'].contains(state.subreddit),
              background: switch (state) {
                Loaded loaded
                    when loaded.headerImageUrl != null &&
                        loaded.headerImageUrl!.isNotEmpty =>
                  Image.network(
                    state.headerImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(),
                  ).animate().fade(
                        begin: 0,
                        end: 0.5,
                      ),
                _ => null,
              },
              actions: [
                IconButton(
                  onPressed: () => _showSortOptionsPopup(context),
                  icon: const Icon(Icons.filter_list_rounded),
                ),
                IconButton(
                  onPressed: () => _refresh(context),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (state is Loading)
              const SliverFillRemaining(
                child: LoadingIndicator(),
              ),
            if (state is LoadingFailed)
              const SliverFillRemaining(
                child: LoadingFailedIndicator(),
              ),
            if (state is Loaded) ...[
              LurkurSpacing.spacing16.verticalSliverGap,
              SliverPadding(
                padding: horizontalPadding,
                sliver: _PostsList(
                  submissions: state.submissions
                      .where(
                        (submission) =>
                            !hiddenSubreddits.contains(submission.subreddit),
                      )
                      .toList(),
                ),
              ),
            ],
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

  void _refresh(BuildContext context) {
    context.read<SubredditCubit>().reload();
    _scrollController.animateTo(
      0,
      duration: 0.25.seconds,
      curve: Curves.fastLinearToSlowEaseIn,
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

class _PostsList extends StatelessWidget {
  const _PostsList({
    required this.submissions,
  });

  final List<RedditSubmission> submissions;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return InkWell(
          onTap: () => showSubmissionPopup(
            context,
            submission: submission,
          ),
          onLongPress: () => showSubmissionMoreActionsPopup(
            context,
            submission: submission,
          ),
          borderRadius: LurkurRadius.radius16.circularBorderRadius,
          child: Padding(
            padding: LurkurSpacing.spacing16.allInsets,
            child: SubmissionCard(
              key: ValueKey(submission.id),
              submission: submission,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => Divider(
        height: LurkurSpacing.spacing16.value,
        indent: LurkurSpacing.spacing16.value,
        endIndent: LurkurSpacing.spacing16.value,
      ),
    );
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
