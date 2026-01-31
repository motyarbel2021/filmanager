import 'dart:convert';
import '../models/filament.dart';
import 'filament_service.dart';

class GoogleSheetsService {
  // Export all filaments to CSV format (for manual import to Google Sheets)
  static String exportToCSV() {
    final filaments = FilamentService.getAllFilaments();
    
    // CSV header
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Brand,Material,Sub-Type,Weight (g),Color,Color Hex,Quantity,Cost,Currency,AMS Compatible,Total Value,Cost/Gram,Last Updated'
    );
    
    // CSV rows
    for (var filament in filaments) {
      buffer.writeln(
        '${filament.id},'
        '${_escapeCsv(filament.brand)},'
        '${filament.material},'
        '${filament.subType},'
        '${filament.weight},'
        '${_escapeCsv(filament.colorName)},'
        '${filament.colorHex},'
        '${filament.quantity},'
        '${filament.cost},'
        '${filament.currency},'
        '${filament.amsCompatible ? "Yes" : "No"},'
        '${filament.totalValue},'
        '${filament.costPerGram},'
        '${filament.lastUpdated.toIso8601String()}'
      );
    }
    
    return buffer.toString();
  }
  
  // Helper to escape CSV fields
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
  
  // Export inventory summary
  static String exportSummaryToCSV() {
    final valueByMaterial = FilamentService.getValueByMaterial();
    final totalValue = FilamentService.getTotalInventoryValue();
    final totalSpools = FilamentService.getTotalSpoolCount();
    
    final buffer = StringBuffer();
    buffer.writeln('FilaManager AI - Inventory Summary');
    buffer.writeln('Generated,${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('Total Spools,${totalSpools}');
    buffer.writeln('Total Value,${totalValue.toStringAsFixed(2)}');
    buffer.writeln('Average Cost per Spool,${totalSpools > 0 ? (totalValue / totalSpools).toStringAsFixed(2) : "0.00"}');
    buffer.writeln('');
    buffer.writeln('Material,Value,Percentage');
    
    for (var entry in valueByMaterial.entries) {
      final percentage = totalValue > 0 ? (entry.value / totalValue * 100) : 0.0;
      buffer.writeln('${entry.key},${entry.value.toStringAsFixed(2)},${percentage.toStringAsFixed(1)}%');
    }
    
    return buffer.toString();
  }
  
  // Create a shareable text format
  static String exportToText() {
    final filaments = FilamentService.getAllFilaments();
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('        FilaManager AI Export');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('Total Items: ${filaments.length}');
    buffer.writeln('Total Spools: ${FilamentService.getTotalSpoolCount()}');
    buffer.writeln('═══════════════════════════════════════\n');
    
    for (var filament in filaments) {
      buffer.writeln('▶ ${filament.brand} - ${filament.colorName}');
      buffer.writeln('  Material: ${filament.material} ${filament.subType}');
      buffer.writeln('  Weight: ${filament.weight}g');
      buffer.writeln('  Quantity: ${filament.quantity} spool(s)');
      buffer.writeln('  Cost: ${CurrencyType.getSymbol(filament.currency)}${filament.cost.toStringAsFixed(2)} per spool');
      buffer.writeln('  Total Value: ${CurrencyType.getSymbol(filament.currency)}${filament.totalValue.toStringAsFixed(2)}');
      buffer.writeln('  AMS: ${filament.amsCompatible ? "✓ Yes" : "✗ No"}');
      buffer.writeln('  Color: ${filament.colorHex}');
      buffer.writeln('');
    }
    
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Total Inventory Value: ${FilamentService.getTotalInventoryValue().toStringAsFixed(2)}');
    buffer.writeln('═══════════════════════════════════════');
    
    return buffer.toString();
  }
  
  // Export to JSON format
  static String exportToJSON() {
    final filaments = FilamentService.getAllFilaments();
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'total_spools': FilamentService.getTotalSpoolCount(),
      'total_value': FilamentService.getTotalInventoryValue(),
      'filaments': filaments.map((f) => f.toJson()).toList(),
      'summary': {
        'by_material': FilamentService.getValueByMaterial(),
      }
    };
    
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
