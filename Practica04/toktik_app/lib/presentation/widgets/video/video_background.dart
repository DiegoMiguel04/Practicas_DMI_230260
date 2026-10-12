import 'package:flutter/material.dart';


class VideoBackground extends StatefulWidget {
  
  final List<Color> colors;
  final List<double> stops;

  const VideoBackground({
    super.key, 
    this.colors = const[
      Colors.transparent,
      Colors.black87
    ],
    this.stops = const[ 0.0, 1.0 ]
  }): assert( colors.length == stops.length, 'Stops and Colors must be same length' );

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Color _seasonColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    final month = DateTime.now().month;
    _seasonColor = month == 10
        ? const Color(0xFF5E1687)
        : month == 12 ? const Color(0xFF087A3C) : Colors.black87;
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final month = DateTime.now().month;
          final active = month == 10 || month == 12;
          final color = active
              ? Color.lerp(_seasonColor, month == 10 ? const Color(0xFFFF7900) : const Color(0xFFD51F35), _controller.value)!
              : widget.colors.last;
          return DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [widget.colors.first, color.withValues(alpha: active ? 0.24 : 0.0), active ? const Color(0xF20B0710) : widget.colors.last],
              stops: [0, widget.stops.first, widget.stops.last],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            )),
          );
        },
      )
    );
  }
}
