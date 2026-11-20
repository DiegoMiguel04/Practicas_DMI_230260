import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

/// Displays a pulsing cinema icon briefly while an image loads.
class LoadingNetworkImage extends StatefulWidget {
  const LoadingNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  State<LoadingNetworkImage> createState() => _LoadingNetworkImageState();
}

class _LoadingNetworkImageState extends State<LoadingNetworkImage> {
  bool _minimumLoadingTimePassed = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _loadingTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _minimumLoadingTimePassed = true);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, progress) {
        // El indicador aparece solo 1 segundo; después se muestra la imagen
        // aunque todavía se esté terminando de cargar.
        if (_minimumLoadingTimePassed) return child;

        return ColoredBox(
          color: colors.primary.withValues(alpha: 0.08),
          child: Center(
            child: Pulse(
              infinite: true,
              duration: const Duration(milliseconds: 1100),
              child: Icon(
                Icons.movie_creation_rounded,
                color: colors.primary,
                size: 38,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: colors.primary.withValues(alpha: 0.08),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: colors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
