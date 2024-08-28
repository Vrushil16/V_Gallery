import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final uploadProgressProvider = StateProvider<double?>((ref) => null);

class UploadImageScreen extends ConsumerStatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends ConsumerState<UploadImageScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  // ignore: unused_field
  int _imagesToUpload = 0;

  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(uploadProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Images'),
            ),
            const SizedBox(height: 16),
            if (_selectedImages != null && _selectedImages!.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _selectedImages!.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(_selectedImages![index].path),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadImages,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Images'),
            ),
            if (uploadProgress != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: uploadProgress),
                  const SizedBox(height: 8),
                  Text('${(uploadProgress * 100).toStringAsFixed(2)}% uploaded'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedFiles;
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages == null || _selectedImages!.isEmpty) return;

    final storageRef = FirebaseStorage.instance.ref().child('images');
    final totalImages = _selectedImages!.length;
    _imagesToUpload = totalImages;

    for (int i = 0; i < totalImages; i++) {
      final imageFile = File(_selectedImages![i].path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadRef = storageRef.child('$fileName.jpg');

      final uploadTask = uploadRef.putFile(imageFile);
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        ref.read(uploadProgressProvider.notifier).state = progress;
      }, onError: (error) {
        // Handle errors here
        print('Error uploading image: $error');
      });

      await uploadTask.whenComplete(() async {
        if (i == totalImages - 1) {
          // Upload completed
          ref.read(uploadProgressProvider.notifier).state = 1.0;
          print('All images uploaded successfully');
        }
      });
    }
  }
}
