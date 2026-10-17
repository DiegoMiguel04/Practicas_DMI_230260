import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Keeps YouTube media inside the feed card. Mobile uses an inline WebView;
/// web uses the iframe player. Neither player owns the feed's gestures.
class YoutubeFullScreenPlayer extends StatelessWidget {
  const YoutubeFullScreenPlayer({
    super.key,
    required this.videoId,
    required this.isActive,
  });

  final String videoId;
  final bool isActive;

  @override
  Widget build(BuildContext context) => kIsWeb
      ? _WebYoutubeCard(videoId: videoId, isActive: isActive)
      : _MobileYoutubeCard(videoId: videoId, isActive: isActive);
}

class _MobileYoutubeCard extends StatefulWidget {
  const _MobileYoutubeCard({required this.videoId, required this.isActive});
  final String videoId;
  final bool isActive;

  @override
  State<_MobileYoutubeCard> createState() => _MobileYoutubeCardState();
}

class _MobileYoutubeCardState extends State<_MobileYoutubeCard> {
  WebViewController? _controller;
  String? _loadError;

  @override
  void didUpdateWidget(covariant _MobileYoutubeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _controller != null) {
      _sendPlayerCommand(widget.isActive ? 'playVideo' : 'pauseVideo');
    }
  }

  Future<void> _startPlayback() async {
    if (_controller != null) return;
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.black);
      final platformController = controller.platform;
      if (platformController is AndroidWebViewController) {
        // The user taps TokTik's poster first; allow the embedded YouTube
        // player to autoplay in response instead of exposing a dead second
        // play button inside the pointer-ignored WebView.
        await platformController.setMediaPlaybackRequiresUserGesture(false);
      }
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() => _loadError = error.description);
          },
        ),
      );
      // YouTube requires an app identity in the Referer header for WebViews.
      // Keep this in sync with android/app/build.gradle.kts applicationId.
      const appOrigin = 'https://com.example.toktik_app';
      await controller.loadRequest(
        Uri.https('www.youtube.com', '/embed/${widget.videoId}', {
          'autoplay': '1',
          'mute': '0',
          'playsinline': '1',
          'controls': '0',
          'fs': '0',
          'rel': '0',
          'modestbranding': '1',
          'enablejsapi': '1',
          'origin': appOrigin,
        }),
        headers: const {'Referer': appOrigin},
      );
      if (!mounted) return;
      setState(() => _controller = controller);
      if (!widget.isActive) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await _sendPlayerCommand('pauseVideo');
      }
    } on PlatformException {
      if (mounted) setState(() => _loadError = 'No se pudo iniciar el reproductor.');
    }
  }

  Future<void> _sendPlayerCommand(String command) async {
    try {
      await _controller?.runJavaScript(
        "window.postMessage(JSON.stringify({event:'command',func:'$command',args:[]}), '*');",
      );
    } on PlatformException {
      // The iframe may not have loaded yet while the user is changing cards.
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_loadError != null)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el video de YouTube. Comprueba tu conexión e inténtalo de nuevo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _loadError = null),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        )
      else if (_controller == null)
        _YoutubePoster(videoId: widget.videoId, onPlay: _startPlayback)
      else
        IgnorePointer(
          ignoring: true,
          child: WebViewWidget(controller: _controller!),
        ),
    ],
  );
}

class _WebYoutubeCard extends StatefulWidget {
  const _WebYoutubeCard({required this.videoId, required this.isActive});
  final String videoId;
  final bool isActive;

  @override
  State<_WebYoutubeCard> createState() => _WebYoutubeCardState();
}

class _WebYoutubeCardState extends State<_WebYoutubeCard> {
  YoutubePlayerController? _controller;
  bool _started = false;

  void _startPlayback() {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: false,
        showFullscreenButton: false,
        playsInline: true,
        pointerEvents: PointerEvents.none,
      ),
    );
    setState(() {
      _controller = controller;
      _started = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) controller.playVideo();
    });
  }

  @override
  void didUpdateWidget(covariant _WebYoutubeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (oldWidget.isActive != widget.isActive && controller != null) {
      if (widget.isActive) {
        controller.playVideo();
      } else {
        controller.pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_started)
        IgnorePointer(
          ignoring: true,
          child: YoutubePlayer(
            controller: _controller!,
            aspectRatio: 16 / 9,
            autoFullScreen: false,
            enableFullScreenOnVerticalDrag: false,
          ),
        )
      else
        _YoutubePoster(videoId: widget.videoId, onPlay: _startPlayback),
    ],
  );
}

class _YoutubePoster extends StatelessWidget {
  const _YoutubePoster({required this.videoId, required this.onPlay});
  final String videoId;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFF111116)),
      Image.network(
        'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
      Center(
        child: Material(
          color: const Color(0xFFE62117),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPlay,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42),
            ),
          ),
        ),
      ),
    ],
  );
}
