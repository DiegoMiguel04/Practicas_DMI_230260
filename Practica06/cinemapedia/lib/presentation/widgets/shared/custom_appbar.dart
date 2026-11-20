import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric( horizontal: 10 ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              const CinemapediaLogo( size: 30 ),
              const SizedBox( width: 8 ),
              Text('Cinemapedia', style: titleStyle ),
      
              const Spacer(),
      
              IconButton.filledTonal(onPressed: () {

                final searchedMovies = ref.read( searchedMoviesProvider );
                final searchQuery = ref.read(searchQueryProvider);
                final isSeries = ref.read(catalogTypeProvider) == CatalogType.series;
                final t = AppStrings.of(context);
                
                showSearch<Movie?>(
                  query: searchQuery,
                  context: context, 
                  delegate: SearchMovieDelegate(
                    searchLabel: isSeries ? t.searchSeries : t.searchMovies,
                    initialMovies: searchedMovies,
                    searchMovies: ref.read( searchedMoviesProvider.notifier ).searchMoviesByQuery
                  )
                ).then((movie) {
                  if ( movie == null ) return;

                  context.push('/home/0/movie/${ movie.id }');
                });

              }, 
              icon: const Icon(Icons.search_rounded)
              )
            ],
          ),
        ),
      )
    );
  }
}
