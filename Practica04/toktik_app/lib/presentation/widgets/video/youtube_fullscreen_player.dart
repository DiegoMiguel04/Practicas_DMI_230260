import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeFullScreenPlayer extends StatefulWidget {
  const YoutubeFullScreenPlayer({
    super.key,
    required this.videoId,
    required this.isActive,
    required this.onVerticalSwipe,
  });

  final String videoId;
  final bool isActive;
  final ValueChanged<bool> onVerticalSwipe;

  @override
  State<YoutubeFullScreenPlayer> createState() => _YoutubeFullScreenPlayerState();
}

class _YoutubeFullScreenPlayerState extends State<YoutubeFullScreenPlayer> {
  late final YoutubePlayerController _controller;
  late final StreamSubscription<YoutubePlayerValue> _playerSubscription;
  double _verticalDragDistance = 0;
  bool _advancedAfterEnd = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.isActive,
      params: YoutubePlayerParams(
        mute: true,
        showControls: false,
        showFullscreenButton: false,
        playsInline: true,
        strictRelatedVideos: true,
        pointerEvents: kIsWeb ? PointerEvents.none : PointerEvents.auto,
      ),
    );
    _playerSubscription = _controller.listen((value) {
      if (widget.isActive &&
          !_advancedAfterEnd &&
          value.playerState == PlayerState.ended) {
        _advancedAfterEnd = true;
        widget.onVerticalSwipe(true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant YoutubeFullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.playVideo();
      } else {
        _controller.pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playerSubscription.cancel());
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => YoutubePlayer(
        controller: _controller,
        aspectRatio: 9 / 16,
        enableFullScreenOnVerticalDrag: false,
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer()
              ..onStart = (_) {
                _verticalDragDistance = 0;
              }
              ..onUpdate = (details) {
                _verticalDragDistance += details.delta.dy;
              }
              ..onEnd = (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (_verticalDragDistance.abs() >= 45 ||
                    velocity.abs() >= 400) {
                  final delta = _verticalDragDistance.abs() >= 45
                      ? _verticalDragDistance
                      : velocity;
                  widget.onVerticalSwipe(delta < 0);
                }
                _verticalDragDistance = 0;
              },
          ),
        },
      );
}
