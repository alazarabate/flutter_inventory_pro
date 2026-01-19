import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_inventory/screens/product_detail_screen.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

/// Animated card that toggles stock with 60 fps color & scale micro-interactions.
class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.red[100],
      end: Colors.green[100],
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.product.stock > 0) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.stock != oldWidget.product.stock) {
      if (widget.product.stock > 0) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  // In ProductCard widget - add this to your build method:
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: 100,
          child: Card(
            color: _colorAnimation.value,
            child: InkWell(
              // ADD THIS: Makes the whole card tappable
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(product: widget.product),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: widget.product.imagePath != null
                      ? (widget.product.imagePath!.startsWith('http')
                          // Firebase URL
                          ? Image.network(
                              widget.product.imagePath!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            )
                          // Local Hive path
                          : Image.file(
                              File(widget.product.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            ))
                      : const Icon(Icons.image, size: 50),
                  title: Text(widget.product.name),
                  subtitle: Text(
                      '${widget.product.price} ETB - Stock: ${widget.product.stock}'),
                  trailing: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Switch(
                      value: widget.product.stock > 0,
                      onChanged: (value) async {
                        // Keep your existing switch logic
                        final updated =
                            widget.product.copyWith(stock: value ? 10 : 0);
                        await ref
                            .read(productProvider.notifier)
                            .updateProduct(updated);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
