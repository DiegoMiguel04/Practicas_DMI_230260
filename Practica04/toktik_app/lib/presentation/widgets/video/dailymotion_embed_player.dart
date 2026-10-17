import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DailymotionEmbedPlayer extends StatefulWidget {
  const DailymotionEmbedPlayer({super.key, required this.playerId, required this.videoId, required this.isActive, this.thumbnailUrl});
  final String playerId;
  final String videoId;
  final bool isActive;
  final String? thumbnailUrl;

  @override
  State<DailymotionEmbedPlayer> createState() => _DailymotionEmbedPlayerState();
}

class _DailymotionEmbedPlayerState extends State<DailymotionEmbedPlayer> {
  WebViewController? _controller;
  String? _error;

  Future<void> _play() async {
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.black);
      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      }
      await controller.setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          debugPrint(
            'Dailymotion WebView: ${error.errorCode} ${error.description}; '
            'url=${error.url ?? 'desconocida'}; mainFrame=${error.isForMainFrame}',
          );
          if (mounted && error.isForMainFrame != false) {
            setState(() => _error = error.description);
          }
        },
      ));
      final uri = Uri.https(
        'geo.dailymotion.com',
        '/player/${widget.playerId}.html',
        {
          'video': widget.videoId,
          // The user tapped TokTik's play button, so let the official player
          // start playback from that interaction.
          'autoplay': 'true',
        },
      );
      await controller.loadRequest(uri);
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo iniciar el reproductor de Dailymotion.');
    }
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    if (_error != null)
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('No se pudo cargar este video de Dailymotion.', style: TextStyle(color: Colors.white70)),
        TextButton.icon(onPressed: () { setState(() => _error = null); _controller?.reload(); }, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
      ]))
    else if (_controller != null)
      WebViewWidget(controller: _controller!)
    else
      Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Color(0xFF111116)),
        if (widget.thumbnailUrl != null) Image.network(widget.thumbnailUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        Center(child: Material(color: const Color(0xFF0066DC), shape: const CircleBorder(), child: InkWell(onTap: _play, customBorder: const CircleBorder(), child: const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42))))),
      ]),
  ]);
}
