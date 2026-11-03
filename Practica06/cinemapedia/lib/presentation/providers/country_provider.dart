import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class MovieCountry {
  final String code;
  final String language;
  final String flag;
  final String languageName;
  final String name;
  const MovieCountry(this.code, this.language, this.flag, this.languageName, this.name);
}

const movieCountries = [
  MovieCountry('US', 'en-US', '🇺🇸', 'English', 'Estados Unidos'),
  MovieCountry('MX', 'es-MX', '🇲🇽', 'Español', 'México'),
  MovieCountry('DE', 'de-DE', '🇩🇪', 'Deutsch', 'Alemania'),
  MovieCountry('BR', 'pt-BR', '🇧🇷', 'Português', 'Brasil'),
  MovieCountry('ZA', 'en-ZA', '🇿🇦', 'English', 'Sudáfrica'),
  MovieCountry('IN', 'hi-IN', '🇮🇳', 'हिन्दी', 'India'),
  MovieCountry('AU', 'en-AU', '🇦🇺', 'English', 'Australia'),
  MovieCountry('JP', 'ja-JP', '🇯🇵', '日本語', 'Japón'),
];

final movieCountryProvider = StateProvider<MovieCountry>((ref) => movieCountries[1]);
