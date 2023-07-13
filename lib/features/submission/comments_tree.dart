import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/reddit/submission_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/tags.dart';

class CommentsTree extends StatelessWidget {
  const CommentsTree({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionCubit, SubmissionState>(
      builder: (context, state) {
        return switch (state) {
          (Loading _) => const _Loading(),
          (LoadingFailed _) => const _LoadingFailed(),
          (Loaded loaded) => BlocProvider(
              create: (_) => _ExpansionStateCubit(),
              child: _Loaded(state: loaded),
            ),
        };
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: LoadingIndicator(),
    );
  }
}

class _LoadingFailed extends StatelessWidget {
  const _LoadingFailed();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      child: LoadingFailedIndicator(),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.state,
  });

  final Loaded state;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return CommentTile(
              comment: state.comments[index],
            );
          },
          childCount: state.comments.length,
        ),
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
  });

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_ExpansionStateCubit, Set<RedditComment>>(
      builder: (context, collapsedComments) {
        final leading = Text(
          '+${comment.score}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.primary,
          ),
        );
        final title = Text.rich(
          TextSpan(
            children: [
              if (comment.isSubmitter)
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ThemeCubit.xsmallPadding,
                    ),
                    child: SubmitterTag(),
                  ),
                ),
              if (comment.isEdited)
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ThemeCubit.xsmallPadding,
                    ),
                    child: EditedTag(),
                  ),
                ),
              TextSpan(
                text: comment.author,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
        final subtitle = Text(comment.body);
        return comment.replies.isNotEmpty
            ? ExpansionTile(
                leading: leading,
                title: title,
                subtitle: subtitle,
                initiallyExpanded: !collapsedComments.contains(comment),
                childrenPadding: const EdgeInsets.only(left: 16),
                onExpansionChanged: (v) => v
                    ? context.read<_ExpansionStateCubit>().setExpanded(comment)
                    : context
                        .read<_ExpansionStateCubit>()
                        .setCollapsed(comment),
                children: [
                  for (final reply in comment.replies)
                    CommentTile(comment: reply),
                ],
              )
            : ListTile(
                leading: leading,
                title: title,
                subtitle: subtitle,
              );
      },
    );
  }
}

class _ExpansionStateCubit extends Cubit<Set<RedditComment>> {
  _ExpansionStateCubit() : super({});

  void setExpanded(RedditComment comment) {
    emit(state..remove(comment));
  }

  void setCollapsed(RedditComment comment) {
    emit(state..add(comment));
  }
}
