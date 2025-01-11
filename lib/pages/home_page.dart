import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noanime_app/pages/downloads_page.dart';
import 'package:noanime_app/pages/favorites_page.dart';
import 'package:noanime_app/pages/search_page.dart';
// Import the new search results page
import 'package:noanime_app/services/scraper_provider.dart';
import 'package:noanime_app/widgets/anime_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _isPressed = false;
  var _selectedIndex = 0;
  var _isGrid = false;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(popularAnimeProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animeState = ref.watch(popularAnimeProvider);

    return Scaffold(
      body: <Widget>[
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar.medium(
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGrid = !_isGrid;
                    });
                  },
                  icon: Icon(
                    color: Theme.of(context).colorScheme.onSurface,
                    _isGrid ? Icons.grid_view_outlined : Icons.grid_on,
                  ),
                ),
              ],
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 5,
              flexibleSpace: FlexibleSpaceBar(
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
                background: Image.asset(
                  fit: BoxFit.cover,
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark ? 'assets/ffflurryB.png' : 'assets/ffflurryB.png',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      _isPressed = !_isPressed;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  controller: searchController,
                  onSubmitted: (value) {},
                  canRequestFocus: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: "البحث",
                      prefixIconColor: Theme.of(context).colorScheme.secondary,
                      hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Colors.green,
                        ),
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
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      prefixIcon: const Icon(Icons.arrow_right)),
                ),
              ),
            ),
            animeState.when(
              data: (data) {
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _isGrid ? 3 : 2,
                    childAspectRatio: 2 / 3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimeCard(animeItem: data[index]);
                    },
                    childCount: data.length,
                  ),
                );
              },
              error: (error, stackTrace) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("Error: $error"),
                  ),
                );
              },
              loading: () {
                return SliverToBoxAdapter(
                  child: Center(
                    child: SpinKitFoldingCube(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const DownloadsPage(),
        const FavoritesPage()
      ][_selectedIndex],
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(
            child: SvgPicture.asset(
              'assets/ffflux.svg',
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Home'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 16,
        height: 70,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
