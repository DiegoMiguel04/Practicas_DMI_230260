import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/presentation/widgets/shared/loading_network_image.dart';

import 'package:cinemapedia/presentation/providers/providers.dart';



class ActorsByMovie extends ConsumerWidget {

  final String movieId;

  const ActorsByMovie({
    super.key, 
    required this.movieId
  });

  @override
  Widget build(BuildContext context, ref) {

    final actorsByMovie = ref.watch( actorsByMovieProvider );
    final colors = Theme.of(context).colorScheme;

    //* Loading actors
    if ( actorsByMovie[movieId] == null ) {
      return Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 50),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2)
        ),
      );
    }
    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            width: 132,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.outline.withValues(alpha: .4)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Actor Photo
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: LoadingNetworkImage(
                      height: 180,
                      width: 132,
                      fit: BoxFit.cover,
                      url: actor.profilePath,
                    )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        actor.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      // Personaje
                      Text(
                        actor.character ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.primary, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );


        },
      ),
    );

  }
}
