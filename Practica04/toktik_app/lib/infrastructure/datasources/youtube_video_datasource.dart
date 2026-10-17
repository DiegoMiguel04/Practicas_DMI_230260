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
      'q': 'videos',
      'type': 'video',
      'videoEmbeddable': 'true',
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
    final playableItems = items.whereType<Map<String, dynamic>>().where((item) =>
        item['id']?['videoId'] is String).toList();

    return playableItems.indexed.map((entry) {
      final (index, item) = entry;
      final id = item['id']?['videoId'] as String;
      final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
      return VideoPost(
        id: 'youtube:$id',
        youtubeVideoId: id,
        caption: snippet['title'] as String? ?? 'Video de YouTube',
        description: snippet['description'] as String? ?? '',
        videoUrl: 'https://www.youtube.com/watch?v=$id',
        // Search does not return engagement totals, so use stable demo figures.
        likes: 1840 + index * 637,
        views: 12600 + index * 4381,
      );
    }).toList();
  }

}
