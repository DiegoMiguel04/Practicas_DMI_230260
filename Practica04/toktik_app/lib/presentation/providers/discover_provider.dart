import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik_app/config/dailymotion_config.dart';
import 'package:toktik_app/config/youtube_config.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/datasources/dailymotion_video_datasource.dart';
import 'package:toktik_app/infrastructure/datasources/peertube_video_datasource.dart';
import 'package:toktik_app/infrastructure/datasources/youtube_video_datasource.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({
    YoutubeVideoDataSource? dataSource,
    PeerTubeVideoDataSource? peerTubeDataSource,
    DailymotionVideoDataSource? dailymotionDataSource,
  })  : _dataSource = dataSource ?? YoutubeVideoDataSource(apiKey: YoutubeConfig.apiKey),
        _peerTubeDataSource = peerTubeDataSource ?? PeerTubeVideoDataSource(),
        _dailymotionDataSource = dailymotionDataSource ??
            DailymotionVideoDataSource(playerId: DailymotionConfig.playerId);

  final YoutubeVideoDataSource _dataSource;
  final PeerTubeVideoDataSource _peerTubeDataSource;
  final DailymotionVideoDataSource _dailymotionDataSource;
  bool initialLoading = true;
  String? errorMessage;
  List<VideoPost> videos = [];
  bool _hasLoaded = false;

  Future<void> loadVideos() async {
    if (_hasLoaded) return;
    final results = await Future.wait([
      _loadSource('YouTube', _dataSource.getVideos(limit: 8)),
      _loadSource('PeerTube', _peerTubeDataSource.getVideos(limit: 8)),
      _loadSource('Dailymotion', _dailymotionDataSource.getVideos(limit: 8)),
    ]);
    for (final source in results) { source.shuffle(Random()); }
    videos = _mixSources(results);
    debugPrint('Descubrir: YouTube ${results[0].length}, PeerTube ${results[1].length}, Dailymotion ${results[2].length}.');
    if (videos.isEmpty) {
      errorMessage = 'No se pudieron cargar videos de YouTube, PeerTube ni Dailymotion. Comprueba tu conexión e inténtalo de nuevo.';
    }
    _hasLoaded = true;
    initialLoading = false;
    notifyListeners();
  }

  List<VideoPost> _mixSources(List<List<VideoPost>> sourceVideos) {
    final sources = sourceVideos.map((source) => List<VideoPost>.of(source)).toList();
    final mixed = <VideoPost>[];
    int? previousSource;
    var consecutive = 0;
    while (sources.any((source) => source.isNotEmpty)) {
      final nonEmpty = [for (var i = 0; i < sources.length; i++) if (sources[i].isNotEmpty) i];
      var choices = nonEmpty.where((i) => consecutive < 3 || i != previousSource || nonEmpty.length == 1).toList();
      if (choices.isEmpty) choices = nonEmpty;
      final source = choices[Random().nextInt(choices.length)];
      mixed.add(sources[source].removeLast());
      consecutive = source == previousSource ? consecutive + 1 : 1;
      previousSource = source;
    }
    return mixed;
  }

  Future<List<VideoPost>> _loadSource(String name, Future<List<VideoPost>> request) async {
    try {
      return await request;
    } catch (error) {
      debugPrint('Error cargando videos de $name: $error');
      return const [];
    }
  }
}
