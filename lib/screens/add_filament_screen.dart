import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/filament.dart';
import '../services/filament_service.dart';

class AddFilamentScreen extends StatefulWidget {
  final Filament? filament;

  const AddFilamentScreen({super.key, this.filament});

  @override
  State<AddFilamentScreen> createState() => _AddFilamentScreenState();
}

class _AddFilamentScreenState extends State<AddFilamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _colorNameController;
  late TextEditingController _colorHexController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;

  String _selectedMaterial = FilamentMaterialType.pla;
  String _selectedSubType = SubType.standard;
  int _selectedWeight = SpoolWeight.gram1000;
  bool _amsCompatible = true;
  String _selectedCurrency = 'USD'; // Default to USD

  @override
  void initState() {
    super.initState();
    final filament = widget.filament;

    _brandController = TextEditingController(text: filament?.brand ?? '');
    _colorNameController = TextEditingController(text: filament?.colorName ?? '');
    _colorHexController = TextEditingController(text: filament?.colorHex ?? '#FF0000');
    _costController = TextEditingController(text: filament?.cost.toString() ?? '');
    _quantityController = TextEditingController(text: filament?.quantity.toString() ?? '1');

    if (filament != null) {
      _selectedMaterial = filament.material;
      _selectedSubType = filament.subType;
      _selectedWeight = filament.weight;
      _amsCompatible = filament.amsCompatible;
      _selectedCurrency = filament.currency;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _colorNameController.dispose();
    _colorHexController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.filament != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Filament' : 'Add Filament'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Brand
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                hintText: 'e.g., eSun, Bambu Lab',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter brand name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Material
            DropdownButtonFormField<String>(
              initialValue: _selectedMaterial,
              decoration: const InputDecoration(
                labelText: 'Material Type',
                prefixIcon: Icon(Icons.science),
                border: OutlineInputBorder(),
              ),
              items: FilamentMaterialType.all.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: Text(material),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMaterial = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sub-type
            DropdownButtonFormField<String>(
              initialValue: _selectedSubType,
              decoration: const InputDecoration(
                labelText: 'Sub-Type',
                prefixIcon: Icon(Icons.style),
                border: OutlineInputBorder(),
              ),
              items: SubType.all.map((subType) {
                return DropdownMenuItem(
                  value: subType,
                  child: Text(subType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Weight
            DropdownButtonFormField<int>(
              initialValue: _selectedWeight,
              decoration: const InputDecoration(
                labelText: 'Spool Weight',
                prefixIcon: Icon(Icons.scale),
                border: OutlineInputBorder(),
              ),
              items: SpoolWeight.all.map((weight) {
                return DropdownMenuItem(
                  value: weight,
                  child: Text('${weight}g'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWeight = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Color name
            TextFormField(
              controller: _colorNameController,
              decoration: const InputDecoration(
                labelText: 'Color Name',
                hintText: 'e.g., Navy Blue',
                prefixIcon: Icon(Icons.palette),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter color name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color picker
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colorHexController,
                    decoration: const InputDecoration(
                      labelText: 'Color Hex',
                      hintText: '#FF0000',
                      prefixIcon: Icon(Icons.color_lens),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter color hex';
                      }
                      if (!value.startsWith('#') || value.length != 7) {
                        return 'Invalid hex format';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                        _colorHexController.text.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity (spools)',
                prefixIcon: Icon(Icons.inventory),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final qty = int.tryParse(value);
                if (qty == null || qty < 0) {
                  return 'Invalid quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency selection
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              items: CurrencyType.all.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Row(
                    children: [
                      Text(CurrencyType.getSymbol(currency)),
                      const SizedBox(width: 8),
                      Text(CurrencyType.getLabel(currency)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Cost
            TextFormField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: 'Cost per spool (${CurrencyType.getSymbol(_selectedCurrency)})',
                prefixIcon: const Icon(Icons.payment),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cost';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost < 0) {
                  return 'Invalid cost';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // AMS compatible
            SwitchListTile(
              title: const Text('AMS Compatible'),
              subtitle: const Text('Compatible with Bambu Lab AMS'),
              value: _amsCompatible,
              onChanged: (value) {
                setState(() {
                  _amsCompatible = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _saveFilament,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update Filament' : 'Add Filament'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFilament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final filament = Filament(
      id: widget.filament?.id ?? FilamentService.generateId(),
      brand: _brandController.text.trim(),
      material: _selectedMaterial,
      subType: _selectedSubType,
      weight: _selectedWeight,
      colorName: _colorNameController.text.trim(),
      colorHex: _colorHexController.text.trim(),
      quantity: int.parse(_quantityController.text),
      cost: double.parse(_costController.text),
      amsCompatible: _amsCompatible,
      lastUpdated: DateTime.now(),
      currency: _selectedCurrency,
    );

    if (widget.filament != null) {
      // Update existing
      await FilamentService.updateFilament(filament);
    } else {
      // Add new (with smart merge)
      await FilamentService.addFilament(filament);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.filament != null
                ? 'Filament updated successfully'
                : 'Filament added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
