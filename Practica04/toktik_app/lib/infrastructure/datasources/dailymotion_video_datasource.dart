import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:toktik_app/config/dailymotion_config.dart';
import 'package:toktik_app/domain/entities/video_post.dart';

/// Busca videos públicos con la Platform API clásica de Dailymotion.
class DailymotionVideoDataSource {
  DailymotionVideoDataSource({
    this.playerId = DailymotionConfig.playerId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String playerId;
  final http.Client _client;

  Future<List<VideoPost>> getVideos({int limit = 8}) async {
    final terms = ['music', 'travel', 'nature', 'science', 'culture']..shuffle(Random());
    final videos = <VideoPost>[];
    final seen = <String>{};
    Object? lastError;
    for (final term in terms.take(2)) {
      try {
        final uri = Uri.https('api.dailymotion.com', '/videos', {
          'search': term,
          'fields': 'id,title,description,thumbnail_720_url,owner.screenname,views_total,channel',
          'limit': '$limit',
          'sort': 'relevance',
          'family_filter': 'true',
        });
        final response = await _client.get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('Dailymotion respondió HTTP ${response.statusCode}.');
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic> || decoded['list'] is! List) {
          throw const FormatException('Respuesta de búsqueda de Dailymotion inválida.');
        }
        for (final raw in decoded['list'] as List) {
          if (raw is! Map<String, dynamic>) continue;
          final video = _toVideo(raw);
          if (video != null && seen.add(video.id)) videos.add(video);
        }
        if (videos.length >= limit) break;
      } catch (error) {
        lastError = error;
      }
    }
    if (videos.isEmpty) throw lastError ?? StateError('Dailymotion no encontró videos.');
    videos.shuffle(Random());
    return videos.take(limit).toList();
  }

  VideoPost? _toVideo(Map<String, dynamic> item) {
    final id = item['id'] as String?;
    if (id == null || id.isEmpty) return null;
    return VideoPost(
      id: 'dailymotion:$id',
      dailymotionVideoId: id,
      caption: item['title'] as String? ?? 'Video de Dailymotion',
      description: item['description'] as String? ?? '',
      videoUrl: 'https://www.dailymotion.com/video/$id',
      thumbnailUrl: item['thumbnail_720_url'] as String?,
      creator: item['owner.screenname'] as String?,
      views: item['views_total'] as int? ?? 0,
    );
  }
}
