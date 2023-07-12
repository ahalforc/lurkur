import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/features/settings.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';
import 'package:lurkur/features/subscriptions.dart';

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
          sortOption: defaultSortOption,
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
      context.read<SubredditCubit>().load(
            widget.subreddit,
            sortOption: SubredditPage.defaultSortOption,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(
        title: widget.subreddit ?? 'home',
      ),
      bottomNavigationBar: const _BottomAppBar(),
      floatingActionButton: const _FloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubredditCubit, SubredditState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: title),
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
          ],
        );
      },
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
            onPressed: () => _showSortOptionsPopup(context),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () => showSettingsPopup(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  void _showSortOptionsPopup(BuildContext context) {
    final subredditCubit = context.read<SubredditCubit>();
    final routerCubit = context.read<RouterCubit>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          children: [
            for (final option in [...SortOption.values])
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.displayName),
                onTap: () {
                  subredditCubit.setSortOption(option);
                  routerCubit.pop(context);
                },
              ),
          ],
        );
      },
    );
  }
}

extension on SortOption {
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
