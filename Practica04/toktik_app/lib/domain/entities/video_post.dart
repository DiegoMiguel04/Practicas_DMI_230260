

class VideoPost {

  final String id;
  final String caption;
  final String description;
  final String videoUrl;
  final String? youtubeVideoId;
  final String? peerTubeEmbedUrl;
  final String? dailymotionVideoId;
  final String? thumbnailUrl;
  final String? creator;
  final int likes;
  final int views;
  final Map<String, String> httpHeaders;

  VideoPost({
    String? id,
    required this.caption,
    this.description = '',
    required this.videoUrl,
    this.youtubeVideoId,
    this.peerTubeEmbedUrl,
    this.dailymotionVideoId,
    this.thumbnailUrl,
    this.creator,
    this.likes = 0,
    this.views = 0,
    this.httpHeaders = const {},
  }) : id = id ?? videoUrl;

  VideoPost copyWith({int? likes, int? views}) => VideoPost(
    id: id,
    caption: caption,
    description: description,
    videoUrl: videoUrl,
    youtubeVideoId: youtubeVideoId,
    peerTubeEmbedUrl: peerTubeEmbedUrl,
    dailymotionVideoId: dailymotionVideoId,
    thumbnailUrl: thumbnailUrl,
    creator: creator,
    likes: likes ?? this.likes,
    views: views ?? this.views,
    httpHeaders: httpHeaders,
  );

}
