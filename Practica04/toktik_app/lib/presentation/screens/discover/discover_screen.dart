import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/providers/favorites_provider.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_scrollable_view.dart';
import 'package:toktik_app/config/theme/season_theme.dart';
import 'package:flutter/services.dart';

enum _FeedSection { forYou, discover, favorites }

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  _FeedSection _selectedSection = _FeedSection.forYou;
  final FavoritesProvider _favoritesProvider = const FavoritesProvider();

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    final forYou = context.watch<ForYouProvider>();
    final discover = context.watch<DiscoverProvider>();
    final videos = _videosForSection(forYou, discover);
    final loading = switch (_selectedSection) {
      _FeedSection.forYou => forYou.initialLoading,
      _FeedSection.discover => discover.initialLoading,
      _FeedSection.favorites => false,
    };
    final error = switch (_selectedSection) {
      _FeedSection.forYou => forYou.errorMessage,
      _FeedSection.discover => discover.errorMessage,
      _FeedSection.favorites => null,
    };

    final sectionBar = SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SeasonalFeedDecoration(),
              const SizedBox(height: 7),
              _SectionBar(
                selectedSection: _selectedSection,
                onSelected: (section) {
                  setState(() => _selectedSection = section);
                  if (section == _FeedSection.discover) {
                    context.read<DiscoverProvider>().loadVideos();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    final feedContent = loading
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
        : error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error, textAlign: TextAlign.center),
                ),
              )
            : videos.isEmpty
                ? Center(
                    child: Text(
                      _selectedSection == _FeedSection.favorites
                          ? 'Aun no tienes videos favoritos.'
                          : 'No hay videos para mostrar.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : VideoScrollableView(
                    key: ValueKey(_selectedSection),
                    videos: videos,
                    youtube: _selectedSection == _FeedSection.discover,
                  );

    return Scaffold(
      backgroundColor: season.background,
      body: _selectedSection == _FeedSection.discover
          ? Stack(children: [
              Column(
                children: [
                  sectionBar,
                  Expanded(child: SafeArea(top: false, child: feedContent)),
                ],
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                right: 14,
                child: _PaletteButton(onTap: () => _showSeasonPicker(context)),
              ),
            ])
          : Stack(
              fit: StackFit.expand,
              children: [
                feedContent,
                sectionBar,
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  right: 14,
                  child: _PaletteButton(onTap: () => _showSeasonPicker(context)),
                ),
              ],
            ),
    );
  }

  Future<void> _showSeasonPicker(BuildContext context) async {
    final provider = context.read<SeasonProvider>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF191921),
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Estilo de temporada', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Personaliza los colores, letras y detalles de TokTik', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 16),
            for (final season in AppSeason.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: CircleAvatar(
                  backgroundColor: season.accent,
                  child: Icon(
                    season == AppSeason.normal ? Icons.restart_alt : Icons.auto_awesome,
                    color: Colors.white,
                  ),
                ),
                title: Text(season.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: provider.season == season ? Icon(Icons.check_circle, color: season.accent) : const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () async {
                  await provider.select(season);
                  try {
                    await const MethodChannel('toktik/app_icon').invokeMethod<void>('setSeason', season.name);
                  } on PlatformException {
                    // The in-app theme remains available if the launcher rejects icon changes.
                  } on MissingPluginException {
                    // Web and desktop do not expose a native launcher icon.
                  }
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
          ]),
        ),
      ),
    );
  }

  List<VideoPost> _videosForSection(
    ForYouProvider forYou,
    DiscoverProvider discover,
  ) {
    switch (_selectedSection) {
      case _FeedSection.forYou:
        return forYou.videos;
      case _FeedSection.discover:
        return discover.videos;
      case _FeedSection.favorites:
        return _favoritesProvider.videosFrom(forYou);
    }
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: .46),
    shape: const CircleBorder(),
    child: IconButton(tooltip: 'Cambiar estilo', onPressed: onTap, icon: const Icon(Icons.palette_outlined), color: Colors.white),
  );
}

class _SeasonalFeedDecoration extends StatelessWidget {
  const _SeasonalFeedDecoration();

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    if (!season.isSeasonal) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: season.accent.withValues(alpha: .38)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(season.bandAsset!, width: 27, height: 27, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Text(
            season.festivalName,
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: .3, shadows: [Shadow(color: season.accent, blurRadius: 9)]),
          ),
        ]),
      ),
    );
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
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.28) : null,
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
