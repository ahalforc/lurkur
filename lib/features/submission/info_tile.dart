import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openSubreddit(context),
      title: Text(
        submission.subreddit,
        maxLines: 1,
      ),
      leading: const Icon(Icons.subdirectory_arrow_right),
    );
  }

  void _openSubreddit(BuildContext context) {
    context.read<RouterCubit>()
      ..goBack(context)
      ..pushSubreddit(
        context,
        subredditName: submission.subreddit,
      );
  }
}
