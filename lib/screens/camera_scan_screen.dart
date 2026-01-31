import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/ai_service.dart';
import '../services/filament_service.dart';
import '../models/filament.dart';
import 'edit_detection_screen.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  List<Map<String, dynamic>> _detectedFilaments = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Camera Scan'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing image with AI...'),
                  SizedBox(height: 8),
                  Text(
                    'Detecting spools and reading labels',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _detectedFilaments.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 100,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'AI Multi-Spool Detection',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.science, size: 16, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Demo Mode: Using simulated detection',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Take a photo of one or multiple filament spools',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The AI will automatically detect each spool, read labels, and extract information',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera),
                          label: const Text('Take Photo'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose from Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Detected ${_detectedFilaments.length} filament(s)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review and confirm each detection',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._detectedFilaments.asMap().entries.map((entry) {
                      return _buildDetectionCard(entry.key, entry.value);
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _reset,
                            child: const Text('Scan Again'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveAll,
                            child: const Text('Save All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildDetectionCard(int index, Map<String, dynamic> data) {
    final colorValue = int.parse(data['colorHex'].replaceAll('#', '0xFF'));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['brand'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${data['material']} ${data['subType']}'),
                      Text(
                        data['colorName'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weight: ${data['weight']}g'),
                Text('Qty: ${data['quantity']}'),
                Text('${CurrencyType.getSymbol(data['currency'] ?? 'USD')}${data['cost'].toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editDetection(index, data),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _saveDetection(data),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      _processImage(await image.readAsBytes());
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      _processImage(await image.readAsBytes());
    }
  }

  Future<void> _processImage(Uint8List imageBytes) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final results = await AIService.processFilamentImage(imageBytes);

      setState(() {
        _detectedFilaments = results;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editDetection(int index, Map<String, dynamic> data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDetectionScreen(data: data),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _detectedFilaments[index] = result;
      });
    }
  }

  Future<void> _saveDetection(Map<String, dynamic> data) async {
    final filament = Filament(
      id: FilamentService.generateId(),
      brand: data['brand'],
      material: data['material'],
      subType: data['subType'],
      weight: data['weight'],
      colorName: data['colorName'],
      colorHex: data['colorHex'],
      quantity: data['quantity'],
      cost: data['cost'],
      amsCompatible: data['amsCompatible'],
      lastUpdated: DateTime.now(),
      currency: data['currency'] ?? 'USD',
    );

    await FilamentService.addFilament(filament);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filament saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _detectedFilaments.remove(data);
      });

      if (_detectedFilaments.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveAll() async {
    for (var data in _detectedFilaments) {
      final filament = Filament(
        id: FilamentService.generateId(),
        brand: data['brand'],
        material: data['material'],
        subType: data['subType'],
        weight: data['weight'],
        colorName: data['colorName'],
        colorHex: data['colorHex'],
        quantity: data['quantity'],
        cost: data['cost'],
        amsCompatible: data['amsCompatible'],
        lastUpdated: DateTime.now(),
        currency: data['currency'] ?? 'USD',
      );

      await FilamentService.addFilament(filament);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_detectedFilaments.length} filament(s) saved'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _reset() {
    setState(() {
      _detectedFilaments = [];
    });
  }
}
