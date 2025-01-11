import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noanime_app/pages/anime_page.dart';
import 'package:noanime_app/services/scraper_provider.dart';
import 'package:noanime_app/model/model.dart';
import 'package:transparent_image/transparent_image.dart'; // Import your AnimeItem model

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    super.initState();

    // Set the initial text to the query
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    ref.read(searchAnimeProvider.notifier).fetchSearchResults(query); // Fetch search results using the provider
  }

  @override
  Widget build(BuildContext context) {
    final animeState = ref.watch(searchAnimeProvider); // Watch the anime provider

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                if (value.length <= 3) {}
                _performSearch(value);
              },
              focusNode: _focusNode,
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: "Search Anime",
                  prefixIconColor: Theme.of(context).colorScheme.secondary,
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary.withAlpha(100),
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  prefixIcon: const Icon(Icons.arrow_right)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: animeState.when(
                loading: () => const Center(child: CircularProgressIndicator()), // Show loading indicator
                error: (error, stackTrace) => Center(child: Text("Error: $error")), // Show error message
                data: (animeList) {
                  if (animeList.isEmpty) {
                    return const Center(child: Text("No results found."));
                    //TODO make it dynamic (use more than 3 letters pleas type etc using search controller :v and a var)
                    // Show no results message
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Theme.of(context).colorScheme.secondary,
                      );
                    },
                    itemCount: animeList.length,
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return ListTile(
                        horizontalTitleGap: 0,
                        contentPadding: const EdgeInsets.all(0),
                        leading: SizedBox(height: 80, width: 80, child: FadeInImage.memoryNetwork(fit: BoxFit.cover, placeholder: kTransparentImage, image: anime.coverUrl)),
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            anime.name, maxLines: 2,
                            // Assuming AnimeItem has a 'name' property
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AnimePage(animeItem: anime);
                            },
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
