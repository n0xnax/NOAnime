import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noanime_app/db/database_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Map<String, dynamic>>> _shows;
  @override
  void initState() {
    _shows = DatabaseHelper.getAllShows();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'NOA',
                style: GoogleFonts.pixelifySans().copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                ),
              ),
              TextSpan(
                text: 'nime',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _shows,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else if (snapshot.hasData) {
            final shows = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'المفضلة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: shows.length,
                    itemBuilder: (context, index) {
                      final show = shows[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          DatabaseHelper.deleteShow(show['anime_id']);
                        },
                        key: ValueKey(show['anime_id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Icon(Icons.delete),
                              )
                            ],
                          ),
                          color: Theme.of(context).colorScheme.errorContainer,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 124,
                                  width: 100,
                                  child: FancyShimmerImage(
                                    boxFit: BoxFit.cover,
                                    imageUrl: show['anime_cover_image_url'],
                                  ),
                                ),
                                const SizedBox(width: 10), // Add spacing between the image and the text
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                                      mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                                      children: [
                                        Container(
                                          height: 48,
                                          child: Text(
                                            show['anime_name'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(show['anime_type']),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(show['anime_release_date'], style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                            Text(
                                              show['anime_score'],
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Theme.of(context).colorScheme.primaryFixed,
                              height: 4,
                              indent: 2,
                              thickness: 1,
                            )
                          ],
                        ),
                      );
                      /* return ListTile(
                        title: Text(show['anime_name']),
                        subtitle: Text(show['anime_score']),
                      );*/
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No shows found.'));
          }
        },
      ),
    );
  }
}
