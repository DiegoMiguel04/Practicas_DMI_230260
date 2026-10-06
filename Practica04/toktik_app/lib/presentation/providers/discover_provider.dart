import 'package:flutter/material.dart';
import 'package:toktik_app/config/google_drive_config.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/datasources/google_drive_video_datasource.dart';
import 'package:toktik_app/infrastructure/datasources/video_stats_local_storage.dart';

class DiscoverProvider extends ChangeNotifier {
  bool initialLoading = true;
  String? errorMessage;
  List<VideoPost> videos = [];
  final Set<String> likedVideoIds = {};
  final VideoStatsLocalStorage _localStorage = VideoStatsLocalStorage();
  Map<String, Map<String, dynamic>> _savedStats = {};

  final GoogleDriveVideoDataSource _videoDataSource = GoogleDriveVideoDataSource(
    folderId: GoogleDriveConfig.folderId,
    apiKey: GoogleDriveConfig.apiKey,
  );

  Future<void> loadNextPage() async {
    try {
      _savedStats = await _localStorage.readAll();
      final remoteVideos = await _videoDataSource.getVideos();
      final restoredVideos = remoteVideos.map((video) {
        final saved = _savedStats[video.id];
        if (saved?['liked'] == true) likedVideoIds.add(video.id);
        return video.copyWith(
          likes: saved?['likes'] as int? ?? video.likes,
          views: saved?['views'] as int? ?? video.views,
        );
      });
      videos = restoredVideos.where((video) => video.views >= video.likes).toList();
      errorMessage = videos.isEmpty ? 'No se encontraron videos en la carpeta.' : null;
    } catch (error) {
      errorMessage = error.toString();
    }
    initialLoading = false;
    notifyListeners();
  }

  Future<void> recordView(String videoId) async {
    final index = videos.indexWhere((video) => video.id == videoId);
    if (index == -1) return;
    if (_savedStats[videoId]?['viewed'] == true) return;
    final video = videos[index].copyWith(views: videos[index].views + 1);
    videos[index] = video;
    _savedStats[videoId] = {
      ...?_savedStats[videoId],
      'viewed': true,
    };
    await _saveStats(video);
    notifyListeners();
  }

  Future<void> toggleLike(String videoId) async {
    final index = videos.indexWhere((video) => video.id == videoId);
    if (index == -1) return;
    final wasLiked = likedVideoIds.contains(videoId);
    if (wasLiked) {
      likedVideoIds.remove(videoId);
    } else {
      likedVideoIds.add(videoId);
    }
    final video = videos[index].copyWith(
      likes: videos[index].likes + (wasLiked ? -1 : 1),
    );
    videos[index] = video;
    await _saveStats(video);
    notifyListeners();
  }

  Future<void> _saveStats(VideoPost video) async {
    _savedStats[video.id] = {
      'likes': video.likes,
      'views': video.views,
      'liked': likedVideoIds.contains(video.id),
      'viewed': _savedStats[video.id]?['viewed'] == true,
    };
    await _localStorage.writeAll(_savedStats);
  }
}
