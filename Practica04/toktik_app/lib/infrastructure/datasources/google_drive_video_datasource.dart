import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/shared/data/local_video_posts.dart';

class GoogleDriveVideoDataSource {
  GoogleDriveVideoDataSource({
    required this.folderId,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String folderId;
  final String apiKey;
  final http.Client _client;

  Future<List<VideoPost>> getVideos() async {
    if (folderId.isEmpty || apiKey.isEmpty) {
      throw StateError(
        'Configura DRIVE_FOLDER_ID y GOOGLE_DRIVE_API_KEY para cargar videos.',
      );
    }

    final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'q': "'$folderId' in parents and trashed = false",
      'key': apiKey,
      'pageSize': '1000',
      'orderBy': 'name',
      'fields': 'files(id,name,mimeType,resourceKey)',
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Google Drive respondió ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];
    final metadataByFilename = {
      for (final post in videoPosts)
        post['videoUrl'].toString().split('/').last: post,
    };

    final directFiles = files.whereType<Map<String, dynamic>>().toList();
    final videoFiles = directFiles.where(_isVideoFile).toList();
    if (videoFiles.isEmpty) {
      final names = directFiles
          .map((file) => '${file['name']} (${file['mimeType']})')
          .join(', ');
      throw StateError(
        directFiles.isEmpty
            ? 'Drive no devolvió archivos en la carpeta configurada. '
                'Revisa que folderId sea el ID de la carpeta que contiene directamente los MP4.'
            : 'Drive devolvió elementos, pero ninguno parece un video. '
                'Elementos: $names',
      );
    }
    videoFiles.sort((a, b) {
      final aName = a['name'] as String? ?? '';
      final bName = b['name'] as String? ?? '';
      final aNumber = int.tryParse(aName.split('.').first);
      final bNumber = int.tryParse(bName.split('.').first);
      if (aNumber != null && bNumber != null) return aNumber.compareTo(bNumber);
      return aName.compareTo(bName);
    });

    return videoFiles
        .map((file) {
          final id = file['id'] as String;
          final filename = file['name'] as String? ?? 'Video';
          final resourceKey = file['resourceKey'] as String?;
          final metadata = metadataByFilename[filename];
          final url = Uri.https('www.googleapis.com', '/drive/v3/files/$id', {
            'alt': 'media',
            'key': apiKey,
          });
          return VideoPost(
            caption: metadata?['name'] as String? ?? filename,
            videoUrl: url.toString(),
            likes: metadata?['likes'] as int? ?? 0,
            views: metadata?['views'] as int? ?? 0,
            httpHeaders: resourceKey == null
                ? const {}
                : {'X-Goog-Drive-Resource-Keys': '$id/$resourceKey'},
          );
        })
        .toList();
  }

  bool _isVideoFile(Map<String, dynamic> file) {
    final mimeType = (file['mimeType'] as String? ?? '').toLowerCase();
    final name = (file['name'] as String? ?? '').toLowerCase();
    return mimeType.startsWith('video/') ||
        name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.m4v') ||
        name.endsWith('.webm');
  }
}
