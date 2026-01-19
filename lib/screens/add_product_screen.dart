import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img; // ADD THIS DEPENDENCY
import '../models/product.dart';
import '../providers/sync_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _tempImagePath; // raw camera file
  String? _localImagePath; // permanent compressed file
  String? _imageUrl; // Firebase URL

  /* ----------------------------------------------------------
     1.  take photo  (unchanged)
     ---------------------------------------------------------- */
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _tempImagePath = pickedFile.path);
    }
  }

  /* ----------------------------------------------------------
     2.  compress + save locally
     ---------------------------------------------------------- */
  Future<File> _compressAndSave(File raw, String id) async {
    // read & resize
    final bytes = await raw.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final resized = img.copyResize(image, width: 1200); // max width
    final compressed = img.encodeJpg(resized, quality: 75); // 75% quality

    // write to app documents
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

    final outFile = File('${imagesDir.path}/$id.jpg')
      ..writeAsBytesSync(compressed);
    print(
        '>>> compressed  ${raw.lengthSync()} → ${outFile.lengthSync()}  bytes');
    return outFile;
  }

  /* ----------------------------------------------------------
     3.  upload compressed file  (same signature)
     ---------------------------------------------------------- */
  Future<String?> _uploadToFirebase(File compressed, String id) async {
    try {
      final ref = FirebaseStorage.instance.ref('product_images/$id.jpg');
      await ref.putFile(compressed);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Firebase upload failed: $e');
      return null;
    }
  }

  /* ----------------------------------------------------------
     4.  SAVE BUTTON  – only the onPressed body changed
     ---------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(syncNotifierProvider);
    final isCloudMode = async.value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            /* preview */
            _tempImagePath != null
                ? Image.file(File(_tempImagePath!), height: 150)
                : IconButton(
                    icon: const Icon(Icons.camera_alt, size: 50),
                    onPressed: _takePhoto),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                String? finalImagePath;

                if (_tempImagePath != null) {
                  // 1️⃣ compress & save locally
                  final compressed =
                      await _compressAndSave(File(_tempImagePath!), id);
                  _localImagePath = compressed.path;

                  // 2️⃣ cloud mode → upload compressed file
                  if (isCloudMode) {
                    _imageUrl = await _uploadToFirebase(compressed, id);
                    finalImagePath = _imageUrl;
                  } else {
                    finalImagePath = _localImagePath;
                  }
                }

                final product = Product(
                  id: id,
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  stock: int.tryParse(_stockController.text) ?? 0,
                  imagePath: finalImagePath,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                  updatedBy: FirebaseAuth.instance.currentUser?.uid ?? 'local',
                  pendingSync: !isCloudMode &&
                      _imageUrl == null &&
                      _localImagePath != null,
                );

                Navigator.pop(context, product);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
