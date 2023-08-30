import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/features/subreddit/subreddit_bab.dart';
import 'package:lurkur/features/subreddit/subreddit_body.dart';
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
      body: SubredditBody(),
      bottomNavigationBar: SubredditBab(),
      floatingActionButton: SubscriptionsFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
