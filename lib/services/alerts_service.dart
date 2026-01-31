import 'package:shared_preferences/shared_preferences.dart';
import '../models/filament.dart';
import 'filament_service.dart';

class AlertsService {
  static const String _lowStockThresholdKey = 'low_stock_threshold';
  static const String _alertsEnabledKey = 'alerts_enabled';
  
  // Get low stock threshold (default: 2 spools)
  static Future<int> getLowStockThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lowStockThresholdKey) ?? 2;
  }
  
  // Set low stock threshold
  static Future<void> setLowStockThreshold(int threshold) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lowStockThresholdKey, threshold);
  }
  
  // Check if alerts are enabled
  static Future<bool> areAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alertsEnabledKey) ?? true;
  }
  
  // Enable/disable alerts
  static Future<void> setAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alertsEnabledKey, enabled);
  }
  
  // Get list of low stock filaments
  static Future<List<Filament>> getLowStockFilaments() async {
    final threshold = await getLowStockThreshold();
    final allFilaments = FilamentService.getAllFilaments();
    
    return allFilaments.where((f) => f.quantity <= threshold && f.quantity > 0).toList();
  }
  
  // Get list of out of stock filaments
  static List<Filament> getOutOfStockFilaments() {
    final allFilaments = FilamentService.getAllFilaments();
    return allFilaments.where((f) => f.quantity == 0).toList();
  }
  
  // Get alert summary
  static Future<Map<String, dynamic>> getAlertSummary() async {
    final lowStock = await getLowStockFilaments();
    final outOfStock = getOutOfStockFilaments();
    
    return {
      'low_stock_count': lowStock.length,
      'out_of_stock_count': outOfStock.length,
      'total_alerts': lowStock.length + outOfStock.length,
      'low_stock_items': lowStock,
      'out_of_stock_items': outOfStock,
    };
  }
  
  // Check if filament should trigger alert
  static Future<bool> shouldAlert(Filament filament) async {
    final enabled = await areAlertsEnabled();
    if (!enabled) return false;
    
    final threshold = await getLowStockThreshold();
    return filament.quantity <= threshold;
  }
  
  // Get alert message for filament
  static String getAlertMessage(Filament filament) {
    if (filament.quantity == 0) {
      return '❌ Out of stock: ${filament.brand} ${filament.colorName}';
    } else {
      return '⚠️ Low stock: ${filament.brand} ${filament.colorName} (${filament.quantity} left)';
    }
  }
  
  // Get total alert count (synchronous for badges)
  static int getAlertCount() {
    final allFilaments = FilamentService.getAllFilaments();
    return allFilaments.where((f) => f.quantity <= 2).length;
  }
  
  // Get alert priority
  static AlertPriority getAlertPriority(Filament filament) {
    if (filament.quantity == 0) {
      return AlertPriority.critical;
    } else if (filament.quantity == 1) {
      return AlertPriority.high;
    } else {
      return AlertPriority.medium;
    }
  }
}

enum AlertPriority {
  critical,
  high,
  medium,
  low,
}
