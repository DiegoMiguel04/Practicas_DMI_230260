import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik_app/presentation/widgets/video/youtube_fullscreen_player.dart';

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
  Offset? _pointerDownPosition;
  int? _activePointer;

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
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _pointerDownPosition = event.position;
        _activePointer = event.pointer;
      },
      onPointerUp: (event) {
        final start = _pointerDownPosition;
        if (!widget.youtube ||
            !kIsWeb ||
            start == null ||
            event.pointer != _activePointer) {
          return;
        }
        _pointerDownPosition = null;
        _activePointer = null;

        final delta = event.position - start;
        if (delta.dy.abs() < 64 || delta.dy.abs() <= delta.dx.abs()) return;
        _goToPage(delta.dy < 0);
      },
      onPointerCancel: (_) {
        _pointerDownPosition = null;
        _activePointer = null;
      },
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: widget.youtube
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          _recordView(widget.videos[index].id);
        },
        itemBuilder: (context, index) {
          final videoPost = widget.videos[index];

          return Stack(
            children: [
              Positioned.fill(
                child: widget.youtube
                    ? YoutubeFullScreenPlayer(
                        key: ValueKey(videoPost.youtubeVideoId),
                        videoId: videoPost.youtubeVideoId!,
                        isActive: index == _currentPage,
                        onVerticalSwipe: _goToPage,
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
                  child: VideoButtons(video: videoPost),
                ),
            ],
          );
        },
      ),
    );
  }

  void _goToPage(bool forward) {
    if (!_pageController.hasClients || widget.videos.isEmpty) return;
    final nextPage = (_currentPage + (forward ? 1 : -1))
        .clamp(0, widget.videos.length - 1)
        .toInt();
    if (nextPage == _currentPage) return;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}
