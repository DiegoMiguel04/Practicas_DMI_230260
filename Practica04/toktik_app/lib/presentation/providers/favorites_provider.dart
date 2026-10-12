import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/for_you_provider.dart';

class FavoritesProvider {
  const FavoritesProvider();

  List<VideoPost> videosFrom(ForYouProvider source) => source.videos
      .where((video) => source.likedVideoIds.contains(video.id))
      .toList();
}
