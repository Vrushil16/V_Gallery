import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/image_service.dart';

final imageServiceProvider = Provider((ref) => ImageService());

final imageUrlsProvider = FutureProvider<List<String>>((ref) async {
  final imageService = ref.watch(imageServiceProvider);
  return imageService.fetchImageUrls();
});
