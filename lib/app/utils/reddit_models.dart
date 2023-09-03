import 'dart:convert';

/// Data class for the endpoint
///   /subreddits/mine/subscriber
///
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

/// Data class for the endpoint
///   /r/$subreddit/<filter>
class RedditSubmission {
  const RedditSubmission({
    required Map data,
  }) : _data = data;

  final Map _data;

  String get id => _data['id'];

  String get title => _data['title'];

  String get author => _data['author'];

  String get subreddit => _data['subreddit'];

  int get commentCount => _data['num_comments'];

  int get score => _data['score'];

  String get scoreStr => '${score > 0 ? '+' : ''}$score';

  String? get thumbnailUrl {
    return switch (_data['thumbnail']) {
      'default' => null,
      'self' => null,
      'spoiler' => null,
      (String value) => value,
      _ => null,
    };
  }

  bool get isNsfw => _data['over_18'] ?? false;

  bool get isPinned => _data['pinned'] ?? false;

  bool get isStickied => _data['stickied'] ?? false;

  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(
        _data['created_utc'].toInt() * 1000,
        isUtc: true,
      );

  LinkSubmission? get link {
    final url = _data['url']?.toString();
    if (url == null || url.isEmpty) return null;
    return LinkSubmission(url: url);
  }

  SelfSubmission? get self {
    final selfText = _data['selftext']?.toString();
    if (selfText == null || selfText.isEmpty) return null;
    return SelfSubmission(text: selfText);
  }

  GallerySubmission? get gallery {
    final result = <(String, double, double)>[];
    if (_data case {'preview': {'images': List images}}) {
      for (final image in images) {
        if (image
            case {
              'variants': {
                'gif': {
                  'source': {
                    'url': String url,
                    'width': num width,
                    'height': num height,
                  },
                },
              },
            }) {
          result.add((url, width.toDouble(), height.toDouble()));
        } else if (image
            case {
              'source': {
                'url': String url,
                'width': num width,
                'height': num height,
              },
            }) {
          result.add((url, width.toDouble(), height.toDouble()));
        }
      }
    }
    if (_data case {'media_metadata': Map metadata}) {
      for (final entry in metadata.values) {
        if (entry
            case {
              'e': 'Image',
              's': {
                'u': String url,
                'x': num width,
                'y': num height,
              },
            }) {
          result.add((url, width.toDouble(), height.toDouble()));
        }
      }
    }
    return result.isNotEmpty
        ? GallerySubmission(
            images: result,
          )
        : null;
  }

  VideoSubmission? get video {
    if (_data
        case {
          'secure_media': {
            'reddit_video': {
              'hls_url': String dashUrl,
              'width': num width,
              'height': num height,
            },
          }
        }) {
      return VideoSubmission(
        url: dashUrl,
        width: width.toDouble(),
        height: height.toDouble(),
      );
    }
    return null;
  }

  @override
  String toString() => const JsonEncoder.withIndent('    ').convert(_data);
}

class LinkSubmission {
  const LinkSubmission({
    required this.url,
  });

  final String url;
}

class SelfSubmission {
  const SelfSubmission({
    required this.text,
  });

  final String text;
}

class GallerySubmission {
  const GallerySubmission({
    required this.images,
  });

  final List<(String url, double width, double height)> images;
}

class VideoSubmission {
  const VideoSubmission({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;
}
