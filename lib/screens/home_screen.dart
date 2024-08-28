import 'dart:async'; // Import this for Timer
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos_riverpod/common_loader.dart';
import 'package:pos_riverpod/providers/product_provider.dart';
import 'package:pos_riverpod/screens/product_detail_screen.dart';
import '../responsive_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startImageSlideshow();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startImageSlideshow() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % 5;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageUrlsAsyncValue = ref.watch(imageUrlsProvider);

    return Scaffold(
      body: imageUrlsAsyncValue.when(
        data: (imageUrls) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: ResponsiveWidget.isSmallScreen(context)
                  ? 200.0
                  : ResponsiveWidget.isMediumScreen(context)
                      ? 350.0
                      : 550.0,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length > 5 ? 5 : imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = imageUrls[index];
                        return kIsWeb
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment(0.0, 0.0),
                          colors: <Color>[
                            Color(0x60000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            SliverToBoxAdapter(
              child: ResponsiveWidget(
                smallScreen: buildGrid(context, imageUrlsAsyncValue, 2),
                mediumScreen: buildGrid(context, imageUrlsAsyncValue, 3),
                largeScreen: buildGrid(context, imageUrlsAsyncValue, 4),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CommonLoader(
            icon: Icons.hourglass_empty,
            size: 60.0,
            color: Colors.white,
            duration: Duration(seconds: 1),
          ),
        ),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildGrid(BuildContext context, AsyncValue<List<String>> imageUrlsAsyncValue, int crossAxisCount) {
    return imageUrlsAsyncValue.when(
      data: (imageUrls) => GridView.builder(
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 3 / 4,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailScreen(
                    imageUrls: imageUrls,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: kIsWeb
                  ? Image.network(
                      imageUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CommonLoader(
                            icon: Icons.hourglass_empty,
                            size: 60.0,
                            color: Colors.white,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const Center(
                        child: CommonLoader(
                          icon: Icons.hourglass_empty,
                          size: 60.0,
                          color: Colors.white,
                          duration: Duration(seconds: 1),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
            ),
          );
        },
      ),
      loading: () => const Center(
        child: CommonLoader(
          icon: Icons.hourglass_empty,
          size: 60.0,
          color: Colors.white,
          duration: Duration(seconds: 1),
        ),
      ),
      error: (e, stack) => Center(child: Text('Error: $e')),
    );
  }
}
