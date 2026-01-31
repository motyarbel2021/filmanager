import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/gemini_config.dart';

class GeminiSetupScreen extends StatefulWidget {
  const GeminiSetupScreen({super.key});

  @override
  State<GeminiSetupScreen> createState() => _GeminiSetupScreenState();
}

class _GeminiSetupScreenState extends State<GeminiSetupScreen> {
  final _apiKeyController = TextEditingController();
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    // Check if already configured
    if (GeminiConfig.isConfigured) {
      _apiKeyController.text = '✓ API Key Configured';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI Setup'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: GeminiConfig.isConfigured 
                  ? Colors.green.shade50 
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      GeminiConfig.isConfigured 
                          ? Icons.check_circle 
                          : Icons.info,
                      color: GeminiConfig.isConfigured 
                          ? Colors.green 
                          : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GeminiConfig.isConfigured 
                                ? 'AI Detection Active' 
                                : 'Demo Mode Active',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            GeminiConfig.isConfigured
                                ? 'Real AI-powered filament detection is enabled'
                                : 'Using sample data. Add API key for real detection',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions Toggle
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Setup Instructions'),
              trailing: Icon(
                _showInstructions 
                    ? Icons.expand_less 
                    : Icons.expand_more,
              ),
              onTap: () {
                setState(() {
                  _showInstructions = !_showInstructions;
                });
              },
            ),
            
            if (_showInstructions) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to get your FREE Gemini API Key:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStep('1', 'Go to Google AI Studio', 
                          'https://makersuite.google.com/app/apikey'),
                      _buildStep('2', 'Sign in with your Google account', ''),
                      _buildStep('3', 'Click "Get API Key" or "Create API Key"', ''),
                      _buildStep('4', 'Copy the generated API key', ''),
                      _buildStep('5', 'Paste it in the code file below', ''),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, 
                                color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Free tier: 60 requests/minute, 1500/day',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
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
            ],
            
            // File Instructions
            Text(
              'Setup Location',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Edit this file:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'lib/config/gemini_config.dart',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                              const ClipboardData(text: 'lib/config/gemini_config.dart'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Path copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Replace:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      "static const String apiKey = 'YOUR_API_KEY_HERE';",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'With:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Text(
                      "static const String apiKey = 'AIzaSy...your-key...';",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current Status
            Text(
              'Current Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListTile(
              leading: Icon(
                GeminiConfig.isConfigured 
                    ? Icons.check_circle 
                    : Icons.warning,
                color: GeminiConfig.isConfigured 
                    ? Colors.green 
                    : Colors.orange,
              ),
              title: Text(
                GeminiConfig.isConfigured 
                    ? 'API Key: Configured ✓' 
                    : 'API Key: Not Configured',
              ),
              subtitle: Text(
                GeminiConfig.isConfigured
                    ? 'Using: ${GeminiConfig.modelName}'
                    : 'Currently using demo mode',
              ),
              tileColor: Colors.grey.shade100,
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (!GeminiConfig.isConfigured)
              FilledButton.icon(
                onPressed: () {
                  // Open instructions website
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visit: https://makersuite.google.com/app/apikey'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Get Free API Key'),
              ),
            
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStep(String number, String text, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                if (url.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
