import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

/// Provides core functionality for a [Cubit] that relies on the reddit api.
abstract class RedditCubit<S> extends Cubit<S> {
  RedditCubit(
    super.initialState, {
    required AuthCubit authCubit,
    required this.redditApi,
  }) : _authCubit = authCubit;

  final AuthCubit _authCubit;
  final RedditApi redditApi;

  String get accessToken {
    final accessToken = _authCubit.state.accessToken;
    if (accessToken == null) {
      throw Exception('invalid access token');
    }
    return accessToken;
  }
}
