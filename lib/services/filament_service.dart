import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/filament.dart';

class FilamentService {
  static const String _boxName = 'filaments';
  static Box<Filament>? _box;

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FilamentAdapter());
    _box = await Hive.openBox<Filament>(_boxName);
  }

  // Get box
  static Box<Filament> get box {
    if (_box == null) {
      throw Exception('FilamentService not initialized. Call init() first.');
    }
    return _box!;
  }

  // Add new filament with smart merge logic
  static Future<void> addFilament(Filament filament) async {
    final existingFilament = findDuplicate(filament);

    if (existingFilament != null) {
      // Merge: Update quantity and average cost
      final newQuantity = existingFilament.quantity + filament.quantity;
      final avgCost = ((existingFilament.cost * existingFilament.quantity) +
              (filament.cost * filament.quantity)) /
          newQuantity;

      final updated = existingFilament.copyWith(
        quantity: newQuantity,
        cost: avgCost,
        lastUpdated: DateTime.now(),
      );

      await existingFilament.save();
      existingFilament.brand = updated.brand;
      existingFilament.material = updated.material;
      existingFilament.subType = updated.subType;
      existingFilament.weight = updated.weight;
      existingFilament.colorName = updated.colorName;
      existingFilament.colorHex = updated.colorHex;
      existingFilament.quantity = updated.quantity;
      existingFilament.cost = updated.cost;
      existingFilament.amsCompatible = updated.amsCompatible;
      existingFilament.lastUpdated = updated.lastUpdated;
      await existingFilament.save();
    } else {
      // Add new entry
      await box.put(filament.id, filament);
    }
  }

  // Find duplicate based on 5 unique parameters
  static Filament? findDuplicate(Filament filament) {
    for (var item in box.values) {
      if (item.uniqueKey == filament.uniqueKey) {
        return item;
      }
    }
    return null;
  }

  // Get all filaments
  static List<Filament> getAllFilaments() {
    return box.values.toList();
  }

  // Get filament by ID
  static Filament? getFilamentById(String id) {
    return box.get(id);
  }

  // Update filament
  static Future<void> updateFilament(Filament filament) async {
    filament.lastUpdated = DateTime.now();
    await box.put(filament.id, filament);
  }

  // Delete filament
  static Future<void> deleteFilament(String id) async {
    await box.delete(id);
  }

  // Update quantity (for chatbot commands)
  static Future<void> updateQuantity(String id, int delta) async {
    final filament = box.get(id);
    if (filament != null) {
      final newQuantity = (filament.quantity + delta).clamp(0, 9999);
      final updated = filament.copyWith(
        quantity: newQuantity,
        lastUpdated: DateTime.now(),
      );
      await box.put(id, updated);
    }
  }

  // Filter by material
  static List<Filament> filterByMaterial(String material) {
    return box.values.where((f) => f.material == material).toList();
  }

  // Filter by AMS compatibility
  static List<Filament> filterByAMS(bool compatible) {
    return box.values.where((f) => f.amsCompatible == compatible).toList();
  }

  // Filter by color
  static List<Filament> filterByColor(String colorName) {
    return box.values
        .where((f) => f.colorName.toLowerCase().contains(colorName.toLowerCase()))
        .toList();
  }

  // Search filaments
  static List<Filament> search(String query) {
    final lowerQuery = query.toLowerCase();
    return box.values.where((f) {
      return f.brand.toLowerCase().contains(lowerQuery) ||
          f.material.toLowerCase().contains(lowerQuery) ||
          f.subType.toLowerCase().contains(lowerQuery) ||
          f.colorName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Sort filaments
  static List<Filament> sort(List<Filament> filaments, String sortBy,
      {bool ascending = true}) {
    final sorted = List<Filament>.from(filaments);

    switch (sortBy) {
      case 'quantity':
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'cost':
        sorted.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case 'date':
        sorted.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
        break;
      case 'brand':
        sorted.sort((a, b) => a.brand.compareTo(b.brand));
        break;
      case 'material':
        sorted.sort((a, b) => a.material.compareTo(b.material));
        break;
      default:
        sorted.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
    }

    return ascending ? sorted : sorted.reversed.toList();
  }

  // Financial calculations
  static double getTotalInventoryValue() {
    return box.values.fold(0.0, (sum, f) => sum + f.totalValue);
  }

  static Map<String, double> getValueByMaterial() {
    final result = <String, double>{};
    for (var filament in box.values) {
      result[filament.material] =
          (result[filament.material] ?? 0) + filament.totalValue;
    }
    return result;
  }

  static int getTotalSpoolCount() {
    return box.values.fold(0, (sum, f) => sum + f.quantity);
  }

  // Generate new ID
  static String generateId() {
    return const Uuid().v4();
  }

  // Close box
  static Future<void> close() async {
    await box.close();
  }
}
