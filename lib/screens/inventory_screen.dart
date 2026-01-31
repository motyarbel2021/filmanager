import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../services/filament_service.dart';
import '../services/alerts_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/gemini_config.dart';
import 'add_filament_screen.dart';
import 'camera_scan_screen.dart';
import 'chatbot_screen.dart';
import 'stats_screen.dart';
import 'alerts_screen.dart';
import 'login_screen.dart';
import 'gemini_setup_screen.dart';
import '../widgets/filament_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedMaterial = 'All';
  String _sortBy = 'date';
  bool _sortAscending = false;
  bool? _amsFilter;

  List<Filament> _filteredFilaments = [];

  @override
  void initState() {
    super.initState();
    _loadFilaments();
  }

  void _loadFilaments() {
    setState(() {
      var filaments = FilamentService.getAllFilaments();

      // Apply search
      if (_searchQuery.isNotEmpty) {
        filaments = FilamentService.search(_searchQuery);
      }

      // Apply material filter
      if (_selectedMaterial != 'All') {
        filaments = filaments
            .where((f) => f.material == _selectedMaterial)
            .toList();
      }

      // Apply AMS filter
      if (_amsFilter != null) {
        filaments = filaments
            .where((f) => f.amsCompatible == _amsFilter)
            .toList();
      }

      // Apply sorting
      filaments = FilamentService.sort(filaments, _sortBy,
          ascending: _sortAscending);

      _filteredFilaments = filaments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FilaManager AI'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Alerts badge
          FutureBuilder<Map<String, dynamic>>(
            future: AlertsService.getAlertSummary(),
            builder: (context, snapshot) {
              final alertCount = snapshot.data?['total_alerts'] ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlertsScreen(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  if (alertCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          alertCount > 9 ? '9+' : '$alertCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          // Profile menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: FutureBuilder<User?>(
                  future: AuthService.getCurrentUser(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user?.name ?? 'User'),
                      subtitle: Text(user?.email ?? ''),
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'gemini',
                child: ListTile(
                  leading: Icon(
                    Icons.auto_awesome,
                    color: GeminiConfig.isConfigured 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  title: const Text('AI Setup'),
                  subtitle: Text(
                    GeminiConfig.isConfigured ? 'Active' : 'Demo Mode',
                    style: TextStyle(
                      fontSize: 11,
                      color: GeminiConfig.isConfigured 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'gemini') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeminiSetupScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search filaments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _loadFilaments();
                });
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedMaterial == 'All', () {
                  setState(() {
                    _selectedMaterial = 'All';
                    _loadFilaments();
                  });
                }),
                ...FilamentMaterialType.all.map((material) {
                  return _buildFilterChip(
                    material,
                    _selectedMaterial == material,
                    () {
                      setState(() {
                        _selectedMaterial = material;
                        _loadFilaments();
                      });
                    },
                  );
                }),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('AMS Compatible'),
                  selected: _amsFilter == true,
                  onSelected: (selected) {
                    setState(() {
                      _amsFilter = selected ? true : null;
                      _loadFilaments();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Inventory grid
          Expanded(
            child: _filteredFilaments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No filaments in inventory',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add filaments using the camera or + button',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredFilaments.length,
                    itemBuilder: (context, index) {
                      return FilamentCard(
                        filament: _filteredFilaments[index],
                        onTap: () => _showFilamentDetails(
                            _filteredFilaments[index]),
                        onDelete: () =>
                            _deleteFilament(_filteredFilaments[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to camera scanner
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScanScreen(),
            ),
          );
          _loadFilaments();
        },
        backgroundColor: theme.colorScheme.secondary, // Orange color
        elevation: 6,
        child: const Icon(Icons.camera_alt, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            IconButton(
              icon: const Icon(Icons.home),
              color: theme.colorScheme.primary,
              tooltip: 'Home',
              onPressed: () {
                // Already on home
              },
            ),
            // Stats
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistics',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // Space for FAB
            // Chat
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                ).then((_) => _loadFilaments());
              },
            ),
            // Alerts
            IconButton(
              icon: Badge(
                label: Text('${AlertsService.getAlertCount()}'),
                isLabelVisible: AlertsService.getAlertCount() > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
              tooltip: 'Alerts',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Added'),
              leading: Radio<String>(
                value: 'date',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                  _loadFilaments();
                },
              ),
            ),
            ListTile(
              title: const Text('Quantity'),
              leading: Radio<String>(
                value: 'quantity',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                  _loadFilaments();
                },
              ),
            ),
            ListTile(
              title: const Text('Cost'),
              leading: Radio<String>(
                value: 'cost',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                  _loadFilaments();
                },
              ),
            ),
            ListTile(
              title: const Text('Brand'),
              leading: Radio<String>(
                value: 'brand',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                  _loadFilaments();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilamentDetails(Filament filament) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                              filament.colorHex.replaceAll('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filament.brand,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${filament.material} ${filament.subType}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Color', filament.colorName),
                  _buildDetailRow('Weight', '${filament.weight}g'),
                  _buildDetailRow('Quantity', '${filament.quantity} spools'),
                  _buildDetailRow('Cost per spool',
                      '${CurrencyType.getSymbol(filament.currency)}${filament.cost.toStringAsFixed(2)}'),
                  _buildDetailRow('Cost per gram',
                      '${CurrencyType.getSymbol(filament.currency)}${filament.costPerGram.toStringAsFixed(2)}'),
                  _buildDetailRow('Total value',
                      '${CurrencyType.getSymbol(filament.currency)}${filament.totalValue.toStringAsFixed(2)}'),
                  _buildDetailRow('AMS Compatible',
                      filament.amsCompatible ? 'Yes' : 'No'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _editFilament(filament);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteFilament(filament);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _editFilament(Filament filament) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFilamentScreen(filament: filament),
      ),
    );
    _loadFilaments();
  }

  Future<void> _deleteFilament(Filament filament) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Filament'),
        content: Text('Are you sure you want to delete ${filament.brand} ${filament.colorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FilamentService.deleteFilament(filament.id);
      _loadFilaments();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
