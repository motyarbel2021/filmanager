import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/filament.dart';

class EditDetectionScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditDetectionScreen({super.key, required this.data});

  @override
  State<EditDetectionScreen> createState() => _EditDetectionScreenState();
}

class _EditDetectionScreenState extends State<EditDetectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _colorNameController;
  late TextEditingController _colorHexController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;

  late String _selectedMaterial;
  late String _selectedSubType;
  late int _selectedWeight;
  late bool _amsCompatible;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.data['brand']);
    _colorNameController = TextEditingController(text: widget.data['colorName']);
    _colorHexController = TextEditingController(text: widget.data['colorHex']);
    _costController = TextEditingController(text: widget.data['cost'].toString());
    _quantityController = TextEditingController(text: widget.data['quantity'].toString());

    _selectedMaterial = widget.data['material'];
    _selectedSubType = widget.data['subType'];
    _selectedWeight = widget.data['weight'];
    _amsCompatible = widget.data['amsCompatible'];
    _selectedCurrency = widget.data['currency'] ?? 'USD';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Detection'),
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

            // Color hex
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colorHexController,
                    decoration: const InputDecoration(
                      labelText: 'Color Hex',
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
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(int.tryParse(
                            _colorHexController.text.replaceAll('#', '0xFF')) ??
                        0xFFCCCCCC),
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
                prefixIcon: Icon(Icons.payment),
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
              onPressed: _saveChanges,
              icon: const Icon(Icons.check),
              label: const Text('Save Changes'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedData = {
      'brand': _brandController.text.trim(),
      'material': _selectedMaterial,
      'subType': _selectedSubType,
      'weight': _selectedWeight,
      'colorName': _colorNameController.text.trim(),
      'colorHex': _colorHexController.text.trim(),
      'quantity': int.parse(_quantityController.text),
      'cost': double.parse(_costController.text),
      'amsCompatible': _amsCompatible,
      'currency': _selectedCurrency,
    };

    Navigator.pop(context, updatedData);
  }
}
