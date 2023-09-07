import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lurkur/app/reddit/reddit.dart';

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

  /// Returns a record of
  ///   "after" - the pagination key
  ///   "submissions" - the parsed json list of submissions for the current page
  ///
  /// [accessToken] is the oauth token for this user
  /// [subreddit] is the display name of a subreddit (like r/popular)
  /// [sort] is the sort option (like hot or top)
  /// [after] is the serialized key reddit uses to paginate its listings
  /// [count] is how many results you've shown the user so far
  /// [t] is the query parameter for what kind of "top" sort option to show
  Future<(String, List<RedditSubmission>)> getSubmissions({
    required String accessToken,
    required String? subreddit,
    required String sort,
    required String? after,
    required int? count,
    required String? t,
  }) async {
    final url = StringBuffer(_baseOauthUrl);
    if (subreddit != null) url.write('/r/$subreddit/$sort');
    url.write('?raw_json=1');
    if (after != null) url.write('&after=$after');
    if (count != null) url.write('&count=$count');
    if (t != null) url.write('&t=$t');

    final data = await _get(
      accessToken,
      url.toString(),
    );

    var newAfter = '';
    final newSubmissions = <RedditSubmission>[];
    if (data
        case {
          'data': {
            'after': String after,
            'children': List<dynamic> children,
          },
        }) {
      newAfter = after;
      for (var {'data': Map data} in children) {
        newSubmissions.add(
          RedditSubmission(data: data),
        );
      }
    }
    return (newAfter, newSubmissions);
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
    final result = <RedditComment>[];
    if (data is Iterable) {
      for (final entry in data) {
        if (entry case {'data': {'children': List children}}) {
          for (final child in children) {
            if (child case {'kind': 't1', 'data': Map innerData}) {
              result.add(RedditComment(data: innerData));
            }
          }
        }
      }
    }
    return result;
  }

  Future<dynamic> _get(
    String accessToken,
    String url,
  ) async {
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
