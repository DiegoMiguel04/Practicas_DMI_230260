import 'package:flutter/material.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik_app/presentation/widgets/video/youtube_fullscreen_player.dart';
import 'package:toktik_app/presentation/widgets/video/peertube_embed_player.dart';
import 'package:toktik_app/presentation/widgets/video/dailymotion_embed_player.dart';
import 'package:toktik_app/config/dailymotion_config.dart';
import 'package:toktik_app/config/theme/season_theme.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final bool youtube;

  const VideoScrollableView({super.key, required this.videos, this.youtube = false});

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.videos.isNotEmpty) {
        _recordView(widget.videos.first.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _recordView(String videoId) {
    if (!widget.youtube) context.read<ForYouProvider>().recordView(videoId);
  }

  @override
  void didUpdateWidget(covariant VideoScrollableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videos != widget.videos && widget.videos.isNotEmpty) {
      _currentPage = _currentPage.clamp(0, widget.videos.length - 1).toInt();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _recordView(widget.videos[_currentPage].id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _recordView(widget.videos[index].id);
        },
        itemBuilder: (context, index) {
          final videoPost = widget.videos[index];
          final isYoutube = videoPost.youtubeVideoId != null;
          final isPeerTube = videoPost.peerTubeEmbedUrl != null;
          final isDailymotion = videoPost.dailymotionVideoId != null;

          return Stack(
            children: [
              Positioned.fill(
                child: isYoutube
                    ? YoutubeFullScreenPlayer(
                        key: ValueKey(videoPost.youtubeVideoId),
                        videoId: videoPost.youtubeVideoId!,
                        isActive: index == _currentPage,
                      )
                    : isPeerTube
                        ? PeerTubeEmbedPlayer(
                            key: ValueKey(videoPost.peerTubeEmbedUrl),
                            embedUrl: videoPost.peerTubeEmbedUrl!,
                            thumbnailUrl: videoPost.thumbnailUrl,
                            isActive: index == _currentPage,
                          )
                        : isDailymotion
                            ? DailymotionEmbedPlayer(
                                key: ValueKey(videoPost.dailymotionVideoId),
                                playerId: DailymotionConfig.playerId,
                                videoId: videoPost.dailymotionVideoId!,
                                thumbnailUrl: videoPost.thumbnailUrl,
                                isActive: index == _currentPage,
                              )
                        : FullScreenPlayer(
                        caption: videoPost.caption,
                        description: videoPost.description,
                        videoUrl: videoPost.videoUrl,
                        httpHeaders: videoPost.httpHeaders,
                      ),
              ),
              if (!widget.youtube)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: VideoButtons(key: ValueKey('drive-${videoPost.id}'), video: videoPost),
                ),
              if (widget.youtube)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: VideoButtons(
                    key: ValueKey('youtube-${videoPost.id}'),
                    video: videoPost,
                    youtube: true,
                  ),
                ),
              if (widget.youtube)
                Positioned(
                  left: 20,
                  right: 86,
                  bottom: 48,
                  child: _DiscoverCaption(videoPost: videoPost),
                ),
            ],
          );
        },
      );
  }

}

class _DiscoverCaption extends StatelessWidget {
  const _DiscoverCaption({required this.videoPost});
  final VideoPost videoPost;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
          decoration: BoxDecoration(
          color: videoPost.peerTubeEmbedUrl != null
              ? const Color(0xFF159B84)
              : videoPost.dailymotionVideoId != null
                  ? const Color(0xFF0066DC)
                  : const Color(0xFFE62117),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 3),
            Text(
              videoPost.peerTubeEmbedUrl != null
                  ? 'PEERTUBE'
                  : videoPost.dailymotionVideoId != null ? 'DAILYMOTION' : 'YOUTUBE',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      if (videoPost.creator != null) ...[
        Text(videoPost.creator!, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 7)])),
        const SizedBox(height: 3),
      ],
      Text(videoPost.caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black87, blurRadius: 8)])),
      if (videoPost.description.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(videoPost.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 7)])),
      ],
    ],
  );
}
