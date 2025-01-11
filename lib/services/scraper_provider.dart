import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noanime_app/model/model.dart';
import 'scraping_service.dart'; // Import your scraper file

final scraper = Scraper();

// Notifier for fetching popular anime
class PopularAnimeNotifier extends StateNotifier<AsyncValue<List<AnimeItem>>> {
  PopularAnimeNotifier() : super(const AsyncValue.loading());

  final List<AnimeItem> _popularAnimeList = [];
  int _currentPage = 0;
  bool _isFetching = false;

  Future<void> fetchPopularAnime() async {
    if (_currentPage == 1) _currentPage++;

    if (_isFetching) return; // Prevent multiple fetches at the same time

    _isFetching = true;
    try {
      final newAnime = await scraper.getPopularAnime((_currentPage).toString());
      if (newAnime.isNotEmpty) {
        _popularAnimeList.addAll(newAnime);
        _currentPage++;
        state = AsyncValue.data(_popularAnimeList);
      } else {
        state = AsyncValue.data(_popularAnimeList); // No more data
      }
    } catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadNextPage() async {
    await fetchPopularAnime();
  }

  // Method to get the current list of popular anime
  List<AnimeItem> get popularAnimeList => _popularAnimeList;
}

// Notifier for fetching search results
class SearchAnimeNotifier extends StateNotifier<AsyncValue<List<AnimeItem>>> {
  SearchAnimeNotifier() : super(const AsyncValue.loading());

  final List<AnimeItem> _searchResults = [];
  bool _isFetching = false;

  Future<void> fetchSearchResults(String query) async {
    if (query.length <= 3) return;
    if (_isFetching) return; // Prevent multiple fetches at the same time

    _isFetching = true;
    _searchResults.clear(); // Clear previous results for new search
    state = const AsyncValue.loading(); // Set loading state

    try {
      final searchResults = await scraper.getAnimeByQuery(query);

      // Check if searchResults is null or empty
      if (searchResults.isNotEmpty) {
        _searchResults.addAll(searchResults);
        state = AsyncValue.data(_searchResults);
      } else {
        state = const AsyncValue.data([]); // Return an empty list if no results found
      }
    } catch (e, stacktrace) {
      state = AsyncValue.error(e, stacktrace);
    } finally {
      _isFetching = false;
    }
  }

  // Method to get the current list of search results
  List<AnimeItem> get searchResults => _searchResults;
}

// Create a provider for PopularAnimeNotifier
final popularAnimeProvider = StateNotifierProvider<PopularAnimeNotifier, AsyncValue<List<AnimeItem>>>((ref) {
  return PopularAnimeNotifier()..fetchPopularAnime(); // Fetch the first page of popular anime
});

// Create a provider for SearchAnimeNotifier
final searchAnimeProvider = StateNotifierProvider<SearchAnimeNotifier, AsyncValue<List<AnimeItem>>>((ref) {
  return SearchAnimeNotifier(); // Initialize the search notifier
});

// Provider for fetching anime details
final getAnimeProvider = FutureProvider.family<ShowResponse?, String>((ref, infoSrc) async {
  return scraper.getAnime(infoSrc); // Fetch anime details
});

// Provider for fetching videos for a given episode source
final getVideosProvider = FutureProvider.family<List<Video>, String>((ref, episodeSrc) async {
  return await scraper.getVideos(episodeSrc); // Fetch videos for the given episode source
});
