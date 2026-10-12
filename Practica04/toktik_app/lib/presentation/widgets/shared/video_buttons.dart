import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:toktik_app/config/helpers/human_formats.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'dart:async';


class VideoButtons extends StatefulWidget {

  final VideoPost video;

  const VideoButtons({
    super.key, 
    required this.video
  });

  @override
  State<VideoButtons> createState() => _VideoButtonsState();
}

class _VideoButtonsState extends State<VideoButtons> {
  bool _showSeasonalLike = false;
  Timer? _seasonalTimer;

  @override
  void dispose() { _seasonalTimer?.cancel(); super.dispose(); }

  void _toggleLike(ForYouProvider provider, bool isLiked) {
    provider.toggleLike(widget.video.id);
    final month = DateTime.now().month;
    if (!isLiked && (month == 10 || month == 12)) {
      _seasonalTimer?.cancel();
      setState(() => _showSeasonalLike = true);
      _seasonalTimer = Timer(const Duration(milliseconds: 1050), () {
        if (mounted) setState(() => _showSeasonalLike = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForYouProvider>();
    final video = widget.video;
    final isLiked = provider.likedVideoIds.contains(video.id);
    final month = DateTime.now().month;
    final likeAsset = month == 10 ? 'assets/octubre_like_icon.png' : 'assets/diciembre_like_icon.png';
    return Column(
      children: [
        Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
          _CustomIconButton(
            value: video.likes,
            iconColor: isLiked ? Colors.red : Colors.white,
            iconData: isLiked ? Icons.favorite : Icons.favorite_border,
            onPressed: () => _toggleLike(provider, isLiked),
          ),
          if (_showSeasonalLike)
            IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_seasonalTimer),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, value, child) => Opacity(
                  opacity: (1 - value).clamp(0.0, 1.0),
                  child: Transform.scale(scale: value < 0.5 ? value * 2 : (1 - value) * 2, child: child),
                ),
                child: Image.asset(likeAsset, width: 46, height: 46, fit: BoxFit.contain),
              ),
            ),
        ]),
        const SizedBox( height: 20 ),
        _CustomIconButton(value: video.views, iconData: Icons.remove_red_eye_outlined),

        const SizedBox( height: 20 ),
        SpinPerfect(
          infinite: true,
          duration: const Duration( seconds: 5),
          child: const _CustomIconButton( value: 0, iconData: Icons.play_circle_outline )
        ),
      ],
    );
  }
}


class _CustomIconButton extends StatelessWidget {

  final int value;
  final IconData iconData;
  final Color? color;
  final VoidCallback? onPressed;

  const _CustomIconButton({
    required this.value, 
    required this.iconData, 
    Color? iconColor,
    this.onPressed,
  }): color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Icon(
              iconData,
              key: ValueKey(iconData.codePoint),
              color: color,
              size: 30,
            ),
          ),
        ),

        if ( value > 0 )
        Text( HumanFormats.humanReadbleNumber(value.toDouble()) ),
      ],
    );
  }
}
