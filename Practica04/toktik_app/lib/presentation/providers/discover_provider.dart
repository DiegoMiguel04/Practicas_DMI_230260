import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toktik_app/config/youtube_config.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/datasources/youtube_video_datasource.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({YoutubeVideoDataSource? dataSource})
      : _dataSource = dataSource ??
            YoutubeVideoDataSource(apiKey: YoutubeConfig.apiKey);

  final YoutubeVideoDataSource _dataSource;
  bool initialLoading = true;
  String? errorMessage;
  List<VideoPost> videos = [];
  bool _hasLoaded = false;

  Future<void> loadVideos() async {
    if (_hasLoaded) return;
    try {
      videos = await _dataSource.getVideos(limit: 10);
      videos.shuffle(Random());
      if (videos.isEmpty) errorMessage = 'No se encontraron videos de YouTube.';
    } catch (error) {
      errorMessage = error.toString();
    }
    _hasLoaded = true;
    initialLoading = false;
    notifyListeners();
  }
}
