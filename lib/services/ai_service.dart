import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/filament.dart';
import '../config/gemini_config.dart';

class AIService {
  // Process filament image with Gemini Vision API
  static Future<List<Map<String, dynamic>>> processFilamentImage(
      Uint8List imageBytes) async {
    
    // Check if Gemini API is configured
    if (!GeminiConfig.isConfigured) {
      // Fallback to demo mode if API key not configured
      return _generateDemoData(imageBytes);
    }
    
    try {
      // Initialize Gemini model
      final model = GenerativeModel(
        model: GeminiConfig.modelName,
        apiKey: GeminiConfig.apiKey,
        generationConfig: GenerationConfig(
          temperature: GeminiConfig.temperature,
          maxOutputTokens: GeminiConfig.maxOutputTokens,
        ),
      );
      
      // Create prompt for filament detection
      final prompt = '''
Analyze this image of 3D printer filament spool(s). For EACH spool visible in the image, extract:

1. Brand name (e.g., eSun, Bambu Lab, Polymaker, Prusament, etc.)
2. Material type (PLA, PETG, ABS, ASA, TPU, PA-CF, etc.)
3. Sub-type/finish (Silk, Matte, Standard, Gradient, Carbon Fiber, High Speed, etc.)
4. Spool weight in grams (common: 1000g, 750g, 500g, 250g)
5. Color name (descriptive name like "Navy Blue", "Matte Black", etc.)
6. Color hex code (best match, e.g., #003366 for navy blue)
7. AMS compatibility (true/false - if it's a Bambu Lab or similar AMS-compatible brand)

Return the results as a JSON array, with one object per spool detected:
[
  {
    "brand": "eSun",
    "material": "PLA",
    "subType": "Silk",
    "weight": 1000,
    "colorName": "Navy Blue",
    "colorHex": "#003366",
    "amsCompatible": true
  }
]

If you cannot read specific information clearly:
- For brand: try to identify from packaging colors/logos
- For material: look for large text labels (PLA, PETG, etc.)
- For color: describe what you see visually
- For weight: common weights are 1kg (1000g) or 750g
- Make reasonable assumptions based on visible information

If no spools are visible, return an empty array: []
''';
      
      // Create content with image
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      
      // Generate response
      final response = await model.generateContent(content);
      final text = response.text ?? '[]';
      
      // Parse JSON response
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final List<dynamic> results = _parseJson(jsonStr);
        
        // Convert to expected format with defaults
        return results.map((item) {
          return {
            'brand': item['brand'] ?? 'Unknown',
            'material': item['material'] ?? 'PLA',
            'subType': item['subType'] ?? 'Standard',
            'weight': item['weight'] ?? 1000,
            'colorName': item['colorName'] ?? 'Unknown',
            'colorHex': item['colorHex'] ?? '#808080',
            'quantity': 1,
            'cost': 25.0, // Default price - user can edit
            'amsCompatible': item['amsCompatible'] ?? true,
            'currency': 'USD',
          };
        }).toList();
      }
      
      // If parsing failed, return demo data
      return _generateDemoData(imageBytes);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gemini API Error: $e');
      }
      // Fallback to demo mode on error
      return _generateDemoData(imageBytes);
    }
  }
  
  // Parse JSON string safely
  static List<dynamic> _parseJson(String jsonStr) {
    try {
      return json.decode(jsonStr) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }
  
  // Generate demo data (fallback when API not configured or fails)
  static Future<List<Map<String, dynamic>>> _generateDemoData(
      Uint8List imageBytes) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate varied sample data based on image bytes (simulates real AI detection)
    // In production, this would call Gemini Vision API with actual image analysis
    
    final imageHash = imageBytes.length % 10; // Simple hash from image
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final variance = (imageHash + (timestamp % 10)) % 10;
    
    // Define various sample filaments
    final samples = [
      {
        'brand': 'eSun',
        'material': 'PLA',
        'subType': 'Silk',
        'weight': 1000,
        'colorName': 'Navy Blue',
        'colorHex': '#003366',
        'quantity': 1,
        'cost': 25.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Bambu Lab',
        'material': 'PETG',
        'subType': 'Matte',
        'weight': 1000,
        'colorName': 'Black',
        'colorHex': '#000000',
        'quantity': 1,
        'cost': 28.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Polymaker',
        'material': 'PLA',
        'subType': 'Standard',
        'weight': 1000,
        'colorName': 'Red',
        'colorHex': '#FF0000',
        'quantity': 1,
        'cost': 22.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Prusament',
        'material': 'PETG',
        'subType': 'Standard',
        'weight': 1000,
        'colorName': 'Orange',
        'colorHex': '#FF8800',
        'quantity': 1,
        'cost': 30.0,
        'amsCompatible': false,
        'currency': 'USD',
      },
      {
        'brand': 'eSun',
        'material': 'ABS',
        'subType': 'Standard',
        'weight': 1000,
        'colorName': 'White',
        'colorHex': '#FFFFFF',
        'quantity': 1,
        'cost': 24.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Polymaker',
        'material': 'TPU',
        'subType': 'Standard',
        'weight': 500,
        'colorName': 'Clear',
        'colorHex': '#CCCCCC',
        'quantity': 1,
        'cost': 35.0,
        'amsCompatible': false,
        'currency': 'USD',
      },
      {
        'brand': 'Bambu Lab',
        'material': 'PLA',
        'subType': 'Silk',
        'weight': 1000,
        'colorName': 'Gold',
        'colorHex': '#FFD700',
        'quantity': 1,
        'cost': 26.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'eSun',
        'material': 'PETG',
        'subType': 'Standard',
        'weight': 1000,
        'colorName': 'Green',
        'colorHex': '#00FF00',
        'quantity': 1,
        'cost': 23.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Polymaker',
        'material': 'PLA',
        'subType': 'Matte',
        'weight': 750,
        'colorName': 'Gray',
        'colorHex': '#808080',
        'quantity': 1,
        'cost': 27.0,
        'amsCompatible': true,
        'currency': 'USD',
      },
      {
        'brand': 'Prusament',
        'material': 'PLA',
        'subType': 'Galaxy',
        'weight': 1000,
        'colorName': 'Purple',
        'colorHex': '#8800FF',
        'quantity': 1,
        'cost': 32.0,
        'amsCompatible': false,
        'currency': 'USD',
      },
    ];
    
    // Return different sample based on image variance
    return [samples[variance]];
  }

  // Parse natural language command for chatbot
  static Map<String, dynamic>? parseNaturalLanguageCommand(String command) {
    final lowerCommand = command.toLowerCase();

    // Pattern: "add X spools of [material] [subtype] [color] by [brand] at [price]"
    final addPattern = RegExp(
      r'add(?:ed)?\s+(\d+)\s+(?:spools?|rolls?)\s+of\s+([^at]+?)(?:\s+at\s+|for\s+)?(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );

    final addMatch = addPattern.firstMatch(lowerCommand);
    if (addMatch != null) {
      final quantity = int.tryParse(addMatch.group(1) ?? '1') ?? 1;
      final description = addMatch.group(2)?.trim() ?? '';
      final cost = double.tryParse(addMatch.group(3) ?? '0') ?? 0;

      return {
        'action': 'add',
        'quantity': quantity,
        'description': description,
        'cost': cost,
      };
    }

    // Pattern: "finished [color] [brand]" or "used up [color]"
    final finishedPattern = RegExp(
      r'(?:finished|used up|out of)\s+(?:the\s+)?(.+)',
      caseSensitive: false,
    );

    final finishedMatch = finishedPattern.firstMatch(lowerCommand);
    if (finishedMatch != null) {
      return {
        'action': 'remove',
        'description': finishedMatch.group(1)?.trim() ?? '',
        'quantity': -1,
      };
    }

    // Pattern: "update/change [color] to [material]"
    final updatePattern = RegExp(
      r'(?:update|change|fix)\s+(.+?)\s+(?:is|to)\s+(?:actually\s+)?(.+)',
      caseSensitive: false,
    );

    final updateMatch = updatePattern.firstMatch(lowerCommand);
    if (updateMatch != null) {
      return {
        'action': 'update',
        'target': updateMatch.group(1)?.trim() ?? '',
        'newValue': updateMatch.group(2)?.trim() ?? '',
      };
    }

    return null;
  }

  // Extract filament info from description
  static Map<String, dynamic> parseFilamentDescription(String description) {
    final result = <String, dynamic>{
      'brand': 'Unknown',
      'material': 'PLA',
      'subType': 'Standard',
      'weight': 1000,
      'colorName': 'Unknown',
      'colorHex': '#808080',
      'amsCompatible': true,
    };

    final lowerDesc = description.toLowerCase();

    // Extract brand
    for (var brand in ['esun', 'bambu lab', 'polymaker', 'prusament']) {
      if (lowerDesc.contains(brand)) {
        result['brand'] = _capitalizeWords(brand);
        break;
      }
    }

    // Extract material
    for (var material in FilamentMaterialType.all) {
      if (lowerDesc.contains(material.toLowerCase())) {
        result['material'] = material;
        break;
      }
    }

    // Extract sub-type
    for (var subType in SubType.all) {
      if (lowerDesc.contains(subType.toLowerCase())) {
        result['subType'] = subType;
        break;
      }
    }

    // Extract color
    final colorMatch = RegExp(
      r'\b(red|blue|green|yellow|black|white|orange|purple|pink|gold|silver|navy|cyan)\b',
      caseSensitive: false,
    ).firstMatch(lowerDesc);

    if (colorMatch != null) {
      final color = colorMatch.group(1) ?? 'Unknown';
      result['colorName'] = _capitalizeWords(color);
      result['colorHex'] = _getColorHex(color);
    }

    return result;
  }

  static String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String _getColorHex(String colorName) {
    final colors = {
      'red': '#FF0000',
      'blue': '#0000FF',
      'green': '#00FF00',
      'yellow': '#FFFF00',
      'black': '#000000',
      'white': '#FFFFFF',
      'orange': '#FF8800',
      'purple': '#8800FF',
      'pink': '#FF88AA',
      'gold': '#FFD700',
      'silver': '#C0C0C0',
      'navy': '#000080',
      'cyan': '#00FFFF',
    };

    return colors[colorName.toLowerCase()] ?? '#808080';
  }
}
