import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('browse'),
            centerTitle: false,
            floating: true,
          ),
          _SubscriptionsList(),
        ],
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RedditSubscription>>(
      future: RedditApi().getSubscriptions(
        accessToken: context.read<AuthCubit>().state.accessToken!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SliverFullScreen(
            child: LoadingFailedIndicator(),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const SliverFullScreen(
            child: LoadingIndicator(),
          );
        }
        return SliverList.list(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: ThemeCubit.medium2Padding,
                right: ThemeCubit.medium2Padding,
                bottom: ThemeCubit.medium2Padding,
              ),
              child: _SubredditTextField(),
            ),
            for (final subscription in data
              ..sort((a, b) => a.displayName
                  .toLowerCase()
                  .compareTo(b.displayName.toLowerCase())))
              _SubscriptionTile.fromSubscription(subscription),
          ],
        );
      },
    );
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
        border: OutlineInputBorder(),
        hintText: 'Find a subreddit',
      ),
      onSubmitted: (s) => context.goToSubreddit(s.trim()),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.title,
    this.subtitle,
    this.subredditName,
  });

  factory _SubscriptionTile.fromSubscription(
    RedditSubscription subscription,
  ) {
    return _SubscriptionTile(
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
    return ListTile(
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
        onTap: () => context.goToSubreddit(subredditName));
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
