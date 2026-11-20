import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

/// Textos de la app en cada idioma.
///
/// Se usa así dentro de cualquier widget:
/// ```dart
/// final t = AppStrings.of(context);
/// Text(t.nowPlaying)
/// ```
/// Como depende de `Localizations`, los widgets se reconstruyen solos
/// cuando cambia el idioma de la app.
class AppStrings {

  final String languageCode;

  const AppStrings(this.languageCode);

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static const supportedCodes = ['es', 'en', 'de', 'zh', 'ar'];

  String _t(String key) =>
      _values[languageCode]?[key] ?? _values['es']![key] ?? key;

  // ---- Navegación
  String get home => _t('home');
  String get popular => _t('popular');
  String get favorites => _t('favorites');

  // ---- Inicio
  String get nowPlaying => _t('nowPlaying');
  String get upcoming => _t('upcoming');
  String get upcomingSub => _t('upcomingSub');
  String get topRated => _t('topRated');
  String get topRatedSub => _t('topRatedSub');
  String get previous => _t('previous');
  String get next => _t('next');

  // ---- Detalle
  String get releaseDate => _t('releaseDate');
  String get ageRating => _t('ageRating');
  String get recommendations => _t('recommendations');
  String get videos => _t('videos');
  String get similarError => _t('similarError');
  String get videosError => _t('videosError');

  // ---- Búsqueda y favoritos
  String get searchMovies => _t('searchMovies');
  String get noFavTitle => _t('noFavTitle');
  String get noFavBody => _t('noFavBody');
  String get startSearching => _t('startSearching');

  // ---- Carga
  String get pleaseWait => _t('pleaseWait');
  String get loading => _t('loading');
  List<String> get loadingMessages =>
      [for (var i = 1; i <= 6; i++) _t('loading$i')];

  // ---- Menú lateral
  String get menu => _t('menu');
  String get language => _t('language');
  String get chooseLanguage => _t('chooseLanguage');

  // ---- Configuración, películas y series
  String get settings => _t('settings');
  String get content => _t('content');
  String get chooseContent => _t('chooseContent');
  String get movies => _t('movies');
  String get series => _t('series');
  String get seriesOnAir => _t('seriesOnAir');
  String get airingToday => _t('airingToday');
  String get airingTodaySub => _t('airingTodaySub');
  String get searchSeries => _t('searchSeries');
  String get noFavSeriesBody => _t('noFavSeriesBody');

