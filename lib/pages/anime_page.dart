import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:noanime_app/db/database_helper.dart';
import 'package:noanime_app/model/model.dart'; // Ensure this imports your models
import 'package:noanime_app/pages/server_page.dart';
import 'package:noanime_app/services/scraper_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:chewie/chewie.dart';

class AnimePage extends ConsumerStatefulWidget {
  const AnimePage({super.key, required this.animeItem});

  final AnimeItem animeItem;

  @override
  ConsumerState<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends ConsumerState<AnimePage> {
  bool _isFavorite = false;
  final _scrollController = ScrollController();
  bool isReverse = false;
  var episodeslist = [];

  Future<void> _checkIfFavorite() async {
    print(widget.animeItem.id);
    final queryResult = await DatabaseHelper.getAnime(widget.animeItem.id.toString());
    //print(queryResult);
    if (queryResult != null) {
      setState(() {
        _isFavorite = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;
    // Watch the provider to get the anime information
    final animeInfo = ref.watch(getAnimeProvider(widget.animeItem.infoSrc));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animeItem.slug),
        centerTitle: true,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: Hero(
                tag: widget.animeItem.coverUrl,
                child: SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FancyShimmerImage(
                      imageUrl: widget.animeItem.coverUrl,
                      boxFit: BoxFit.cover,
                      cacheKey: widget.animeItem.id,
                      shimmerDuration: const Duration(milliseconds: 800),
                      shimmerHighlightColor: Theme.of(context).colorScheme.onPrimary.withAlpha(255),
                      shimmerBaseColor: Theme.of(context).colorScheme.primaryContainer,
                      shimmerBackColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.surfaceContainer.withAlpha(255),
                      Theme.of(context).colorScheme.primaryContainer.withAlpha(0),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      textAlign: TextAlign.center,
                      widget.animeItem.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                          ),
                    ).animate().fadeIn(duration: const Duration(milliseconds: 100), delay: const Duration(milliseconds: 250)),
                  ),
                ),
              ),
            ),
          ),
          animeInfo.when(
            data: (data) {
              final show = data!.show.first;
              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        // boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1, blurStyle: BlurStyle.normal)],
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(26),
                          bottomRight: Radius.circular(26),
                        ),
                      ),
                      // color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              show.animeScore,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            PannableRatingBar(
                              rate: (double.tryParse(show.animeScore) ?? 0 * 10 / 100) / 2,
                              items: List.generate(
                                  5,
                                  (index) => RatingWidget(
                                        selectedColor: Theme.of(context).colorScheme.primary,
                                        unSelectedColor: Theme.of(context).colorScheme.onPrimaryFixed,
                                        child: const Icon(
                                          Icons.star,
                                          size: 31,
                                        ),
                                      )),
                            ),

                            /*RatingBar.readOnly(
                                filledIcon: Icons.star,
                                emptyIcon: Icons.star_outline,
                                maxRating: 5,
                                size: 24,
                                alignment: Alignment.center,
                                direction: Axis.horizontal,fa
                                isHalfAllowed: true,
                                halfFilledIcon: Icons.star_half,
                                initialRating: ((double.tryParse(show.animeScore) ?? 0 * 10 / 100) / 2) /*.roundToDouble()*/,
                              ),
                              */
                            const SizedBox(
                              height: 8,
                            ),
                            ReadMoreText(
                              show.animeDescription,
                              textAlign: TextAlign.center,
                              isExpandable: true,
                              locale: const Locale('ar'),
                              trimLines: 3,
                              colorClickableText: Theme.of(context).colorScheme.tertiary,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'اقرأ المزيد',
                              trimExpandedText: '\n عرض أقل',
                              lessStyle: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              show.animeStatus == 'Completed' ? 'مكتمل' : 'مستمر',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            Text(
                              'تاريخ الصدور : ${show.animeReleaseDate}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'النوع : ${show.animeGenres}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        ).animate().fadeIn(duration: const Duration(milliseconds: 100), delay: const Duration(milliseconds: 250)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton.filled(
                            onPressed: () async {
                              if (!_isFavorite) {
                                final showSql = {
                                  'anime_id': show.animeId,
                                  'anime_name': show.animeName,
                                  'anime_score': show.animeScore,
                                  'anime_status': show.animeStatus,
                                  'anime_type': show.animeType,
                                  'anime_release_date': show.animeReleaseDate,
                                  'anime_description': show.animeDescription,
                                  'anime_genres': show.animeGenres,
                                  'anime_cover_image_url': show.animeCoverImageUrl,
                                  'wallpaper': show.wallpaper,
                                  'anime_slug': show.animeSlug,
                                  'show_episode_count': show.showEpisodeCount
                                };

                                await DatabaseHelper.insertShow(showSql);
                                setState(() {
                                  //_isAdding = false;
                                  _isFavorite = true;
                                });
                              } else {
                                await DatabaseHelper.deleteShow(show.animeId);
                                setState(() {
                                  _isFavorite = false;
                                });
                              }
                            },
                            icon: Icon(
                              // size: 32,
                              _isFavorite ? Icons.favorite : Icons.favorite_outline,
                            ),
                          ),
                        ),
                        const Text('قائمة الحلقات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton.filled(
                            onPressed: () {
                              setState(() {
                                isReverse = !isReverse;
                              });
                            },
                            icon: Icon(
                              // size: 32,
                              isReverse ? Icons.swap_vert_circle_sharp : Icons.swap_vert_circle_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: data.episodes.length,
                      itemBuilder: (context, index) {
                        episodeslist = data.episodes;

                        if (isReverse) {
                          episodeslist = episodeslist.reversed.toList();
                        }
                        return episodeslist.map((episode) {
                          return Padding(
                            padding: const EdgeInsets.all(0),
                            child: Container(
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primaryFixed, width: 1))),
                              //color: Theme.of(context).colorScheme.onPrimaryFixed,
                              child: ListTile(
                                trailing: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                ),
                                leading: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primaryFixed),
                                focusColor: Theme.of(context).colorScheme.primary,
                                splashColor: Theme.of(context).colorScheme.secondary,
                                iconColor: Theme.of(context).colorScheme.tertiary,
                                enableFeedback: true,
                                titleAlignment: ListTileTitleAlignment.center,
                                title: Text(
                                  episode.episodeName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.primaryFixed),
                                ),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ServerPage(episode: episode);
                                    },
                                  ));
                                  // Handle episode tap, e.g., navigate to episode details
                                },
                              ),
                            ),
                          );
                        }).toList()[index];
                      },
                    ),
                  ),
                ]),
              );
            },
            loading: () {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: Center(
                      child: SpinKitFoldingCube(
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ),
              );
            },
            error: (error, stackTrace) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Text('Error: $error'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
