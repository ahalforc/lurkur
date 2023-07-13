import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/reddit/submission_cubit.dart';
import 'package:lurkur/app/widgets/indicators.dart';

class CommentsTree extends StatelessWidget {
  const CommentsTree({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionCubit, SubmissionState>(
      builder: (context, state) {
        return switch (state) {
          (Loading _) => const _Loading(),
          (LoadingFailed _) => const _LoadingFailed(),
          (Loaded loaded) => _Loaded(state: loaded),
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= state.comments.length) return null;

          final comment = state.comments[index];
          return Text(comment.toString());
        },
      ),
    );
  }
}
