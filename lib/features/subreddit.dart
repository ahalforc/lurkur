import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';
import 'package:lurkur/features/subreddit/subreddit_bab.dart';
import 'package:lurkur/features/subreddit/subscriptions_fab.dart';

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
      child: SubredditView(
        subreddit: subreddit,
      ),
    );
  }
}

class SubredditView extends StatefulWidget {
  const SubredditView({
    super.key,
    required this.subreddit,
  });

  final String? subreddit;

  @override
  State<SubredditView> createState() => _SubredditViewState();
}

class _SubredditViewState extends State<SubredditView> {
  @override
  void didUpdateWidget(covariant SubredditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subreddit != widget.subreddit) {
      context.read<SubredditCubit>().load(
            widget.subreddit,
            sortOption: SubredditPage.defaultSortOption,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
      bottomNavigationBar: SubredditBab(),
      floatingActionButton: SubscriptionsFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubredditCubit, SubredditState>(
      builder: (context, state) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) => _maybeLoadMore(
            context,
            notification,
          ),
          child: CustomScrollView(
            slivers: [
              // todo The sort option isn't fading at the same time as the subreddit
              SliverAppBar(
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: state.subreddit ?? 'home'),
                      TextSpan(
                        text: '  ( ${state.sortOption.displayName} )',
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                floating: true,
              ),
              switch (state) {
                (Loading _) => const SliverFillRemaining(
                    child: LoadingIndicator(),
                  ),
                (LoadingFailed _) => const SliverFillRemaining(
                    child: LoadingFailedIndicator(),
                  ),
                (Loaded loaded) => SliverList.builder(
                    itemCount: loaded.submissions.length,
                    itemBuilder: (context, index) {
                      return SubmissionTile(
                        submission: loaded.submissions[index],
                      );
                    },
                  ),
              },
              if (state is Loaded && state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: LoadingIndicator(),
                ),
              if (state is Loaded && state.didLoadingMoreFail)
                const SliverToBoxAdapter(
                  child: LoadingFailedIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
      context.read<SubredditCubit>().loadMore();
    }
    return false; // let the notification continue bubbling
  }
}
