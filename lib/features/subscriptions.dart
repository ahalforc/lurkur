import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/indicators.dart';

/// Shows a popup that lets the user select a subreddit from their subscriptions.
///
/// For more information, please see [SubscriptionsBody].
void showSubscriptionsPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return const SubscriptionsBody();
    },
  );
}

class SubscriptionsBody extends StatelessWidget {
  const SubscriptionsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RedditSubscription>>(
      future: RedditApi().getSubscriptions(
        accessToken: context.read<AuthCubit>().state.accessToken!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const LoadingFailedIndicator();
        }
        final data = snapshot.data;
        if (data == null) {
          return const LoadingIndicator();
        }
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: ThemeCubit.mediumPadding,
                right: ThemeCubit.mediumPadding,
                bottom: ThemeCubit.mediumPadding,
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Find a subreddit',
                ),
                onSubmitted: context.goToSubreddit,
              ),
            ),
            const _SubscriptionTile(
              title: 'home',
            ),
            const _SubscriptionTile(
              title: 'popular',
              subredditName: 'popular',
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
    read<RouterCubit>()
      ..pop(this)
      ..goToSubreddit(
        this,
        subredditName: subredditName,
      );
  }
}