  static const Map<String, Map<String, String>> _values = {

    // ------------------------------------------------------------ Español
    'es': {
      'home': 'Inicio',
      'popular': 'Populares',
      'favorites': 'Favoritos',
      'nowPlaying': 'En cines',
      'upcoming': 'Próximamente',
      'upcomingSub': 'En este mes',
      'topRated': 'Mejor calificadas',
      'topRatedSub': 'Desde siempre',
      'previous': 'Anterior',
      'next': 'Siguiente',
      'releaseDate': 'Estreno:',
      'ageRating': 'Clasificación:',
      'recommendations': 'Recomendaciones',
      'videos': 'Videos',
      'similarError': 'No se pudo cargar películas similares',
      'videosError': 'No se pudieron cargar los videos',
      'searchMovies': 'Buscar películas',
      'noFavTitle': 'Nada que ver aun',
      'noFavBody': 'No tienes películas favoritas',
      'startSearching': 'Empieza a buscar',
      'pleaseWait': 'Espere por favor',
      'loading': 'Cargando...',
      'loading1': 'Cargando películas',
      'loading2': 'Comprando palomitas de maíz',
      'loading3': 'Cargando populares',
      'loading4': 'Llamando a mi novia',
      'loading5': 'Ya mero...',
      'loading6': 'Esto está tardando más de lo esperado :(',
      'menu': 'Menú',
      'language': 'Idioma',
      'chooseLanguage': 'Elige el idioma de la app y de las películas',
      'settings': 'Configuración',
      'content': 'Contenido',
      'chooseContent': 'Elige qué quieres ver',
      'movies': 'Películas',
      'series': 'Series',
      'seriesOnAir': 'En emisión',
      'airingToday': 'Se emiten hoy',
      'airingTodaySub': 'Episodios nuevos',
      'searchSeries': 'Buscar series',
      'noFavSeriesBody': 'No tienes series favoritas',
    },

    // ------------------------------------------------------------ English
    'en': {
      'home': 'Home',
      'popular': 'Popular',
      'favorites': 'Favorites',
      'nowPlaying': 'In theaters',
      'upcoming': 'Coming soon',
      'upcomingSub': 'This month',
      'topRated': 'Top rated',
      'topRatedSub': 'All time',
      'previous': 'Previous',
      'next': 'Next',
      'releaseDate': 'Release date:',
      'ageRating': 'Age rating:',
      'recommendations': 'Recommendations',
      'videos': 'Videos',
      'similarError': 'Could not load similar movies',
      'videosError': 'Could not load the videos',
      'searchMovies': 'Search movies',
      'noFavTitle': 'Oh no!!',
      'noFavBody': "You don't have any favorite movies",
      'startSearching': 'Start searching',
      'pleaseWait': 'Please wait',
      'loading': 'Loading...',
      'loading1': 'Loading movies',
      'loading2': 'Buying popcorn',
      'loading3': 'Loading popular movies',
      'loading4': 'Calling my girlfriend',
      'loading5': 'Almost there...',
      'loading6': 'This is taking longer than expected :(',
      'menu': 'Menu',
      'language': 'Language',
      'chooseLanguage': 'Choose the language of the app and the movies',
      'settings': 'Settings',
      'content': 'Content',
      'chooseContent': 'Choose what you want to watch',
      'movies': 'Movies',
      'series': 'TV Series',
      'seriesOnAir': 'On the air',
      'airingToday': 'Airing today',
      'airingTodaySub': 'New episodes',
      'searchSeries': 'Search TV series',
      'noFavSeriesBody': "You don't have any favorite series",
    },

    // ------------------------------------------------------------ Deutsch
    'de': {
      'home': 'Start',
      'popular': 'Beliebt',
      'favorites': 'Favoriten',
      'nowPlaying': 'Im Kino',
      'upcoming': 'Demnächst',
      'upcomingSub': 'In diesem Monat',
      'topRated': 'Bestbewertet',
      'topRatedSub': 'Aller Zeiten',
      'previous': 'Zurück',
      'next': 'Weiter',
      'releaseDate': 'Erscheinungsdatum:',
      'ageRating': 'Altersfreigabe:',
      'recommendations': 'Empfehlungen',
      'videos': 'Videos',
      'similarError': 'Ähnliche Filme konnten nicht geladen werden',
      'videosError': 'Videos konnten nicht geladen werden',
      'searchMovies': 'Filme suchen',
      'noFavTitle': 'Oh nein!!',
      'noFavBody': 'Du hast noch keine Lieblingsfilme',
      'startSearching': 'Jetzt suchen',
      'pleaseWait': 'Bitte warten',
      'loading': 'Wird geladen...',
      'loading1': 'Filme werden geladen',
      'loading2': 'Popcorn wird gekauft',
      'loading3': 'Beliebte Filme werden geladen',
      'loading4': 'Ich rufe meine Freundin an',
      'loading5': 'Gleich geschafft...',
      'loading6': 'Das dauert länger als erwartet :(',
      'menu': 'Menü',
      'language': 'Sprache',
      'chooseLanguage': 'Wähle die Sprache der App und der Filme',
      'settings': 'Einstellungen',
      'content': 'Inhalt',
      'chooseContent': 'Wähle, was du sehen möchtest',
      'movies': 'Filme',
      'series': 'Serien',
      'seriesOnAir': 'Läuft aktuell',
      'airingToday': 'Heute im TV',
      'airingTodaySub': 'Neue Folgen',
      'searchSeries': 'Serien suchen',
      'noFavSeriesBody': 'Du hast noch keine Lieblingsserien',
    },

    // ------------------------------------------------------------ 中文
    'zh': {
      'home': '首页',
      'popular': '热门',
      'favorites': '收藏',
      'nowPlaying': '正在热映',
      'upcoming': '即将上映',
      'upcomingSub': '本月',
      'topRated': '评分最高',
      'topRatedSub': '历史榜单',
      'previous': '上一部',
      'next': '下一部',
      'releaseDate': '上映日期：',
      'ageRating': '年龄分级：',
      'recommendations': '推荐',
      'videos': '视频',
      'similarError': '无法加载相似电影',
      'videosError': '无法加载视频',
      'searchMovies': '搜索电影',
      'noFavTitle': '哎呀！',
      'noFavBody': '你还没有收藏的电影',
      'startSearching': '开始搜索',
      'pleaseWait': '请稍候',
      'loading': '加载中...',
      'loading1': '正在加载电影',
      'loading2': '正在买爆米花',
      'loading3': '正在加载热门电影',
      'loading4': '正在给女朋友打电话',
      'loading5': '马上就好...',
      'loading6': '这比预期花的时间更长 :(',
      'menu': '菜单',
      'language': '语言',
      'chooseLanguage': '选择应用和电影的语言',
      'settings': '设置',
      'content': '内容',
      'chooseContent': '选择你想看的内容',
      'movies': '电影',
      'series': '剧集',
      'seriesOnAir': '正在播出',
      'airingToday': '今日播出',
      'airingTodaySub': '新剧集',
      'searchSeries': '搜索剧集',
      'noFavSeriesBody': '你还没有收藏的剧集',
    },

    // ------------------------------------------------------------ العربية
    'ar': {
      'home': 'الرئيسية',
      'popular': 'الشائعة',
      'favorites': 'المفضلة',
      'nowPlaying': 'في دور العرض',
      'upcoming': 'قريبًا',
      'upcomingSub': 'هذا الشهر',
      'topRated': 'الأعلى تقييمًا',
      'topRatedSub': 'على مر العصور',
      'previous': 'السابق',
      'next': 'التالي',
      'releaseDate': 'تاريخ الإصدار:',
      'ageRating': 'التصنيف العمري:',
      'recommendations': 'توصيات',
      'videos': 'مقاطع الفيديو',
      'similarError': 'تعذّر تحميل الأفلام المشابهة',
      'videosError': 'تعذّر تحميل مقاطع الفيديو',
      'searchMovies': 'ابحث عن فيلم',
      'noFavTitle': 'يا للأسف!!',
      'noFavBody': 'ليس لديك أفلام مفضلة',
      'startSearching': 'ابدأ البحث',
      'pleaseWait': 'يرجى الانتظار',
      'loading': 'جارٍ التحميل...',
      'loading1': 'جارٍ تحميل الأفلام',
      'loading2': 'جارٍ شراء الفشار',
      'loading3': 'جارٍ تحميل الأفلام الشائعة',
      'loading4': 'أتصل بصديقتي',
      'loading5': 'تقريبًا انتهينا...',
      'loading6': 'هذا يستغرق وقتًا أطول من المتوقع :(',
      'menu': 'القائمة',
      'language': 'اللغة',
      'chooseLanguage': 'اختر لغة التطبيق والأفلام',
      'settings': 'الإعدادات',
      'content': 'المحتوى',
      'chooseContent': 'اختر ما تريد مشاهدته',
      'movies': 'أفلام',
      'series': 'مسلسلات',
      'seriesOnAir': 'يُعرض حاليًا',
      'airingToday': 'تُعرض اليوم',
      'airingTodaySub': 'حلقات جديدة',
      'searchSeries': 'ابحث عن مسلسل',
      'noFavSeriesBody': 'ليس لديك مسلسلات مفضلة',
    },
  };
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedCodes.contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale.languageCode));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
