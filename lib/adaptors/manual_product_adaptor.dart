import 'package:hive/hive.dart';
import '../models/product.dart';

/// Manual TypeAdapter for Product that is tolerant of missing fields.
class ManualProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final id = (fields[0] as String?) ?? '';
    final name = (fields[1] as String?) ?? '';
    final price = (fields[2] as num?)?.toDouble() ?? 0.0;
    final stock = (fields[3] as num?)?.toInt() ?? 0;
    final imagePath = fields[4] as String?;
    final category = fields[5] as String?;
    final updatedAt = (fields[6] as num?)?.toInt() ?? 0;
    final updatedBy = (fields[7] as String?) ?? '';
    final pendingSync = (fields[8] as bool?) ?? false;

    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      imagePath: imagePath,
      category: category,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
      pendingSync: pendingSync,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.stock)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.updatedBy)
      ..writeByte(8)
      ..write(obj.pendingSync);
  }
}
