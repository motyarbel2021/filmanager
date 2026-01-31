// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filament.dart';

// **************************************************************************
// TypeAdapter
// **************************************************************************

class FilamentAdapter extends TypeAdapter<Filament> {
  @override
  final int typeId = 0;

  @override
  Filament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Filament(
      id: fields[0] as String,
      brand: fields[1] as String,
      material: fields[2] as String,
      subType: fields[3] as String,
      weight: fields[4] as int,
      colorName: fields[5] as String,
      colorHex: fields[6] as String,
      quantity: fields[7] as int,
      cost: fields[8] as double,
      amsCompatible: fields[9] as bool,
      lastUpdated: fields[10] as DateTime,
      currency: fields[11] as String? ?? 'USD',
    );
  }

  @override
  void write(BinaryWriter writer, Filament obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.material)
      ..writeByte(3)
      ..write(obj.subType)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.colorName)
      ..writeByte(6)
      ..write(obj.colorHex)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.cost)
      ..writeByte(9)
      ..write(obj.amsCompatible)
      ..writeByte(10)
      ..write(obj.lastUpdated)
      ..writeByte(11)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
