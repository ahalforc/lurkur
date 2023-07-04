import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
  });

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // todo Get an appropriate thumbnail for a post
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          'https://picsum.photos/200',
        ),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: post.title,
            ),
            TextSpan(
              text: ' - ${post.author}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '+${post.score}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
            TextSpan(
              text:
                  ' - ${DateTime.now().difference(post.createdDateTime).inHours} hours ago - ',
              style: context.textTheme.bodyMedium?.copyWith(),
            ),
            TextSpan(
              text: '${post.commentCount} comments',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
            const TextSpan(
              text: ' - ',
            ),
            TextSpan(
              text: post.subreddit,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.read<RouterCubit>().pushPost(
            context,
            post: 'todo',
          ),
    );
  }
}
