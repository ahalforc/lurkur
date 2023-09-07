import 'dart:convert';

/// Data class for the endpoint
///   /subreddits/mine/subscriber
class RedditSubscription {
  const RedditSubscription({
    required Map data,
  }) : _data = data;

  final Map _data;

  String get displayName => _data['display_name'] ?? '';

  String get title => _data['title'] ?? '';

  @override
  String toString() => const JsonEncoder.withIndent('    ').convert(_data);
}
