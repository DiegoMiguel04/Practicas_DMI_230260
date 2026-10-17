import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:toktik_app/domain/entities/video_post.dart';

/// Reads public videos from PeerTube's federated search index.
class PeerTubeVideoDataSource {
  PeerTubeVideoDataSource({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _searchEndpoint =
      Uri.https('search.joinpeertube.org', '/api/v1/search/videos');
  static final Uri _fallbackEndpoint =
      Uri.https('peertube2.cpy.re', '/api/v1/videos');

  final http.Client _client;

  Future<List<VideoPost>> getVideos({int limit = 10}) async {
    // This list must stay mutable because it is shuffled before requests.
    final topics = ['music', 'nature', 'science', 'travel', 'culture'];
    topics.shuffle(Random());
    final results = <VideoPost>[];
    final seen = <String>{};
    Object? lastError;

    // Two short queries provide a varied batch without making a large number
    // of requests to the public index on every app launch.
    for (final topic in topics.take(2)) {
      try {
        final uri = _searchEndpoint.replace(queryParameters: {
          'search': topic,
          'count': '$limit',
          'sort': '-match',
          'nsfw': 'false',
        });
        final response = await _client
            .get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('PeerTube respondió HTTP ${response.statusCode}.');
        }

        final decoded = jsonDecode(response.body);
        final root = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
        final rawVideos = root['data'] ?? root['videos'] ?? root['items'];
        if (rawVideos is! List) {
          throw const FormatException(
            'La API de PeerTube no devolvió una lista en el campo data.',
          );
        }

        for (final raw in rawVideos) {
          if (raw is! Map<String, dynamic>) continue;
          final video = _toVideoPost(raw);
          if (video != null && seen.add(video.id)) results.add(video);
        }
        if (results.length >= limit) break;
      } catch (error) {
        lastError = error;
      }
    }

    // Keep results available when the global search index is temporarily down
    // or has no matches for the selected terms.
    if (results.isEmpty) {
      try {
        final uri = _fallbackEndpoint.replace(queryParameters: {
          'count': '$limit',
          'sort': '-publishedAt',
          'nsfw': 'false',
        });
        final response = await _client
            .get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('PeerTube respondió HTTP ${response.statusCode}.');
        }
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          for (final raw in decoded['data'] as List) {
            if (raw is Map<String, dynamic>) {
              final video = _toVideoPost(raw);
              if (video != null && seen.add(video.id)) results.add(video);
            }
          }
        }
      } catch (error) {
        lastError = error;
      }
    }

    final available = await _filterAvailable(results);
    if (available.isEmpty) {
      throw lastError ??
          StateError('La API pública de PeerTube no encontró videos para el feed.');
    }
    available.shuffle(Random());
    return available.take(limit).toList();
  }

  VideoPost? _toVideoPost(Map<String, dynamic> item) {
    final canonicalUrl = item['url'] as String?;
    final uuid = item['uuid'] as String? ?? item['id']?.toString();
    if (canonicalUrl == null || uuid == null) return null;
    final videoUri = Uri.tryParse(canonicalUrl);
    if (videoUri == null || !videoUri.hasAuthority) return null;

    final embedPath = item['embedPath'] as String?;
    final embedUri = embedPath != null
        ? videoUri.resolve(embedPath)
        : videoUri.resolve('/videos/embed/$uuid');
    final thumbnailPath = item['thumbnailPath'] as String? ??
        item['thumbnailUrl'] as String? ??
        item['thumbnail'] as String?;
    final thumbnail = thumbnailPath == null
        ? null
        : videoUri.resolve(thumbnailPath).toString();
    final account = item['account'] as Map<String, dynamic>?;
    final views = item['views'] as int? ?? 0;
    final likes = item['likes'] as int? ?? 0;

    return VideoPost(
      id: 'peertube:$uuid',
      caption: item['name'] as String? ?? 'Video de PeerTube',
      description: item['description'] as String? ?? '',
      videoUrl: canonicalUrl,
      peerTubeEmbedUrl: embedUri.toString(),
      thumbnailUrl: thumbnail,
      creator: account?['displayName'] as String? ??
          account?['name'] as String? ??
          item['channel']?['displayName'] as String?,
      likes: likes,
      views: views,
    );
  }

  Future<List<VideoPost>> _filterAvailable(List<VideoPost> videos) async {
    final checks = await Future.wait(videos.map((video) async {
      try {
        final origin = Uri.parse(video.videoUrl);
        final uuid = video.id.replaceFirst('peertube:', '');
        final api = Uri(
          scheme: origin.scheme,
          host: origin.host,
          port: origin.hasPort ? origin.port : null,
          path: '/api/v1/videos/$uuid',
        );
        final response = await _client
            .get(api, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 6));
        if (response.statusCode != 200) return false;
        final data = jsonDecode(response.body);
        return data is Map<String, dynamic> && data['isLive'] != true;
      } catch (_) {
        return false;
      }
    }));
    return [
      for (var i = 0; i < videos.length; i++)
        if (checks[i]) videos[i],
    ];
  }
}
