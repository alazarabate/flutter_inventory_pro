import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/pdf_service.dart';

/// Displays detailed product information and provides PDF invoice export functionality.
class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export Invoice',
            onPressed: () async {
              final pdf = PdfService();
              await pdf.shareInvoice([product]);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imagePath != null)
              Center(
                child: Image.network(
                  (product.imagePath!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Name: ${product.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                'Price: ${product.price} ETB',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Center(
              child: Text(
                'Stock: ${product.stock}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (product.category != null)
              Center(
                child: Text(
                  'Category: ${product.category}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Invoice'),
                onPressed: () async {
                  final pdf = PdfService();
                  await pdf.shareInvoice([product]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
