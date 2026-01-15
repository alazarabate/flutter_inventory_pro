import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'dart:io';

/// Screen for adding a new product with name, price, stock, and photo capture.
class AddProductScreen extends ConsumerStatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _imagePath;

  /// Opens the camera to capture a photo for the product image.
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _imagePath != null
                ? Image.file(File(_imagePath!), height: 150, fit: BoxFit.cover)
                : IconButton(
                    icon: Icon(Icons.camera_alt, size: 50),
                    onPressed: _takePhoto,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final product = Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  stock: int.tryParse(_stockController.text) ?? 0,
                  imagePath: _imagePath,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                  updatedBy: FirebaseAuth.instance.currentUser?.uid ?? 'local',
                  pendingSync: true,

                );
                Navigator.pop(context, product);
              },
              child: Text('Save'),
            ),
            
          ],
        ),
      ),
    );
  }
}
