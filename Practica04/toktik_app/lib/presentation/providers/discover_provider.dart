import 'package:flutter/material.dart';
import 'package:toktik_app/config/google_drive_config.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/datasources/google_drive_video_datasource.dart';

class DiscoverProvider extends ChangeNotifier {
  bool initialLoading = true;
  String? errorMessage;
  List<VideoPost> videos = [];

  final GoogleDriveVideoDataSource _videoDataSource = GoogleDriveVideoDataSource(
    folderId: GoogleDriveConfig.folderId,
    apiKey: GoogleDriveConfig.apiKey,
  );

  Future<void> loadNextPage() async {
    try {
      videos = await _videoDataSource.getVideos();
      errorMessage = videos.isEmpty ? 'No se encontraron videos en la carpeta.' : null;
    } catch (error) {
      errorMessage = error.toString();
    }
    initialLoading = false;
    notifyListeners();
  }
}
