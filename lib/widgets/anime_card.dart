import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noanime_app/model/model.dart';
import 'package:noanime_app/pages/anime_page.dart';

class AnimeCard extends StatelessWidget {
  final AnimeItem animeItem;

  const AnimeCard({super.key, required this.animeItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return AnimePage(
              animeItem: animeItem,
            );
          },
        ));
      },
      child: Card(
        clipBehavior: Clip.antiAlias, // Optional: ensures rounded corners if needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Optional: rounding corners of the card
        child: Stack(
          children: [
            // The cover image will be in the background
            Hero(
              tag: animeItem.coverUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FancyShimmerImage(
                  imageUrl: animeItem.coverUrl,
                  boxFit: BoxFit.cover,
                  cacheKey: animeItem.id,
                  shimmerDuration: const Duration(milliseconds: 800),
                  shimmerHighlightColor: Theme.of(context).colorScheme.onPrimary.withAlpha(150),
                  shimmerBaseColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
                  shimmerBackColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            /* FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: animeItem.coverUrl, // Use the actual cover URL from the animeItem
              fit: BoxFit.cover, // Ensure the image covers the whole space
      
              width: double.infinity, // Make the image take up the full width
            ),*/
            // The text will be overlaid on top of the image
            Positioned(
              bottom: 0, // Position the text near the bottom of the image
              left: 0, // Optional: Add a little margin from the left side
              right: 0, // Optional: Add a little margin from the right side
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(8.0), // Add some padding to the text container
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
                      Theme.of(context).colorScheme.primaryContainer.withAlpha(0),
                    ],
                  ),
                  // Background color for text
                  borderRadius: BorderRadius.zero, // Optional: rounded corners for the container
                ),
                child: Center(
                  child: Hero(
                      tag: animeItem.id,
                      child: Text(
                        animeItem.name, // Display the anime name
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                            ),
                      )),
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
            ),
          ],
        ),
      ),
    );
  }
}
