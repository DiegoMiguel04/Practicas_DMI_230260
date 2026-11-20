import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularView extends ConsumerStatefulWidget {
  const PopularView({super.key});

  @override
  PopularViewState createState() => PopularViewState();
}

class PopularViewState extends ConsumerState<PopularView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context ) {
    super.build(context);
    
    final isSeries = ref.watch( catalogTypeProvider ) == CatalogType.series;
    final popularProvider = isSeries ? popularSeriesProvider : popularMoviesProvider;

    final popularMovies = ref.watch( popularProvider );
    
    if ( popularMovies.isEmpty ) {
      return const SafeArea(child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: MovieMasonry(
          key: ValueKey('popular-$isSeries'),
          loadNextPage: () => ref.read(popularProvider.notifier).loadNextPage(),
          movies: popularMovies
        ),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
