import 'dart:convert';

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
    return SelfSubmission(
      text: selfText,
      textHtml: _data['selftext_html']?.toString(),
    );
  }

  GallerySubmission? get gallery {
    final result = <GalleryImage>[];
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
          result.add(
            GalleryImage(
              url: url,
              width: width.toDouble(),
              height: height.toDouble(),
            ),
          );
        } else if (image
            case {
              'source': {
                'url': String url,
                'width': num width,
                'height': num height,
              },
            }) {
          result.add(
            GalleryImage(
              url: url,
              width: width.toDouble(),
              height: height.toDouble(),
            ),
          );
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
              'id': String id,
            }) {
          result.add(
            GalleryImage(
              id: id,
              url: url,
              width: width.toDouble(),
              height: height.toDouble(),
            ),
          );
        }
      }
    }

    // If this is a gallery, then omit all other media entries that don't
    // exist in the gallery list items.
    if (_data case {'gallery_data': {'items': List items}}) {
      final galleryIds = <String>[];
      for (final item in items) {
        if (item case {'media_id': String id}) {
          galleryIds.add(id);
        }
      }
      return GallerySubmission(
        images: galleryIds
            .map((id) => result.firstWhere((image) => image.id == id))
            .toList(),
      );
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
    } else if (_data
        case {
          'preview': {
            'reddit_video_preview': {
              // hls_url doesn't seem to work
              'fallback_url': String url,
              'width': num width,
              'height': num height,
            },
          },
        }) {
      return VideoSubmission(
        url: url,
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
    this.textHtml,
  });

  final String text;
  final String? textHtml;
}

class GallerySubmission {
  const GallerySubmission({
    required this.images,
  });

  final List<GalleryImage> images;
}

class GalleryImage {
  const GalleryImage({
    this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  final String? id;
  final String url;
  final double width, height;
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

  double get aspectRatio => width / height;
}
