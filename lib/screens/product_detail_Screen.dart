import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos_riverpod/common_loader.dart';

class ImageDetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageDetailScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  BoxFit _boxFit = BoxFit.contain;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleBoxFit(BoxFit boxFit) {
    setState(() {
      _boxFit = boxFit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final imageUrl = widget.imageUrls[index];
              return kIsWeb
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
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
                      fit: _boxFit,
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
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                      fit: _boxFit,
                    );
            },
          ),
          Positioned(
            bottom: 50,
            right: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _toggleBoxFit(BoxFit.contain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _boxFit == BoxFit.contain ? Colors.white : Colors.grey,
                  ),
                  child: Text(
                    "Contain",
                    style: TextStyle(
                      color: _boxFit == BoxFit.contain ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _toggleBoxFit(BoxFit.cover),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _boxFit == BoxFit.cover ? Colors.white : Colors.grey,
                  ),
                  child: Text(
                    "Cover",
                    style: TextStyle(
                      color: _boxFit == BoxFit.cover ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
                  onPressed: () {
                    if (_currentIndex < widget.imageUrls.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
