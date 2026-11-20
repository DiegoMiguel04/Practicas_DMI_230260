import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/shared/loading_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:go_router/go_router.dart';


class MoviesSlideshow extends StatefulWidget {
  
  final List<Movie> movies;
  
  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {

  final SwiperController _controller = SwiperController();

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final t = AppStrings.of(context);

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        children: [

          Swiper(
            controller: _controller,
            viewportFraction: 0.8,
            scale: 0.9,
            autoplay: true,
            pagination: SwiperPagination(
              margin: const EdgeInsets.only(top: 0),
              builder: DotSwiperPaginationBuilder(
                activeColor: colors.primary,
                color: colors.secondary
              )
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) => _Slide(movie: widget.movies[index] ),
          ),

          // Flechas para cambiar de película (el bottom: 30 compensa el espacio de los puntos)
          // Siempre de izquierda a derecha (también en árabe) para que cada flecha
          // apunte hacia donde realmente se mueve el carrusel.
          Positioned.fill(
            bottom: 30,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ArrowButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: t.previous,
                    onPressed: () => _controller.previous(),
                  ),
                  _ArrowButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: t.next,
                    onPressed: () => _controller.next(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ArrowButton extends StatelessWidget {

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: Material(
          color: Colors.black54,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}


class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10)
        )
      ]
    );

      
    return Padding(
      padding: const EdgeInsets.only( bottom: 30 ),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => context.push('/home/0/movie/${ movie.id }'),
            child: Stack(
              fit: StackFit.expand,
              children: [

                // Imagen de fondo
                LoadingNetworkImage(
                  fit: BoxFit.cover,
                  url: movie.backdropPath,
                ),

                // Título y descripción corta sobre un degradado negro para que se lean bien
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [ Colors.transparent, Colors.black54 ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB( 16, 28, 16, 10 ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if ( movie.overview.trim().isNotEmpty )
                            Padding(
                              padding: const EdgeInsets.only( top: 2 ),
                              child: Text(
                                movie.overview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}
