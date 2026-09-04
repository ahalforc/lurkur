import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preferences_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/popups.dart';
import 'package:provider/provider.dart';

void showSubmissionMoreActionsPopup(
  BuildContext context, {
  required RedditSubmission submission,
}) {
  showPrimaryPopup(
    context: context,
    expand: false,
    builder: (context, scrollController) {
      return MultiProvider(
        providers: [
          Provider.value(
            value: submission,
          ),
        ],
        child: SubmissionMoreActionsBody(
          scrollController: scrollController,
        ),
      );
    },
  );
}

class SubmissionMoreActionsBody extends StatelessWidget {
  const SubmissionMoreActionsBody({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final submission = context.watch<RedditSubmission>();
    return ListView(
      controller: scrollController,
      children: [
        ListTile(
          leading: const Icon(Icons.reddit_rounded),
          title: Text(submission.title),
          subtitle: Text(submission.subreddit),
        ),
        const _ShowOrHide(),
        const _ShowJson(),
      ],
    );
  }
}

class _ShowJson extends StatelessWidget {
  const _ShowJson();

  @override
  Widget build(BuildContext context) {
    final submission = context.watch<RedditSubmission>();
    return ListTile(
      leading: const Icon(Icons.data_object),
      title: const Text('Show json'),
      subtitle: const Text('For the daring'),
      onTap: () => showPrimaryPopup(
        context: context,
        expand: true,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(submission.toString()),
          );
        },
      ),
    );
  }
}

class _ShowOrHide extends StatelessWidget {
  const _ShowOrHide();

  @override
  Widget build(BuildContext context) {
    final submission = context.watch<RedditSubmission>();
    return ListTile(
      leading: const Icon(Icons.hide_source),
      title: const Text('Hide'),
      subtitle: const Text('Remove this subreddit from all feeds'),
      onTap: () {
        context.read<PreferencesCubit>().hideSubreddit(
              submission.subreddit,
            );
        context.read<RouterCubit>().goBack(context);
      },
    );
  }
}
