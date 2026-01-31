import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../services/alerts_service.dart';
import '../services/filament_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _alertsEnabled = true;
  int _threshold = 2;
  List<Filament> _lowStockItems = [];
  List<Filament> _outOfStockItems = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final enabled = await AlertsService.areAlertsEnabled();
    final threshold = await AlertsService.getLowStockThreshold();
    final lowStock = await AlertsService.getLowStockFilaments();
    final outOfStock = AlertsService.getOutOfStockFilaments();

    setState(() {
      _alertsEnabled = enabled;
      _threshold = threshold;
      _lowStockItems = lowStock;
      _outOfStockItems = outOfStock;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAlerts = _lowStockItems.length + _outOfStockItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alerts'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alert settings card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alert Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Enable/disable alerts
                  SwitchListTile(
                    title: const Text('Enable Low Stock Alerts'),
                    subtitle: const Text('Get notified when filaments run low'),
                    value: _alertsEnabled,
                    onChanged: (value) async {
                      await AlertsService.setAlertsEnabled(value);
                      setState(() {
                        _alertsEnabled = value;
                      });
                    },
                  ),
                  
                  const Divider(),
                  
                  // Threshold slider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alert when quantity reaches: $_threshold spool${_threshold != 1 ? 's' : ''}',
                          style: theme.textTheme.titleSmall,
                        ),
                        Slider(
                          value: _threshold.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _threshold.toString(),
                          onChanged: _alertsEnabled
                              ? (value) async {
                                  final newThreshold = value.toInt();
                                  await AlertsService.setLowStockThreshold(newThreshold);
                                  setState(() {
                                    _threshold = newThreshold;
                                  });
                                  _loadAlerts();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Alert summary
          Card(
            color: totalAlerts > 0 ? Colors.orange.shade50 : Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    totalAlerts > 0 ? Icons.warning_amber : Icons.check_circle,
                    size: 40,
                    color: totalAlerts > 0 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalAlerts > 0 ? '$totalAlerts Alert${totalAlerts != 1 ? 's' : ''}' : 'All Good!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: totalAlerts > 0 ? Colors.orange.shade900 : Colors.green.shade900,
                          ),
                        ),
                        Text(
                          totalAlerts > 0
                              ? 'Some filaments need attention'
                              : 'All filaments are well stocked',
                          style: TextStyle(
                            color: totalAlerts > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Out of stock section
          if (_outOfStockItems.isNotEmpty) ...[
            Text(
              '❌ Out of Stock (${_outOfStockItems.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ..._outOfStockItems.map((filament) => _buildAlertCard(
              filament,
              AlertPriority.critical,
              theme,
            )),
            const SizedBox(height: 16),
          ],
          
          // Low stock section
          if (_lowStockItems.isNotEmpty) ...[
            Text(
              '⚠️ Low Stock (${_lowStockItems.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ..._lowStockItems.map((filament) => _buildAlertCard(
              filament,
              AlertsService.getAlertPriority(filament),
              theme,
            )),
          ],
          
          // Empty state
          if (totalAlerts == 0) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts at this time',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll be notified when stock runs low',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard(Filament filament, AlertPriority priority, ThemeData theme) {
    Color alertColor;
    IconData alertIcon;
    
    switch (priority) {
      case AlertPriority.critical:
        alertColor = Colors.red;
        alertIcon = Icons.error;
        break;
      case AlertPriority.high:
        alertColor = Colors.orange;
        alertIcon = Icons.warning;
        break;
      case AlertPriority.medium:
        alertColor = Colors.yellow.shade700;
        alertIcon = Icons.info;
        break;
      case AlertPriority.low:
        alertColor = Colors.blue;
        alertIcon = Icons.notifications;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(int.parse(filament.colorHex.replaceAll('#', '0xFF'))),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        title: Text(
          '${filament.brand} ${filament.colorName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${filament.material} ${filament.subType}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(alertIcon, size: 16, color: alertColor),
                const SizedBox(width: 4),
                Text(
                  filament.quantity == 0
                      ? 'Out of stock'
                      : '${filament.quantity} spool${filament.quantity != 1 ? 's' : ''} remaining',
                  style: TextStyle(
                    color: alertColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () => _reorderFilament(filament),
        ),
      ),
    );
  }

  Future<void> _reorderFilament(Filament filament) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _ReorderDialog(filament: filament),
    );

    if (result != null && result > 0) {
      final updated = filament.copyWith(
        quantity: filament.quantity + result,
        lastUpdated: DateTime.now(),
      );
      
      await FilamentService.updateFilament(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $result spool${result != 1 ? 's' : ''} to inventory'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAlerts();
      }
    }
  }
}

class _ReorderDialog extends StatefulWidget {
  final Filament filament;

  const _ReorderDialog({required this.filament});

  @override
  State<_ReorderDialog> createState() => _ReorderDialogState();
}

class _ReorderDialogState extends State<_ReorderDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restock Filament'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.filament.brand} ${widget.filament.colorName}'),
          const SizedBox(height: 16),
          Text('Current stock: ${widget.filament.quantity} spool${widget.filament.quantity != 1 ? 's' : ''}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add quantity:'),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'New total: ${widget.filament.quantity + _quantity} spool${widget.filament.quantity + _quantity != 1 ? 's' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _quantity),
          child: const Text('Add to Stock'),
        ),
      ],
    );
  }
}
