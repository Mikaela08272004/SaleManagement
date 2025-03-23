// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerProductAdapter extends TypeAdapter<CustomerProduct> {
  @override
  final int typeId = 4;

  @override
  CustomerProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerProduct(
      product: fields[0] as Product,
      quantity: fields[1] as int,
      purchaseDate: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerProduct obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.purchaseDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
