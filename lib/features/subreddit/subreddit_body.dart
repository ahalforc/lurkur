import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/reddit/subreddit_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/features/subreddit/submission_tile.dart';

class SubredditBody extends StatelessWidget {
  const SubredditBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubredditCubit>().state;
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
            (Loaded loaded) => SliverSafeArea(
                left: false,
                right: false,
                bottom: false,
                sliver: SliverList.separated(
                  itemCount: loaded.submissions.length,
                  itemBuilder: (context, index) {
                    return SubmissionTile(
                      submission: loaded.submissions[index],
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
  }

  bool _maybeLoadMore(BuildContext context, ScrollNotification notification) {
    // todo This should be more like "75% of max scroll extent == load more"
    if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
      context.read<SubredditCubit>().loadMore();
    }
    return false; // let the notification continue bubbling
  }
}