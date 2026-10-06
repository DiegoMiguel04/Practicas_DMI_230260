import 'package:flutter/material.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;

  const VideoScrollableView({super.key, required this.videos});

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.videos.isNotEmpty) {
        _recordView(widget.videos.first.id);
      }
    });
  }

  void _recordView(String videoId) {
    context.read<DiscoverProvider>().recordView(videoId);
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
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        _currentPage = index;
        _recordView(widget.videos[index].id);
      },
      itemBuilder: (context, index) {
        final videoPost = widget.videos[index];

        return Stack(
          children: [
            SizedBox.expand(
              child: FullScreenPlayer(
                caption: videoPost.caption,
                description: videoPost.description,
                videoUrl: videoPost.videoUrl,
                httpHeaders: videoPost.httpHeaders,
              ),
            ),
            Positioned(
              bottom: 40,
              right: 20,
              child: VideoButtons(video: videoPost),
            ),
          ],
        );
      },
    );
  }
}
