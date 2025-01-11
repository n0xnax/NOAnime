class AnimeItem {
  AnimeItem({
    required this.coverUrl,
    required this.id,
    required this.name,
    required this.score,
    required this.slug,
    required this.type,
    required this.infoSrc,
  });

  final String coverUrl;
  final String id;
  final String name;
  final String score;
  final String slug;
  final String type;
  final String infoSrc;

  // Factory constructor to create an AnimeItem from a map (JSON)
  factory AnimeItem.fromJson(Map<String, dynamic> json) {
    return AnimeItem(
      coverUrl: json['coverUrl'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      score: json['score'] as String,
      slug: json['slug'] as String,
      type: json['type'] as String,
      infoSrc: json['infoSrc'] as String,
    );
  }

  // Static method to convert a list of JSON objects to a list of AnimeItems
  static List<AnimeItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AnimeItem.fromJson(json)).toList();
  }
}

// Main model for the response
class ShowResponse {
  final List<Show> show;
  final List<Episode> episodes;

  ShowResponse({required this.show, required this.episodes});

  factory ShowResponse.fromJson(Map<String, dynamic> json) {
    return ShowResponse(
      show: (json['show'] as List).map((i) => Show.fromJson(i)).toList(),
      episodes: (json['EPS'] as List).map((i) => Episode.fromJson(i)).toList(),
    );
  }
}

// Model for the show information
class Show {
  final int animeId;
  final String animeName;
  final String animeScore;
  final String animeStatus;
  final String animeType;
  final String animeReleaseDate;
  final String animeDescription;
  final String animeGenres;
  final String animeCoverImageUrl;
  final String wallpaper;
  final String animeSlug;
  final int showEpisodeCount;

  Show({
    required this.animeId,
    required this.animeName,
    required this.animeScore,
    required this.animeStatus,
    required this.animeType,
    required this.animeReleaseDate,
    required this.animeDescription,
    required this.animeGenres,
    required this.animeCoverImageUrl,
    required this.wallpaper,
    required this.animeSlug,
    required this.showEpisodeCount,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      animeId: json['anime_id'],
      animeName: json['anime_name'],
      animeScore: json['anime_score'],
      animeStatus: json['anime_status'],
      animeType: json['anime_type'],
      animeReleaseDate: json['anime_release_date'],
      animeDescription: json['anime_description'],
      animeGenres: json['anime_genres'],
      animeCoverImageUrl: json['anime_cover_image_url'],
      wallpaper: json['wallpapaer'],
      animeSlug: json['anime_slug'],
      showEpisodeCount: json['show_episode_count'],
    );
  }
}

// Model for the episode information
class Episode {
  final String episodeName;
  final int episodeNumber;
  final String infoSrc;

  Episode({
    required this.episodeName,
    required this.episodeNumber,
    required this.infoSrc,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeName: json['episode_name'],
      episodeNumber: json['episode_number'],
      infoSrc: json['info-src'],
    );
  }
}

class VideoServer {
  VideoServer({required this.videos, required this.serverId});
  final List<Video> videos;
  final String serverId;
}

class Video {
  final String url;
  final String quality;
  // New property for server name

  Video(this.url, this.quality);
}
