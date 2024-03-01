import 'dart:convert';

/// Data class for the endpoint
///   /r/$subreddit/about
class RedditSubreddit {
  const RedditSubreddit({
    required Map data,
  }) : _data = data;

  final Map _data;

  String? get headerImageUrl => _data['data']['mobile_banner_image'];

  @override
  String toString() => const JsonEncoder.withIndent('    ').convert(_data);
}
