import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({ super.key });

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {

  //* El reloj de carga de la pantalla completa se muestra solo 1 segundo
  Timer? _loaderTimer;
  bool _loaderExpired = false;

  @override
  void initState() {
    super.initState();
    _loadFirstPages();
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    super.dispose();
  }

  void _startLoaderTimer() {
    _loaderTimer ??= Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _loaderExpired = true);
    });
  }

  /// Pide la primera página de las listas del catálogo que se está viendo
  /// (películas o series). Si una lista ya tiene datos no se vuelve a pedir.
  void _loadFirstPages() {
    final isSeries = ref.read( catalogTypeProvider ) == CatalogType.series;

    final providers = isSeries
      ? [ onTheAirSeriesProvider, airingTodaySeriesProvider, popularSeriesProvider, topRatedSeriesProvider ]
      : [ nowPlayingMoviesProvider, upcomingMoviesProvider, popularMoviesProvider, topRatedMoviesProvider ];

    for ( final provider in providers ) {
      if ( ref.read( provider ).isEmpty ) {
        ref.read( provider.notifier ).loadNextPage();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    //* Al cambiar de idioma los providers se reinician: hay que volver a pedir los datos
    ref.listen( languageProvider, (previous, next) {
      if ( previous == next ) return;

      // En un microtask para que Riverpod ya haya recreado los providers
      // con el nuevo idioma antes de pedir la primera página.
      Future.microtask(() {
        if ( mounted ) _loadFirstPages();
      });
    });

    //* Al cambiar entre películas y series se piden las listas del nuevo catálogo
    ref.listen( catalogTypeProvider, (previous, next) {
      if ( previous == next ) return;

      Future.microtask(() {
        if ( mounted ) _loadFirstPages();
      });
    });

    final t = AppStrings.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    final isSeries = ref.watch( catalogTypeProvider ) == CatalogType.series;

    final initialLoading = ref.watch(initialLoadingProvider);
    if ( initialLoading && !_loaderExpired ) {
      _startLoaderTimer();
      return const FullScreenLoader();
    }
    if ( !initialLoading ) {
      // Terminó de cargar: el próximo reloj vuelve a durar 1 segundo
      _loaderTimer?.cancel();
      _loaderTimer = null;
      _loaderExpired = false;
    }

    final catalogProviders = isSeries
      ? [ onTheAirSeriesProvider, airingTodaySeriesProvider, popularSeriesProvider, topRatedSeriesProvider ]
      : [ nowPlayingMoviesProvider, upcomingMoviesProvider, popularMoviesProvider, topRatedMoviesProvider ];
    final hasCatalogItems = catalogProviders.any((provider) => ref.read(provider).isNotEmpty);
    final hasLoadError = catalogProviders.any((provider) => ref.read(provider.notifier).loadError != null);
    if (hasLoadError && !hasCatalogItems) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo cargar el catálogo. Revisa tu conexión y la API key de TMDB.'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadFirstPages, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    // Mismas secciones para películas y series, con listas distintas
    final firstProvider  = isSeries ? onTheAirSeriesProvider : nowPlayingMoviesProvider;
    final secondProvider = isSeries ? airingTodaySeriesProvider : upcomingMoviesProvider;
    final thirdProvider  = isSeries ? topRatedSeriesProvider : topRatedMoviesProvider;

    final slideShowMovies = ref.watch( isSeries ? seriesSlideshowProvider : moviesSlideshowProvider );
    final firstMovies  = ref.watch( firstProvider );
    final secondMovies = ref.watch( secondProvider );
    final thirdMovies  = ref.watch( thirdProvider );

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),


        SliverList(delegate: SliverChildBuilderDelegate(
          (context, index) {
              return Column(
                  children: [
              
                    // const CustomAppbar(),
              
                    if ( slideShowMovies.isEmpty )
                      const SizedBox( height: 210 )
                    else
                      MoviesSlideshow(key: ValueKey('slideshow-$isSeries'), movies: slideShowMovies ),
              
                    MovieHorizontalListview(
                      key: ValueKey('first-$isSeries'),
                      movies: firstMovies,
                      title: isSeries ? t.seriesOnAir : t.nowPlaying,
                      subTitle: HumanFormats.today(languageCode),
                      loadNextPage: () => ref.read(firstProvider.notifier).loadNextPage()
                      
                    ),
              
                    MovieHorizontalListview(
                      key: ValueKey('second-$isSeries'),
                      movies: secondMovies,
                      title: isSeries ? t.airingToday : t.upcoming,
                      subTitle: isSeries ? t.airingTodaySub : t.upcomingSub,
                      loadNextPage: () => ref.read(secondProvider.notifier).loadNextPage()
                    ),
              
                    //* Ya no estará aquí, ahora es parte del menú inferior
                    // MovieHorizontalListview(
                    //   movies: popularMovies,
                    //   title: 'Populares',
                    //   // subTitle: '',
                    //   loadNextPage: () =>ref.read(popularMoviesProvider.notifier).loadNextPage()
                    // ),
              
                    MovieHorizontalListview(
                      key: ValueKey('third-$isSeries'),
                      movies: thirdMovies,
                      title: t.topRated,
                      subTitle: t.topRatedSub,
                      loadNextPage: () => ref.read(thirdProvider.notifier).loadNextPage()
                    ),

                    const SizedBox( height: 10 ),
              
              
                  ],
                );
          },
          childCount: 1
        )),

      ]
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
