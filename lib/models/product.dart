import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
@freezed
class Product with _$Product {
  const factory Product({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) @Default(0.0) double price,
    @HiveField(3) @Default(0) int stock,
    @HiveField(4) String? imagePath,
    @HiveField(5) String? category,
    @HiveField(6) @Default(0) int updatedAt,
    @HiveField(7) @Default('') String updatedBy,
    @HiveField(8) @Default(false) bool pendingSync,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}