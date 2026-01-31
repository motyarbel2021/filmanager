import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/export_service.dart';
import 'google_sheets_export_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _exportFormat = 'csv';
  String? _exportedData;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Inventory'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Export to Google Sheets
          Card(
            color: Colors.green.shade50,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoogleSheetsExportScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.table_chart,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export to Google Sheets',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quick export with step-by-step guide',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Other Export Formats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Export format selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Export Format',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // CSV option
                  RadioListTile<String>(
                    title: const Text('CSV (Comma-Separated Values)'),
                    subtitle: const Text('Import to Google Sheets, Excel'),
                    secondary: const Icon(Icons.table_chart),
                    value: 'csv',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                        _exportedData = null;
                      });
                    },
                  ),
                  
                  // Summary CSV option
                  RadioListTile<String>(
                    title: const Text('CSV Summary'),
                    subtitle: const Text('Statistics and breakdown by material'),
                    secondary: const Icon(Icons.summarize),
                    value: 'summary',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                        _exportedData = null;
                      });
                    },
                  ),
                  
                  // Text option
                  RadioListTile<String>(
                    title: const Text('Text Format'),
                    subtitle: const Text('Human-readable text file'),
                    secondary: const Icon(Icons.text_snippet),
                    value: 'text',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                        _exportedData = null;
                      });
                    },
                  ),
                  
                  // JSON option
                  RadioListTile<String>(
                    title: const Text('JSON Format'),
                    subtitle: const Text('For backup and data migration'),
                    secondary: const Icon(Icons.code),
                    value: 'json',
                    groupValue: _exportFormat,
                    onChanged: (value) {
                      setState(() {
                        _exportFormat = value!;
                        _exportedData = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Export button
          FilledButton.icon(
            onPressed: _isExporting ? null : _performExport,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Generate Export'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Preview/Copy section
          if (_exportedData != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Export Preview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _exportedData!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Copy the data above and paste into:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_exportFormat == 'csv' || _exportFormat == 'summary')
                          Chip(
                            avatar: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Google Sheets'),
                          ),
                        if (_exportFormat == 'csv' || _exportFormat == 'summary')
                          Chip(
                            avatar: const Icon(Icons.table_view, size: 16),
                            label: const Text('Excel'),
                          ),
                        if (_exportFormat == 'text')
                          Chip(
                            avatar: const Icon(Icons.note, size: 16),
                            label: const Text('Text Editor'),
                          ),
                        if (_exportFormat == 'json')
                          Chip(
                            avatar: const Icon(Icons.backup, size: 16),
                            label: const Text('Backup File'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Import to Google Sheets',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Copy the data above\n'
                      '2. Open Google Sheets (sheets.google.com)\n'
                      '3. Create new sheet\n'
                      '4. Select cell A1\n'
                      '5. Ctrl+V (Paste)\n'
                      '6. Data will auto-format into columns',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
    });

    // Simulate brief processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    String data;
    switch (_exportFormat) {
      case 'csv':
        data = GoogleSheetsService.exportToCSV();
        break;
      case 'summary':
        data = GoogleSheetsService.exportSummaryToCSV();
        break;
      case 'text':
        data = GoogleSheetsService.exportToText();
        break;
      case 'json':
        data = GoogleSheetsService.exportToJSON();
        break;
      default:
        data = GoogleSheetsService.exportToCSV();
    }

    setState(() {
      _exportedData = data;
      _isExporting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export generated successfully! Copy to use.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    if (_exportedData != null) {
      await Clipboard.setData(ClipboardData(text: _exportedData!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
