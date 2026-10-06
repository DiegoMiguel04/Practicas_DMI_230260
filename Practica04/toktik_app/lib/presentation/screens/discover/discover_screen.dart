import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_scrollable_view.dart';

enum _FeedSection { forYou, discover, favorites }

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  _FeedSection _selectedSection = _FeedSection.forYou;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    final videos = _videosForSection(provider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (provider.initialLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (provider.errorMessage != null)
            Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
          else
            Stack(
                  fit: StackFit.expand,
                  children: [
                    if (videos.isEmpty)
                      Center(
                        child: Text(
                          _selectedSection == _FeedSection.favorites
                              ? 'Aún no tienes videos favoritos.'
                              : 'No hay videos para mostrar.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      VideoScrollableView(
                        key: ValueKey(_selectedSection),
                        videos: videos,
                      ),
                    SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _SectionBar(
                            selectedSection: _selectedSection,
                            onSelected: (section) {
                              setState(() => _selectedSection = section);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  List<VideoPost> _videosForSection(DiscoverProvider provider) {
    switch (_selectedSection) {
      case _FeedSection.forYou:
        return provider.videos;
      case _FeedSection.discover:
        return provider.videos.reversed.toList();
      case _FeedSection.favorites:
        return provider.videos
            .where((video) => provider.likedVideoIds.contains(video.id))
            .toList();
    }
  }
}

class _SectionBar extends StatelessWidget {
  const _SectionBar({
    required this.selectedSection,
    required this.onSelected,
  });

  final _FeedSection selectedSection;
  final ValueChanged<_FeedSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SectionButton(
              label: 'Para ti',
              section: _FeedSection.forYou,
              selectedSection: selectedSection,
              onSelected: onSelected,
            ),
            _SectionButton(
              label: 'Descubrir',
              section: _FeedSection.discover,
              selectedSection: selectedSection,
              onSelected: onSelected,
            ),
            _SectionButton(
              label: 'Favoritos',
              section: _FeedSection.favorites,
              selectedSection: selectedSection,
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.label,
    required this.section,
    required this.selectedSection,
    required this.onSelected,
  });

  final String label;
  final _FeedSection section;
  final _FeedSection selectedSection;
  final ValueChanged<_FeedSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = section == selectedSection;
    return TextButton(
      onPressed: () => onSelected(section),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
