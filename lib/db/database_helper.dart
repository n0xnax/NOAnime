import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'anime.db';
  static const int _dbVersion = 1;

  // Anime table columns
  static const String tableAnime = 'anime';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCoverUrl = 'coverUrl';
  static const String columnScore = 'score';
  static const String columnSlug = 'slug';
  static const String columnType = 'type';
  static const String columnInfoSrc = 'infoSrc';

  // Show table columns
  static const String tableShow = 'show';
  static const String columnAnimeId = 'anime_id';
  static const String columnAnimeName = 'anime_name';
  static const String columnAnimeScore = 'anime_score';
  static const String columnAnimeStatus = 'anime_status';
  static const String columnAnimeType = 'anime_type';
  static const String columnAnimeReleaseDate = 'anime_release_date';
  static const String columnAnimeDescription = 'anime_description';
  static const String columnAnimeGenres = 'anime_genres';
  static const String columnAnimeCoverImageUrl = 'anime_cover_image_url';
  static const String columnWallpaper = 'wallpaper';
  static const String columnAnimeSlug = 'anime_slug';
  static const String columnShowEpisodeCount = 'show_episode_count';

  // Initialize the database
  static Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        // Create the anime table
        await db.execute('''
          CREATE TABLE $tableAnime (
            $columnId TEXT PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnCoverUrl TEXT NOT NULL,
            $columnScore TEXT NOT NULL,
            $columnSlug TEXT NOT NULL,
            $columnType TEXT NOT NULL,
            $columnInfoSrc TEXT NOT NULL
          )
        ''');

        // Create the show table
        await db.execute('''
          CREATE TABLE $tableShow (
            $columnAnimeId INTEGER PRIMARY KEY,
            $columnAnimeName TEXT NOT NULL,
            $columnAnimeScore TEXT NOT NULL,
            $columnAnimeStatus TEXT NOT NULL,
            $columnAnimeType TEXT NOT NULL,
            $columnAnimeReleaseDate TEXT NOT NULL,
            $columnAnimeDescription TEXT NOT NULL,
            $columnAnimeGenres TEXT NOT NULL,
            $columnAnimeCoverImageUrl TEXT NOT NULL,
            $columnWallpaper TEXT NOT NULL,
            $columnAnimeSlug TEXT NOT NULL,
            $columnShowEpisodeCount INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Get the database instance
  static Future<Database> _getDatabase() async {
    return await _initializeDatabase();
  }

  static Future<Map<String, dynamic>?> getAnime(String anime_id) async {
    final db = await _getDatabase();

    // Use parameterized query to avoid SQL injection

    try {
      var anime = await db.rawQuery('SELECT * FROM $tableShow WHERE anime_id = ?', [anime_id]);
      print(anime);
      if (anime.isNotEmpty) {
        return anime[0];
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
    // print('result ${anime[0]}');
    // Check if the result is not empty before accessing the first item
    /* if (anime.isNotEmpty) {
      return anime[0];
    } else {
      return null;
    }*/
  }

  // Insert a new anime
  static Future<void> insertAnime(Map<String, dynamic> anime) async {
    final db = await _getDatabase();
    await db.insert(tableAnime, anime, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all favorite anime
  static Future<List<Map<String, dynamic>>> getAllAnime() async {
    final db = await _getDatabase();
    return await db.query(tableAnime);
  }

  // Delete an anime by ID
  static Future<void> deleteAnime(String id) async {
    final db = await _getDatabase();
    await db.delete(tableAnime, where: '$columnId = ?', whereArgs: [id]);
  }

  // Insert a new show
  static Future<void> insertShow(Map<String, dynamic> show) async {
    final db = await _getDatabase();
    await db.insert(tableShow, show, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all shows
  static Future<List<Map<String, dynamic>>> getAllShows() async {
    final db = await _getDatabase();
    return await db.query(tableShow);
  }

  // Delete a show by Anime ID
  static Future<void> deleteShow(int animeId) async {
    final db = await _getDatabase();
    await db.delete(tableShow, where: '$columnAnimeId = ?', whereArgs: [animeId]);
  }
}
