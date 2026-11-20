import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';


class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> with AutomaticKeepAliveClientMixin {

  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadNextPage();

  }

  void loadNextPage() async {

    if ( isLoading || isLastPage ) return;
    isLoading = true;

    final movies = await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;

    if ( movies.isEmpty ) {
      isLastPage = true;
    }

  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Se muestran los favoritos del catálogo que se está viendo (películas o series)
    final isSeries = ref.watch( catalogTypeProvider ) == CatalogType.series;
    final favoriteMovies = ref.watch(favoriteMoviesProvider).values
        .where((movie) => MediaId.isSeries( movie.id ) == isSeries )
        .toList();


    if ( favoriteMovies.isEmpty ) {
      final colors = Theme.of(context).colorScheme;
      final t = AppStrings.of(context);
      return SafeArea(
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon( Icons.favorite_outline_sharp, size: 60, color: colors.primary ),
            Text(t.noFavTitle, style: TextStyle( fontSize: 30, color: colors.primary)),
            Text(isSeries ? t.noFavSeriesBody : t.noFavBody, style: const TextStyle( fontSize: 20 )),

            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.go('/home/0'), 
              child: Text(t.startSearching)
            )
          ],
          ),
        ),
      );
    }




    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: MovieMasonry(
          key: ValueKey('favorites-$isSeries'),
          loadNextPage: loadNextPage,
          movies: favoriteMovies
        ),
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
