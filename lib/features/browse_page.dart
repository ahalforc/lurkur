import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/browse_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/app_bars.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BrowseCubit(
        authCubit: context.read<AuthCubit>(),
        redditApi: context.read<RedditApi>(),
      )..load(),
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatelessWidget {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          LargeSliverAppBar(
            title: 'browse',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.browseCubit.reload(),
              ),
            ],
          ),
          SliverPadding(
            padding: context.responsiveHorizontalPadding.copyWith(
              top: 16,
              bottom: 16,
            ),
            sliver: const SliverToBoxAdapter(
              child: _SubredditTextField(),
            ),
          ),
          SliverPadding(
            padding: context.responsiveHorizontalPadding,
            sliver: const _SubscriptionsList(),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList();

  @override
  Widget build(BuildContext context) {
    final state = context.watchBrowseCubit.state;
    return switch (state) {
      Loading _ => const SliverFullScreen(
          child: LoadingIndicator(),
        ),
      LoadingFailed _ => const SliverFullScreen(
          child: LoadingFailedIndicator(),
        ),
      Loaded loaded => SliverList.separated(
          itemCount: loaded.subscriptions.length,
          itemBuilder: (context, index) {
            return _SubscriptionCard.fromSubscription(
              loaded.subscriptions[index],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 16),
        ),
    };
  }
}

class _SubredditTextField extends StatelessWidget {
  const _SubredditTextField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.go,
      decoration: const InputDecoration(
        hintText: 'Find a subreddit',
      ),
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onSubmitted: (s) => context.goToSubreddit(s.trim()),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.title,
    this.subtitle,
    this.subredditName,
  });

  factory _SubscriptionCard.fromSubscription(
    RedditSubscription subscription,
  ) {
    return _SubscriptionCard(
      title: subscription.displayName,
      subtitle: subscription.title,
      subredditName: subscription.displayName,
    );
  }

  final String title;
  final String? subtitle;
  final String? subredditName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(title),
          subtitle: subtitle != null
              ? Opacity(
                  opacity: 0.5,
                  child: Text(subtitle!),
                )
              : null,
          trailing: const Opacity(
            opacity: 0.5,
            child: Icon(Icons.chevron_right),
          ),
          onTap: () => context.goToSubreddit(subredditName)),
    );
  }
}

extension on BuildContext {
  void goToSubreddit(String? subredditName) {
    read<RouterCubit>().pushSubreddit(
      this,
      subredditName: subredditName,
    );
  }
}
