import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/widgets/loading_failed_indicator.dart';
import 'package:lurkur/app/widgets/loading_indicator.dart';
import 'package:lurkur/features/settings.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';
import 'package:lurkur/features/subscriptions.dart';

/// Renders a subreddit's posts and scaffold content for interacting with the
/// subreddit and the rest of the app.
///
/// If a null [subreddit] is provided, then the user's home page is fetched.
class SubredditPage extends StatelessWidget {
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
      )..load(subreddit),
      child: SubredditView(
        subreddit: subreddit,
      ),
    );
  }
}

class SubredditView extends StatefulWidget {
  const SubredditView({
    super.key,
    this.subreddit,
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
      context.read<SubredditCubit>().load(widget.subreddit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SubredditCubit, SubredditState>(
        builder: (context, state) {
          return _Body(
            subreddit: widget.subreddit ?? 'home',
            child: switch (state) {
              (Loading _) => const SliverFillRemaining(
                  child: Center(
                    child: LoadingIndicator(),
                  ),
                ),
              (LoadingFailed _) => const SliverFillRemaining(
                  child: Center(
                    child: LoadingFailedIndicator(),
                  ),
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
          );
        },
      ),
      bottomNavigationBar: const _BottomAppBar(),
      floatingActionButton: const _FloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.subreddit,
    required this.child,
  });

  final String subreddit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(subreddit),
          centerTitle: false,
          floating: true,
        ),
        child,
      ],
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showSubscriptionsPopup(context),
      child: const Icon(Icons.list),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () => showSettingsPopup(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
