import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik_app/domain/entities/video_post.dart';

class YoutubeVideoDataSource {
  YoutubeVideoDataSource({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  Future<List<VideoPost>> getVideos({int limit = 10}) async {
    if (apiKey.isEmpty) {
      throw StateError(
        'Configura la API key en lib/config/youtube_config.dart para cargar Descubrir.',
      );
    }

    final searchUri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'key': apiKey,
      'q': 'shorts',
      'type': 'video',
      'videoEmbeddable': 'true',
      'videoDuration': 'short',
      'maxResults': '$limit',
      'safeSearch': 'moderate',
    });
    final searchResponse = await _client.get(searchUri);
    if (searchResponse.statusCode != 200) {
      throw Exception(
        'YouTube Search returned ${searchResponse.statusCode}: '
        '${searchResponse.body}',
      );
    }

    final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final items = searchData['items'] as List<dynamic>? ?? [];
    final ids = items
        .whereType<Map<String, dynamic>>()
        .map((item) => item['id']?['videoId'] as String?)
        .whereType<String>()
        .toList();
    if (ids.isEmpty) return [];

    // Search's "short" filter means under four minutes. Keep videos of up to
    // three minutes as closer candidates for Shorts; the API does not expose
    // a definitive Shorts classification or aspect-ratio search filter.
    final detailsUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'contentDetails',
      'key': apiKey,
      'id': ids.join(','),
    });
    final detailsResponse = await _client.get(detailsUri);
    if (detailsResponse.statusCode != 200) {
      throw Exception(
        'YouTube Videos returned ${detailsResponse.statusCode}: '
        '${detailsResponse.body}',
      );
    }
    final detailsData = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
    final durations = <String, int>{};
    for (final item in detailsData['items'] as List<dynamic>? ?? []) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['id'] as String?;
      final duration = item['contentDetails']?['duration'] as String?;
      if (id != null && duration != null) durations[id] = _durationSeconds(duration);
    }

    return items.whereType<Map<String, dynamic>>().map((item) {
      final id = item['id']?['videoId'] as String?;
      if (id == null || (durations[id] ?? 999999) > 180) return null;
      final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
      return VideoPost(
        id: 'youtube:$id',
        youtubeVideoId: id,
        caption: snippet['title'] as String? ?? 'Video de YouTube',
        description: snippet['description'] as String? ?? '',
        videoUrl: 'https://www.youtube.com/watch?v=$id',
      );
    }).whereType<VideoPost>().toList();
  }

  int _durationSeconds(String value) {
    final match = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$')
        .firstMatch(value);
    if (match == null) return 0;
    return (int.tryParse(match[1] ?? '') ?? 0) * 3600 +
        (int.tryParse(match[2] ?? '') ?? 0) * 60 +
        (int.tryParse(match[3] ?? '') ?? 0);
  }
}
