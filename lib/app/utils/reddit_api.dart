import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lurkur/app/utils/reddit_models.dart';

class RedditApi {
  static const _baseOauthUrl = 'https://oauth.reddit.com';

  /// Returns a list of subreddits the user has subscribed to.
  Future<List<RedditSubscription>> getSubscriptions({
    required String accessToken,
  }) async {
    final data = await _get(
      accessToken,
      '$_baseOauthUrl/subreddits/mine/subscriber',
    );
    final result = <RedditSubscription>[];
    if (data case {'data': {'children': List<dynamic> children}}) {
      for (var {'data': Map data} in children) {
        result.add(
          RedditSubscription(data: data),
        );
      }
    }
    return result;
  }

  /// Returns a list of submissions for a given subreddit.
  Future<List<RedditSubmission>> getSubmissions({
    required String accessToken,
    required String? subreddit,
    required String sort,
  }) async {
    final data = await _get(
      accessToken,
      subreddit == null
          ? '$_baseOauthUrl?raw_json=1'
          : '$_baseOauthUrl/r/$subreddit/hot?raw_json=1',
    );
    final result = <RedditSubmission>[];
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
      for (var {'data': Map data} in children) {
        result.add(
          RedditSubmission(data: data),
        );
      }
    }
    return result;
  }

  /// Returns a starting level tree of comments for a submission.
  Future<List<RedditComment>> getComments({
    required String accessToken,
    required String subreddit,
    required String submissionId,
  }) async {
    final data = await _get(
      accessToken,
      '$_baseOauthUrl/r/$subreddit/comments/$submissionId?raw_json=1',
    );
    print(const JsonEncoder.withIndent('    ').convert(data));
    final result = <RedditComment>[];
    return result;
  }

  Future<dynamic> _get(String accessToken, String url) async {
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
}
