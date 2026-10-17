import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toktik_app/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final String description;
  final Map<String, String> httpHeaders;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    required this.description,
    this.httpHeaders = const {},
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late final VideoPlayerController controller;
  late final Future<void> _initialization;
  bool _isPaused = false;
  bool _showPlayIcon = false;
  String? _loadError;
  Timer? _playIconTimer;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: widget.httpHeaders,
    )
      ..setLooping(true);
    _initialization = _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await controller.initialize();
      await controller.setVolume(1);
      await controller.play();
    } catch (_) {
      final message = await _diagnoseLoadError();
      if (mounted) setState(() => _loadError = message);
    }
  }

  Future<String> _diagnoseLoadError() async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(widget.videoUrl))
        ..headers.addAll(widget.httpHeaders)
        ..headers['Range'] = 'bytes=0-0';
      final response = await client.send(request);
      final body = StringBuffer();
      var bytesRead = 0;
      await for (final chunk in response.stream) {
        final remaining = 8192 - bytesRead;
        if (remaining <= 0) break;
        final bytesToAdd = chunk.length > remaining
            ? chunk.sublist(0, remaining)
            : chunk;
        body.write(utf8.decode(bytesToAdd, allowMalformed: true));
        bytesRead += bytesToAdd.length;
        if (bytesRead >= 8192) break;
      }

      final reason = _driveErrorReason(body.toString());
      if (response.statusCode == 403 || response.statusCode == 429) {
        if (_isQuotaReason(reason)) {
          return 'No se pudo reproducir este video: Google Drive indicó que se alcanzó un límite de cuota o solicitudes ($reason). Inténtalo más tarde.';
        }
        if (reason == 'downloadQuotaExceeded') {
          return 'No se pudo reproducir este video: Google Drive alcanzó el límite temporal de descargas de este archivo. Inténtalo más tarde.';
        }
        return 'Google Drive rechazó la descarga (HTTP ${response.statusCode}${reason == null ? '' : ', $reason'}). Revisa que el archivo permita acceso y descarga mediante el enlace configurado.';
      }
      if (response.statusCode == 401) {
        return 'No se pudo reproducir el video: Google Drive rechazó la API key (HTTP 401).';
      }
      if (response.statusCode == 404) {
        return 'No se encontró el archivo en Google Drive (HTTP 404); revisa su ID y permisos.';
      }
      return 'No se pudo cargar el video desde Google Drive (HTTP ${response.statusCode}). Comprueba la conexión y el acceso al archivo.';
    } catch (_) {
      return 'No se pudo cargar el video de Google Drive. Comprueba la conexión y que el archivo sea accesible.';
    } finally {
      client.close();
    }
  }

  String? _driveErrorReason(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) return null;
      final errors = error['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final reason = (errors.first as Map)['reason'];
        if (reason is String) return reason;
      }
      final status = error['status'];
      return status is String ? status : null;
    } on FormatException {
      return null;
    }
  }

  bool _isQuotaReason(String? reason) => const {
    'dailyLimitExceeded',
    'quotaExceeded',
    'rateLimitExceeded',
    'userRateLimitExceeded',
  }.contains(reason);

  @override
  void dispose() {
    _playIconTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (_loadError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        return GestureDetector(
          onTap: () {
            if (!_isPaused) {
              controller.pause();
              _playIconTimer?.cancel();
              setState(() {
                _isPaused = true;
                _showPlayIcon = false;
              });
            } else {
              controller.play();
              setState(() {
                _isPaused = false;
                _showPlayIcon = true;
              });
              _playIconTimer?.cancel();
              _playIconTimer = Timer(const Duration(milliseconds: 800), () {
                if (mounted) setState(() => _showPlayIcon = false);
              });
            }
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(controller),
                VideoBackground(stops: [0.8, 1.0]),
                Center(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      reverseDuration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: _isPaused
                          ? const Icon(
                              Icons.play_arrow_rounded,
                              key: ValueKey('paused-play-icon'),
                              color: Colors.white,
                              size: 88,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 12),
                              ],
                            )
                          : _showPlayIcon
                              ? const Icon(
                                  Icons.pause_rounded,
                                  key: ValueKey('playing-pause-icon'),
                                  color: Colors.white,
                                  size: 88,
                                  shadows: [
                                    Shadow(color: Colors.black54, blurRadius: 12),
                                  ],
                                )
                              : const SizedBox.shrink(key: ValueKey('no-control-icon')),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: _VideoCaption(
                    caption: widget.caption,
                    description: widget.description,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoCaption extends StatelessWidget {
  final String caption;
  final String description;

  const _VideoCaption({required this.caption, required this.description});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: size.width * 0.62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption, maxLines: 2, style: titleStyle),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ExpandableDescription(description: description),
          ],
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.description});

  final String description;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 14, height: 1.3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.description, style: style),
          maxLines: 2,
          textDirection: Directionality.of(context),
          ellipsis: '\u2026',
        )..layout(maxWidth: constraints.maxWidth);
        final hasMore = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.description,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: style,
            ),
            if (hasMore)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _expanded ? 'Ver menos' : 'Ver más',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
