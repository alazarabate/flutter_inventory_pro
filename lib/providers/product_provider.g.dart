// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productNotifierHash() => r'62b55b7b8103ec527b01f1cac84ea4eb7edf90ba';

/// Manages product inventory state with CRUD operations and optimistic updates.
///
/// Copied from [ProductNotifier].
@ProviderFor(ProductNotifier)
final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>.internal(
  ProductNotifier.new,
  name: r'productNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductNotifier = AsyncNotifier<List<Product>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
