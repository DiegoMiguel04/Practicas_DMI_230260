import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _HomeView(),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

class _HomeView extends ConsumerStatefulWidget {
  const _HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<_HomeView> {

  @override
  void initState() {
    super.initState();
    
    ref.read( nowPlayingMoviesProvider.notifier ).loadNextPage();
    ref.read( popularMoviesProvider.notifier ).loadNextPage();
    ref.read( topRatedMoviesProvider.notifier ).loadNextPage();
    ref.read( upcomingMoviesProvider.notifier ).loadNextPage();
  }

  void _showCountries() {
    showModalBottomSheet<void>(context: context, isScrollControlled: true,
      showDragHandle: true, builder: (sheetContext) => SafeArea(
        child: Consumer(builder: (context, ref, _) {
          final selected = ref.watch(movieCountryProvider);
          return Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('País y clasificación', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('El idioma y la región cambian los resultados de películas.'),
                const SizedBox(height: 12),
                ...movieCountries.map((country) => ListTile(
                  leading: Text(country.flag, style: const TextStyle(fontSize: 26)),
                  title: Text('${country.name} (${country.languageName})'),
                  trailing: selected.code == country.code ? const Icon(Icons.check_circle, color: Colors.deepPurple) : null,
                  onTap: () {
                    ref.read(movieCountryProvider.notifier).state = country;
                    Navigator.pop(sheetContext);
                  },
                )),
              ],
            ),
          );
        }),
      ));
  }


  @override
  Widget build(BuildContext context) {

    final initialLoading = ref.watch(initialLoadingProvider);
    if ( initialLoading ) return const FullScreenLoader();
    
    final slideShowMovies = ref.watch( moviesSlideshowProvider );
    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final popularMovies = ref.watch( popularMoviesProvider );
    final topRatedMovies = ref.watch( topRatedMoviesProvider );
    final upcomingMovies = ref.watch( upcomingMoviesProvider );

    ref.listen(movieCountryProvider, (previous, next) {
      ref.invalidate(nowPlayingMoviesProvider);
      ref.invalidate(popularMoviesProvider);
      ref.invalidate(topRatedMoviesProvider);
      ref.invalidate(upcomingMoviesProvider);
      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
      ref.read(popularMoviesProvider.notifier).loadNextPage();
      ref.read(topRatedMoviesProvider.notifier).loadNextPage();
      ref.read(upcomingMoviesProvider.notifier).loadNextPage();
    });

    return Scaffold(
      drawer: Drawer(child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(20), child: Text('Cinemapedia', style: Theme.of(context).textTheme.headlineSmall)),
        const Divider(),
        ListTile(leading: const Icon(Icons.home_rounded), title: const Text('Inicio'), onTap: () => Navigator.pop(context)),
        ListTile(leading: const Icon(Icons.settings_rounded), title: const Text('Configuración'), subtitle: const Text('País, idioma y clasificación'),
          onTap: () { Navigator.pop(context); _showCountries(); }),
      ]))),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nowPlayingMoviesProvider);
          ref.invalidate(popularMoviesProvider);
          ref.invalidate(topRatedMoviesProvider);
          ref.invalidate(upcomingMoviesProvider);
          ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
          ref.read(popularMoviesProvider.notifier).loadNextPage();
          ref.read(topRatedMoviesProvider.notifier).loadNextPage();
          ref.read(upcomingMoviesProvider.notifier).loadNextPage();
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [

        SliverAppBar(
          floating: true,
          leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(context).openDrawer())),
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),


        SliverList(delegate: SliverChildBuilderDelegate(
          (context, index) {
              return Column(
                  children: [
              
                    // const CustomAppbar(),
              
                    MoviesSlideshow(movies: slideShowMovies ),
              
                    MovieHorizontalListview(
                      movies: nowPlayingMovies,
                      title: 'En cines',
                      subTitle: 'Lunes 20',
                      loadNextPage: () =>ref.read(nowPlayingMoviesProvider.notifier).loadNextPage()
                      
                    ),
              
                    MovieHorizontalListview(
                      movies: upcomingMovies,
                      title: 'Próximamente',
                      subTitle: 'En este mes',
                      loadNextPage: () =>ref.read(upcomingMoviesProvider.notifier).loadNextPage()
                    ),
              
                    MovieHorizontalListview(
                      movies: popularMovies,
                      title: 'Populares',
                      // subTitle: '',
                      loadNextPage: () =>ref.read(popularMoviesProvider.notifier).loadNextPage()
                    ),
              
                    MovieHorizontalListview(
                      movies: topRatedMovies,
                      title: 'Mejor calificadas',
                      subTitle: 'Desde siempre',
                      loadNextPage: () =>ref.read(topRatedMoviesProvider.notifier).loadNextPage()
                    ),

                    const SizedBox( height: 10 ),
              
              
                  ],
                );
          },
          childCount: 1
        )),

      ]
    )
    ));
  }
}
