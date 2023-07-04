import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lurkur/app/blocs/auth_cubit.dart';

class RedditApi {
  static const _baseOauthUrl = 'https://oauth.reddit.com';

  /// Returns a list of subreddits the user has subscribed to.
  Future<List<RedditSubscription>> getSubscriptions(
    BuildContext context,
  ) async {
    final data = await _get(
      context,
      '$_baseOauthUrl/subreddits/mine/subscriber',
    );
    final result = <RedditSubscription>[];
    if (data case {'data': {'children': List<dynamic> children}}) {
      for (var {
            'data': {
              'title': String title,
              'display_name': String displayName,
            }
          } in children) {
        result.add(
          RedditSubscription(
            displayName: displayName,
            title: title,
          ),
        );
      }
    }
    return result;
  }

  /// Returns a list of posts for a given subreddit.
  ///
  /// todo maybe accept a [RedditSubscription] as an input
  Future<List<RedditPost>> getPosts(
    BuildContext context, {
    required String? subreddit,
  }) async {
    final data = await _get(
      context,
      subreddit == null ? _baseOauthUrl : '$_baseOauthUrl/r/$subreddit/hot',
    );
    final result = <RedditPost>[];
    if (data
        case {
          'data': {
            'before': String? before,
            'after': String? after,
            // 'count': int? count,
            // 'limit': int? limit,
            'children': List<dynamic> children,
          },
        }) {
      print('JOEY - before: $before');
      print('JOEY - after: $after');
      // print('JOEY - count: $count');
      // print('JOEY - limit: $limit');
      print(jsonEncode(children[4]));
      for (var {
            'data': {
              'title': String title,
              'subreddit': String subreddit,
              'num_comments': int commentCount,
              'created_utc': double createdUtc,
              'thumbnail': String? thumbnailUrl,
              'score': int score,
            }
          } in children) {
        result.add(
          // todo look into using "preview" instead of "thumbnail"
          RedditPost(
            title: title,
            author: 'Omnidroid',
            subreddit: subreddit,
            commentCount: commentCount,
            createdUtc: createdUtc,
            thumbnailUrl: thumbnailUrl,
            score: score,
          ),
        );
      }
    }
    return result;
  }

  Future<dynamic> _get(BuildContext context, String url) async {
    final accessToken = await _getAccessToken(context);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('todo joey bad status code');
    }
    return jsonDecode(response.body);
  }

  Future<String> _getAccessToken(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authorized) {
      return authState.accessToken;
    }
    throw Exception('todo joey get the damn access token');
  }
}

class RedditSubscription {
  const RedditSubscription({
    required this.displayName,
    required this.title,
  });

  final String displayName;
  final String title;
}

class RedditPost {
  const RedditPost({
    required this.title,
    required this.author,
    required this.subreddit,
    required this.commentCount,
    required this.createdUtc,
    required this.thumbnailUrl,
    required this.score,
  });

  final String title;
  final String author;
  final String subreddit;
  final int commentCount;
  final double createdUtc;
  final String? thumbnailUrl;
  final int score;

  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(
        createdUtc.toInt() * 1000,
        isUtc: true,
      );
}
