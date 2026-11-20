import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

LocalStorageDatasource createLocalStorageDatasource() => IsarDatasource();



class IsarDatasource extends LocalStorageDatasource {

  late Future<Isar> db;

  IsarDatasource() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if ( Isar.instanceNames.isEmpty ) {
      // Isar 3.1+ ya no resuelve el directorio por sÃ­ solo: hay que pasarlo.
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open(
        [ MovieSchema ],
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }


  @override
  Future<bool> isMovieFavorite(int movieId) async {
    final isar = await db;

    final Movie? isFavoriteMovie = await isar.movies
      .filter()
      .idEqualTo(movieId)
      .findFirst();

    return isFavoriteMovie != null;
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final favoriteMovie = await isar.movies
          .filter()
          .idEqualTo(movie.id)
          .findFirst();

      if (favoriteMovie != null) {
        await isar.movies.delete(favoriteMovie.isarId!);
      } else {
        await isar.movies.put(movie);
      }
    });

  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) async {

    final isar = await db;

    return isar.movies.where()
      .offset(offset)
      .limit(limit)
      .findAll();
  }

}
