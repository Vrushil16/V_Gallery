import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<String>> fetchImageUrls() async {
    final ListResult result = await storage.ref('images/').listAll();
    final List<String> imageUrls = [];

    for (var item in result.items) {
      final String url = await item.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }
}
