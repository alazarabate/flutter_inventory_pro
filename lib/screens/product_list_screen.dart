import 'package:new_inventory/providers/product_provider.dart';
import 'package:new_inventory/widgets/product_card.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_product_screen.dart';

/// Stores raw search keystrokes for instant text field updates.
final _rawSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provides a debounced search query stream that updates after 300ms of inactivity.
final searchQueryProvider = StreamProvider<String>((ref) {
  return ref
      .watch(_rawSearchQueryProvider.notifier)
      .stream
      .debounce((_) => TimerStream(null, const Duration(milliseconds: 300)))
      .startWith('');
});

/// Main screen displaying a searchable list of products with add functionality.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productProvider);
    final debouncedQueryAsync = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddScreen(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (products) {
          return debouncedQueryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (query) {
              final filtered = query.isEmpty
                  ? products
                  : products
                      .where(
                        (p) => p.name.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                      )
                      .toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  return Dismissible(
                    key: Key(product.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Product'),
                          content: Text('Delete ${product.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('DELETE',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      await ref
                          .read(productProvider.notifier)
                          .deleteProduct(product.id);
                    },
                    child: ProductCard(product: product),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Opens the add product screen and adds the result to inventory if provided.
  void _showAddScreen(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
    if (result != null) {
      ref.read(productProvider.notifier).addProduct(result);
    }
  }
}

/// Custom search delegate for filtering products by name with real‑time suggestions.
class ProductSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  ProductSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        ref.read(_rawSearchQueryProvider.notifier).state = '';
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        ref.read(_rawSearchQueryProvider.notifier).state = query;
      }
      close(context, null);
    });

    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (products) {
        final suggestions = query.isEmpty
            ? products
            : products
                .where(
                  (p) => p.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final product = suggestions[index];
            return ListTile(
              leading: product.imagePath != null
                  ? Image.network(
                      (product.imagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 40),
              title: Text(product.name),
              subtitle: Text('${product.price} ETB - Stock: ${product.stock}'),
              onTap: () {
                query = product.name;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
