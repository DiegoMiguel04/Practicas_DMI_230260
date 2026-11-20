import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/infrastructure/datasources/web_storage_datasource.dart'
    as preferences;

LocalStorageDatasource createLocalStorageDatasource() =>
    preferences.WebStorageDatasource();
