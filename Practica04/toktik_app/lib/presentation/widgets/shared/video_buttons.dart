import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:toktik_app/config/helpers/human_formats.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'package:toktik_app/config/theme/season_theme.dart';
import 'dart:async';
import 'package:flutter/services.dart';


class VideoButtons extends StatefulWidget {

  final VideoPost video;
  final bool youtube;

  const VideoButtons({
    super.key, 
    required this.video,
    this.youtube = false,
  });

  @override
  State<VideoButtons> createState() => _VideoButtonsState();
}

class _VideoButtonsState extends State<VideoButtons> {
  bool _showSeasonalLike = false;
  bool _youtubeLiked = false;
  Timer? _seasonalTimer;

  @override
  void dispose() { _seasonalTimer?.cancel(); super.dispose(); }

  void _toggleLike(ForYouProvider provider, bool isLiked) {
    if (widget.youtube) {
      setState(() => _youtubeLiked = !_youtubeLiked);
    } else {
      provider.toggleLike(widget.video.id);
    }
    if (!isLiked && context.read<SeasonProvider>().season.isSeasonal) {
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
    final isLiked = widget.youtube ? _youtubeLiked : provider.likedVideoIds.contains(video.id);
    final season = context.watch<SeasonProvider>().season;
    final likeAsset = season.likeAsset;
    return Column(
      children: [
        Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
          _CustomIconButton(
            value: video.likes + (_youtubeLiked ? 1 : 0),
            iconColor: isLiked ? Colors.red : Colors.white,
            iconData: isLiked ? Icons.favorite : Icons.favorite_border,
            onPressed: () => _toggleLike(provider, isLiked),
          ),
          if (_showSeasonalLike && likeAsset != null)
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

        const SizedBox(height: 14),
        _CustomIconButton(
          value: 0,
          iconData: Icons.share_outlined,
          onPressed: () => _shareLink(context, video.videoUrl),
        ),

        const SizedBox( height: 20 ),
        SpinPerfect(
          infinite: true,
          duration: const Duration( seconds: 5),
          child: const _CustomIconButton( value: 0, iconData: Icons.play_circle_outline )
        ),
      ],
    );
  }

  Future<void> _shareLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Enlace copiado para compartir')));
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
