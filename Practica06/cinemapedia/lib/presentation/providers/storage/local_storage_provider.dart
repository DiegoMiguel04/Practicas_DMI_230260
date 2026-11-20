import 'package:cinemapedia/infrastructure/datasources/local_storage_datasource_factory.dart';
import 'package:cinemapedia/infrastructure/repositories/local_storage_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final localStorageRepositoryProvider = Provider((ref) {
  return LocalStorageRepositoryImpl(createLocalStorageDatasource());
});

