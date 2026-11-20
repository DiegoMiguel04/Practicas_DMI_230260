import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';
import 'package:cinemapedia/presentation/widgets/shared/flag_icon.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final language = ref.watch(languageProvider);
    final catalog = ref.watch(catalogTypeProvider);

    return Drawer(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(28), bottomEnd: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(colors: colors, textStyles: textStyles),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
              children: [
                _SectionTitle(icon: Icons.video_library_rounded, title: t.content, subtitle: t.chooseContent),
                const SizedBox(height: 8),
                _CatalogTile(
                  icon: Icons.movie_creation_outlined,
                  label: t.movies,
                  selected: catalog == CatalogType.movies,
                  onTap: () => _changeCatalog(context, ref, CatalogType.movies),
                ),
                const SizedBox(height: 8),
                _CatalogTile(
                  icon: Icons.live_tv_rounded,
                  label: t.series,
                  selected: catalog == CatalogType.series,
                  onTap: () => _changeCatalog(context, ref, CatalogType.series),
                ),
                const SizedBox(height: 28),
                _SectionTitle(icon: Icons.translate_rounded, title: t.language, subtitle: t.chooseLanguage),
                const SizedBox(height: 8),
                for (final item in AppLanguages.all)
                  _LanguageTile(
                    language: item,
                    selected: item == language,
                    onTap: () {
                      changeLanguage(ref, item);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 14),
            child: Text('Cinemapedia · 1.0.0', style: textStyles.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  void _changeCatalog(BuildContext context, WidgetRef ref, CatalogType type) {
    ref.read(catalogTypeProvider.notifier).state = type;
    ref.read(searchQueryProvider.notifier).state = '';
    Navigator.of(context).pop();
  }
}

class _Header extends StatelessWidget {
  final ColorScheme colors;
  final TextTheme textStyles;

  const _Header({required this.colors, required this.textStyles});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.primary, colors.tertiary]),
        borderRadius: const BorderRadiusDirectional.only(topEnd: Radius.circular(28), bottomEnd: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CinemapediaLogo(size: 46),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cinemapedia', style: textStyles.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('Tu próxima historia empieza aquí', style: textStyles.bodySmall?.copyWith(color: Colors.white.withValues(alpha: .86))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: styles.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle, style: styles.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatalogTile({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: selected ? colors.primary.withValues(alpha: .14) : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: selected ? colors.primary : colors.outline.withValues(alpha: .4)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onTap,
        leading: Icon(icon, color: selected ? colors.primary : colors.onSurfaceVariant),
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        trailing: selected ? Icon(Icons.check_circle_rounded, color: colors.primary) : null,
        dense: true,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({required this.language, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: selected ? colors.primary.withValues(alpha: .12) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? colors.primary : colors.outline.withValues(alpha: .4)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Row(children: [
              FlagIcon(country: language.country, width: 34),
              const SizedBox(width: 11),
              Expanded(child: Text(language.label, style: TextStyle(color: selected ? colors.primary : colors.onSurface, fontWeight: selected ? FontWeight.w700 : FontWeight.w500))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? colors.primary : Colors.transparent, border: Border.all(color: selected ? colors.primary : colors.outline)),
                child: selected ? Icon(Icons.check_rounded, size: 14, color: colors.onPrimary) : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
