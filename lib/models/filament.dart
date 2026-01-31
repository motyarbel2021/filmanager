import 'package:hive/hive.dart';

part 'filament.g.dart';

@HiveType(typeId: 0)
class Filament extends HiveObject {
  @HiveField(0)
  String id;

  // 1. Brand/Manufacturer
  @HiveField(1)
  String brand;

  // 2. Material type
  @HiveField(2)
  String material;

  // 3. Sub-type (Silk, Matte, Gradient, etc.)
  @HiveField(3)
  String subType;

  // 4. Spool weight in grams
  @HiveField(4)
  int weight;

  // 5. Color name and hex code
  @HiveField(5)
  String colorName;

  @HiveField(6)
  String colorHex;

  // 6. Quantity in stock
  @HiveField(7)
  int quantity;

  // 7. Cost per unit (price)
  @HiveField(8)
  double cost;

  // 8. AMS compatibility
  @HiveField(9)
  bool amsCompatible;

  // 9. Last update timestamp
  @HiveField(10)
  DateTime lastUpdated;

  // 10. Currency (USD or ILS)
  @HiveField(11)
  String currency;

  Filament({
    required this.id,
    required this.brand,
    required this.material,
    required this.subType,
    required this.weight,
    required this.colorName,
    required this.colorHex,
    required this.quantity,
    required this.cost,
    required this.amsCompatible,
    required this.lastUpdated,
    this.currency = 'USD', // Default to USD
  });

  // Calculated fields
  double get totalValue => cost * quantity;
  double get costPerGram => cost / weight;

  // Create unique identifier for duplicate detection
  String get uniqueKey => '$brand-$material-$subType-$weight-$colorName'.toLowerCase();

  // Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'material': material,
      'subType': subType,
      'weight': weight,
      'colorName': colorName,
      'colorHex': colorHex,
      'quantity': quantity,
      'cost': cost,
      'currency': currency,
      'amsCompatible': amsCompatible,
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalValue': totalValue,
      'costPerGram': costPerGram,
    };
  }

  // Create from JSON (for import or parsing)
  factory Filament.fromJson(Map<String, dynamic> json) {
    return Filament(
      id: json['id'] as String,
      brand: json['brand'] as String,
      material: json['material'] as String,
      subType: json['subType'] as String,
      weight: json['weight'] as int,
      colorName: json['colorName'] as String,
      colorHex: json['colorHex'] as String,
      quantity: json['quantity'] as int,
      cost: (json['cost'] as num).toDouble(),
      amsCompatible: json['amsCompatible'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  // Copy with method for updates
  Filament copyWith({
    String? id,
    String? brand,
    String? material,
    String? subType,
    int? weight,
    String? colorName,
    String? colorHex,
    int? quantity,
    double? cost,
    bool? amsCompatible,
    DateTime? lastUpdated,
    String? currency,
  }) {
    return Filament(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      material: material ?? this.material,
      subType: subType ?? this.subType,
      weight: weight ?? this.weight,
      colorName: colorName ?? this.colorName,
      colorHex: colorHex ?? this.colorHex,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      amsCompatible: amsCompatible ?? this.amsCompatible,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currency: currency ?? this.currency,
    );
  }
}

// Material types enum
class FilamentMaterialType {
  static const String pla = 'PLA';
  static const String petg = 'PETG';
  static const String abs = 'ABS';
  static const String asa = 'ASA';
  static const String tpu = 'TPU';
  static const String paCf = 'PA-CF';

  static List<String> get all => [pla, petg, abs, asa, tpu, paCf];
}

// Sub-types enum
class SubType {
  static const String standard = 'Standard';
  static const String silk = 'Silk';
  static const String matte = 'Matte';
  static const String gradient = 'Gradient';
  static const String carbonFiber = 'Carbon Fiber';
  static const String highSpeed = 'High Speed';

  static List<String> get all => [standard, silk, matte, gradient, carbonFiber, highSpeed];
}

// Common spool weights
class SpoolWeight {
  static const int gram250 = 250;
  static const int gram500 = 500;
  static const int gram1000 = 1000;

  static List<int> get all => [gram250, gram500, gram1000];
}

// Currency types
class CurrencyType {
  static const String usd = 'USD';
  static const String ils = 'ILS';

  static List<String> get all => [usd, ils];

  static String getSymbol(String currency) {
    switch (currency) {
      case usd:
        return '\$';
      case ils:
        return '₪';
      default:
        return '\$';
    }
  }

  static String getLabel(String currency) {
    switch (currency) {
      case usd:
        return 'Dollar (USD)';
      case ils:
        return 'Shekel (ILS)';
      default:
        return 'Dollar (USD)';
    }
  }
}
