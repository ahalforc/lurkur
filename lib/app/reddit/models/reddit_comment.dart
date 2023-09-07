/// Data class for the endpoint
///   /r/$subreddit/comments/$submissionId?raw_json=1
class RedditComment {
  const RedditComment({
    required Map data,
  }) : _data = data;

  final Map _data;

  String get author => _data['author'] ?? '';

  int get score => _data['score'] ?? 0;

  String get body => _data['body'] ?? '';

  bool get isEdited {
    final edited = _data['edited'];
    if (edited is bool) return edited;
    if (edited is num) return true;
    return false;
  }

  bool get isSubmitter => _data['is_submitter'] ?? false;

  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(
        _data['created_utc'].toInt() * 1000,
        isUtc: true,
      );

  List<RedditComment> get replies {
    final result = <RedditComment>[];
    if (_data['replies'] case {'data': {'children': List children}}) {
      for (final child in children) {
        if (child case {'data': Map data}) {
          result.add(RedditComment(data: data));
        }
      }
    }
    return result;
  }
}
