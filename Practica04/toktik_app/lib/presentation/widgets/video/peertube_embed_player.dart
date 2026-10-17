import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Inline PeerTube player that stays inside the feed card and leaves vertical
/// gestures available to the feed's PageView.
class PeerTubeEmbedPlayer extends StatefulWidget {
  const PeerTubeEmbedPlayer({
    super.key,
    required this.embedUrl,
    required this.isActive,
    this.thumbnailUrl,
  });

  final String embedUrl;
  final bool isActive;
  final String? thumbnailUrl;

  @override
  State<PeerTubeEmbedPlayer> createState() => _PeerTubeEmbedPlayerState();
}

class _PeerTubeEmbedPlayerState extends State<PeerTubeEmbedPlayer> {
  WebViewController? _controller;
  String? _error;

  @override
  void didUpdateWidget(covariant PeerTubeEmbedPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _controller != null) {
      _runVideoCommand(widget.isActive ? 'play' : 'pause');
    }
  }

  Future<void> _play() async {
    if (_controller != null) return;
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.black);
      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        await platform.setMediaPlaybackRequiresUserGesture(false);
      }
      await controller.setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          if (mounted && error.isForMainFrame != false) {
            setState(() => _error = error.description);
          }
        },
      ));
      final uri = Uri.parse(widget.embedUrl).replace(queryParameters: {
        ...Uri.parse(widget.embedUrl).queryParameters,
        'autoplay': '1',
        'controls': '1',
        'muted': '0',
        'p2p': '0',
      });
      await controller.loadRequest(uri);
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo iniciar el reproductor PeerTube.');
    }
  }

  Future<void> _runVideoCommand(String command) async {
    try {
      await _controller?.runJavaScript(
        "document.querySelector('video')?.$command();",
      );
    } catch (_) {
      // The video element might not be ready while the user scrolls.
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          if (_error != null)
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('No se pudo cargar este video de PeerTube.',
                    style: TextStyle(color: Colors.white70)),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _error = null);
                    _controller?.reload();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ]),
            )
          else if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            _Poster(thumbnailUrl: widget.thumbnailUrl, onPlay: _play),
        ],
      );
}

class _Poster extends StatelessWidget {
  const _Poster({required this.thumbnailUrl, required this.onPlay});
  final String? thumbnailUrl;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF111116)),
          if (thumbnailUrl != null)
            Image.network(
              thumbnailUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Center(
            child: Material(
              color: const Color(0xFF159B84),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlay,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 42),
                ),
              ),
            ),
          ),
        ],
      );
}
