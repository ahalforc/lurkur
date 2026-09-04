import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:lurkur/app/blocs/preferences_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/images.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/tags.dart';

class CommentsTree extends StatelessWidget {
  const CommentsTree({
    super.key,
    required this.comments,
  });

  final List<RedditComment> comments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _ExpansionStateCubit(),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: SliverSafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          sliver: SliverList.builder(
            itemBuilder: (context, index) {
              return CommentTile(
                comment: comments[index],
              );
            },
            itemCount: comments.length,
          ),
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
    if (comment.author == 'AutoModerator' &&
        context.watchPreferences.state.hideAutoModeratorComments) {
      return Container();
    }
    return BlocBuilder<_ExpansionStateCubit, Set<RedditComment>>(
      builder: (context, collapsedComments) {
        final title = _CommentTitle(comment: comment);
        final subtitle = _CommentSubtitle(comment: comment);
        return comment.replies.isNotEmpty
            ? ExpansionTile(
                title: title,
                subtitle: subtitle,
                initiallyExpanded: !collapsedComments.contains(comment),
                childrenPadding: const EdgeInsets.only(left: 24),
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
                title: title,
                subtitle: subtitle,
              );
      },
    );
  }
}

class _CommentTitle extends StatelessWidget {
  const _CommentTitle({
    required this.comment,
  });

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    return SeparatedRow(
      separatorBuilder: SeparatedRow.dotSeparatorBuilder,
      children: [
        Flexible(
          child: Text(comment.author.isEmpty ? 'Deleted' : comment.author),
        ),
        ScoreTag(score: comment.score),
        if (comment.isSubmitter) const SubmitterTag(),
        if (comment.isEdited) const EditedTag(),
      ],
    );
  }
}

class _CommentSubtitle extends StatelessWidget {
  const _CommentSubtitle({
    required this.comment,
  });

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    if (comment.body.startsWith('https://preview.redd.it/')) {
      return InlineImage(url: comment.body);
    }
    return context.watchPreferences.state.useHtmlForText
        ? HtmlWidget(comment.bodyHtml.trim())
        : Text(comment.body);
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
